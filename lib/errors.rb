class KComp
  class MissingDependencyError < Exception; end
  class CyclicDependencyError < Exception; end
end
