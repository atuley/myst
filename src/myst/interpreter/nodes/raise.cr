module Myst
  class Interpreter
    def visit(node : Raise)
      visit(node.value)
      value = stack.pop

      raise RuntimeError.new(value, callstack)
    end
  end
end
