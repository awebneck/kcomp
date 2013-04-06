class KComp
  class MissingDependencyError < Exception; end
  class CyclicDependencyError < Exception; end
  class UndefinedVariableError < Exception; end
end
