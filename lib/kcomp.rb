require 'rgl/adjacency'
require 'rgl/topsort'
require 'fileutils'
require 'pry'
require File.dirname(__FILE__) + "/errors"

class KComp
  def initialize(src, dest, opts={})
    @options = opts
    @depdg = RGL::DirectedAdjacencyGraph.new
    @texts = {}
    @compiled = []
    @src = src = src =~ /\/$/ ? src : src + "/"
    if @src !~ /^[.\/]/
      @src = "./" + @src
    end
    @dest = dest = dest =~ /\/$/ ? dest : dest + "/"
    if @dest !~ /^[.\/]/
      @dest = "./" + @dest
    end
    build_vertices @src
    @vertices = @depdg.to_a
    build_edges @src
    check_for_cycles
    @tsort = @depdg.topsort_iterator
    @reversedg = @depdg.reverse
    @rtsort = @reversedg.topsort_iterator
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

    def compile_inclusion(vertex, dest, ovars={}, inclusion=false)
      vars = ovars.dup
      f = @texts[vertex].dup
      rf = f.dup
      if (vertex !~ /_[^\/]+\.kit$/ || inclusion)
        f.scan(/(<!-- *[$@]([A-Za-z0-9_][A-Za-z0-9_]*) *-->)|(<!-- ?[$@]([A-Za-z0-9_][A-Za-z0-9_]*) ?[ :=] *(.+) *-->)|(<!--!!! (.+) !!!-->)/).each do |import|
          begin
            if (import[0].nil? && import[2].nil?)
              rf.gsub! import[5], compile_inclusion(import[6], dest, vars, true).rstrip
            elsif (import[5].nil? && import[2].nil?)
              rf.gsub! import[0], vars[import[1]]
            else
              vars[import[3]] = import[4].strip
              rf.gsub!(import[2] + "\n", "")
              rf.gsub!(import[2], "")
            end
          end
        end
        if (vertex !~ /_[^\/]+\.kit$/)
          unless @options[:flatten]
            filename = dest + vertex.gsub(@src, "").gsub(/\.kit$/, detect_format(rf))
            dirname = filename.gsub(/\/[^\/]+$/, "")
          else
            filename = dest + vertex.gsub(/([^\/]+\/)+/, "").gsub(/\.kit$/, detect_format(rf))
            dirname = filename.gsub(/\/[^\/]+$/, "")
          end
          puts "Compiling #{filename}"
          unless Dir.exists?(dirname)
            FileUtils.mkdir_p dirname
          end
          File.open(filename, 'w+') do |file|
            file.write rf
          end
        end
      end
      rf
    end

    def compile_files(dest)
      @tsort.each do |v|
        compile_inclusion(v, dest)
      end
    end

    def detect_format(text)
      case text
      when /<\?php/
        ".php"
      when /<%=?/
        ".erb"
      else
        ".html"
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
        add_edges(src, v, v.gsub(src, "").gsub(/\/[^\/]+$/, "") + "/")
      end
    end

    def add_edges(src, vertex, subdir="")
      rf = f = File.read(vertex)
      f.scan(/(<!-- ?@(?:import|include) ['"]?((?:[A-Za-z0-9_\/\-.]+(?:, *)?)+)['"]? ?-->)/).each do |import|
        repl = []
        import.last.split(/, */).each do |incl|
          match = nil
          if incl !~ /\.\w+$/
            incl = "#{incl}.kit"
          end
          if @vertices.include?(src + subdir + incl)
            match = src + subdir + incl
          elsif @vertices.include?(src + subdir + incl.gsub(/\/([^\/]+)$/, "/_#{$1}"))
            match = src + subdir + "_" + incl
          else
            match = @vertices.select { |v| v =~ /#{incl}$/ }.first
            if match.nil?
              match = @vertices.select { |v| v =~ /#{incl.gsub(/([^\/]+\/)+/, "")}$/ }.first
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

  def self.compile!(src, dest, opts={})
    kc = KComp.new src, dest, opts
    kc.compile!
  end
end
