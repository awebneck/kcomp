require 'rgl/adjacency'
require 'rgl/topsort'
require 'fileutils'
require File.dirname(__FILE__) + "/errors"

class KComp
  def initialize
    @depdg = RGL::DirectedAdjacencyGraph.new
    @texts = {}
    @vars = {}
  end

  def compile!(src, dest)
    @src = src = src =~ /\/$/ ? src : src + "/"
    @dest = dest = dest =~ /\/$/ ? dest : dest + "/"
    check_for_cycles(src)
    compile_files(dest)
  end

  private
    def compile_files(dest)
      @depdg.topsort_iterator.to_a.reverse.each do |v|
        rf = f = @texts[v]
        f.scan(/(<!--!!! (.+) !!!-->)/).each do |import|
          rf.gsub! import.first, @texts[import.last]
        end
        @texts[v] = rf
        if (v !~ /_[^\/]+\.kit$/)
          filename = dest + v.gsub(@src, "").gsub(/\.kit$/, ".html")
          dirname = filename.gsub(/\/[^\/]+$/, "")
          puts "Compiling #{filename}"
          unless Dir.exists?(dirname)
            FileUtils.mkdir_p dirname
          end
          File.open(filename, 'w+') do |file|
            file.write rf
          end
        end
      end
    end

    def check_for_cycles(src)
      build_vertices src
      build_edges src
      cycle = @depdg.cycles.first
      unless cycle.nil?
        last = cycle.pop
        text = cycle.join(", ")
        text += (cycle.length > 1 ? ", and " : " and ") + last
        raise CyclicDependencyError, "A cyclic dependency exists between: #{text}"
      end
    end

    def build_vertices(src)
      Dir.entries(src).each do |entry|
        if Dir.exists?(src + entry) && ![".", ".."].include?(entry)
          check_for_cycles(src + entry + "/")
        elsif entry =~ /\.kit$/
          @depdg.add_vertex src + entry
        end
      end
    end

    def build_edges(src)
      @depdg.each_vertex do |v|
        add_edges(src, v)
      end
    end

    def add_edges(src, vertex)
      rf = f = File.read vertex
      vertices = @depdg.to_a
      f.scan(/(<!-- ?@(?:import|include) ['"]?((?:[A-Za-z0-9_\/\-.]+(?:, *)?)+)['"]? ?-->)/).each do |import|
        repl = []
        import.last.split(/, */).each do |incl|
          match = nil
          if vertices.include?(src + incl)
            match = src + incl
          elsif vertices.include?(src + "_" + incl)
            match = src + "_" + incl
          else
            match = vertices.select { |v| v =~ /#{incl}$/ }.first
            if match.nil?
              match = vertices.select { |v| v =~ /_#{incl}$/ }.first
            end
          end
          if match.nil?
            raise MissingDependencyError, "File #{vertex} depends upon #{incl}, but no such file was found"
          end
          @depdg.add_edge vertex, match
          repl << match
        end
        rf.gsub! import.first, repl.map { |r| "<!--!!! #{r} !!!-->" }.join("\n")
      end
      @vars[vertex] = {}
      f.scan(/(<!-- ?(?:@|\$)(\w+) ?[ :=] *(\.+) *-->)/).each do |var|
        @vars[vertex][var[1]] = var.last
        rf.gsub! var.first, ""
      end
      @texts[vertex] = rf
    end

  def self.compile!(src, dest)
    kc = KComp.new
    kc.compile! src, dest
  end
end
