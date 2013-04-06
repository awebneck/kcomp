require 'rgl/adjacency'
require 'rgl/topsort'
require 'fileutils'
require File.dirname(__FILE__) + "/errors"

class KComp
  def initialize(src, dest)
    @depdg = RGL::DirectedAdjacencyGraph.new
    @texts = {}
    @ctexts = {}
    @vars = {}
    @src = src = src =~ /\/$/ ? src : src + "/"
    @dest = dest = dest =~ /\/$/ ? dest : dest + "/"
    build_vertices src
    @vertices = @depdg.to_a
    build_edges src
    check_for_cycles
    @tsort = @depdg.topsort_iterator
    @reversedg = @depdg.reverse
    @rtsort = @reversedg.topsort_iterator
    define_variables
  end

  def dependency_digraph
    @depdg
  end

  def reverse_dependency_digraph
    @reversedg
  end

  def files
    @tsort.to_a
  end

  def compile!
    compile_files(@dest)
    puts "Compilation complete"
  end

  private
    def define_variables
      @tsort.each do |v|
        rf = f = @texts[v]
        vars = {}
        f.scan(/(<!-- ?[$@]([A-Za-z_][A-Za-z0-9_\-]*) ?[ :=] *(.+) *-->)/).each do |var|
          vars[var[1]] = var.last.strip
          rf.gsub! var.first, ""
        end
        define_variables_for_vertex v, vars
      end
    end

    def define_variables_for_vertex(v, vars)
      @vars[v] ||= {}
      @vars[v].merge! vars
      @depdg.adjacent_vertices(v).each do |dep|
        define_variables_for_vertex dep, vars
      end
    end

    def compile_files(dest)
      @rtsort.each do |v|
        rf = f = @texts[v]
        f.scan(/(<!--!!! (.+) !!!-->)/).each do |import|
          rf.gsub! import.first, @ctexts[import.last]
        end
        f.scan(/(<!-- ?[$@]([A-Za-z_][A-Za-z0-9_\-]*) ?-->)/).each do |import|
          if @vars[v][import.last].nil?
            raise UndefinedVariableError, "Variable #{import.last} not defined."
          end
          rf.gsub! import.first, @vars[v][import.last]
        end
        @ctexts[v] = rf.gsub(/\n+/, "\n")
        if (v !~ /_[^\/]+\.kit$/)
          filename = dest + v.gsub(@src, "").gsub(/\.kit$/, ".html")
          dirname = filename.gsub(/\/[^\/]+$/, "")
          puts "Compiling #{filename}"
          unless Dir.exists?(dirname)
            FileUtils.mkdir_p dirname
          end
          File.open(filename, 'w+') do |file|
            file.write @ctexts[v]
          end
        end
      end
    end

    def check_for_cycles
      cycle = @depdg.cycles.first
      unless cycle.nil?
        last = cycle.pop
        text = cycle.join(", ")
        text += (cycle.length > 1 ? ", and " : " and ") + last
        raise CyclicDependencyError, "A cyclic dependency exists between: #{text}."
      end
    end

    def build_vertices(src)
      Dir.entries(src).each do |entry|
        if Dir.exists?(src + entry) && ![".", ".."].include?(entry)
          build_vertices(src + entry + "/")
        elsif entry =~ /\.kit$/
          @depdg.add_vertex src + entry
        end
      end
    end

    def build_edges(src)
      @depdg.vertices.each do |v|
        add_edges(src, v)
      end
    end

    def add_edges(src, vertex)
      rf = f = File.read(vertex)
      f.scan(/(<!-- ?@(?:import|include) ['"]?((?:[A-Za-z0-9_\/\-.]+(?:, *)?)+)['"]? ?-->)/).each do |import|
        repl = []
        import.last.split(/, */).each do |incl|
          match = nil
          if incl !~ /\.\w+$/
            incl = "#{incl}.kit"
          end
          if @vertices.include?(src + incl)
            match = src + incl
          elsif @vertices.include?(src + "_" + incl)
            match = src + "_" + incl
          else
            match = @vertices.select { |v| v =~ /#{incl}$/ }.first
            if match.nil?
              match = @vertices.select { |v| v =~ /_#{incl}$/ }.first
            end
          end
          if match.nil?
            raise MissingDependencyError, "File #{vertex} depends upon #{incl}, but no such file was found."
          end
          @depdg.add_edge vertex, match
          repl << match
        end
        rf.gsub! import.first, repl.map { |r| "<!--!!! #{r} !!!-->" }.join("\n")
      end
      @texts[vertex] = rf
    end

  def self.compile!(src, dest)
    kc = KComp.new src, dest
    kc.compile!
  end
end
