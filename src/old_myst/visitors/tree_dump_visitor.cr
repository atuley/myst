require "colorize"

module Myst
  class TreeDumpVisitor
    macro visit(*node_types)
      {% for node_type in node_types %}
        def visit(node : {{node_type}})
          {{yield}}
        end
      {% end %}
    end


    property io : IO

    def initialize(@io : IO)
    end


    visit AST::Node do
      io.puts(node.type_name)
      io << "\n"
    end

    visit AST::Block, AST::ExpressionList, AST::ParameterList do
      io << "#{node.type_name}".colorize(:red).mode(:bold)
      io << "/#{node.children.size}\n"
      recurse node.children
    end

    visit AST::RequireStatement, AST::IncludeStatement do
      io << "#{node.type_name}\n".colorize(:red)
      recurse [node.path]
    end

    visit AST::ReturnStatement, AST::BreakStatement, AST::NextStatement do
      io << "#{node.type_name}".colorize(:green).mode(:bold)
      if node.value
        io << "\n"
        recurse [node.value.not_nil!]
      end
    end

    visit AST::ModuleDefinition, AST::FunctionDefinition do
      io << "#{node.type_name}".colorize(:blue).mode(:bold)
      io << "|#{node.name}\n"
      recurse node.children
    end

    visit AST::Pattern do
      io << "#{node.type_name}".colorize(:cyan)
      io << "|#{node.name}\n"
    end

    visit AST::SimpleAssignment do
      io << "#{node.type_name}\n".colorize(:green)
      recurse [node.target, node.value]
    end

    visit AST::PatternMatchingAssignment do
      io << "#{node.type_name}\n".colorize(:green)
      recurse [node.pattern, node.value]
    end

    visit AST::WhenExpression, AST::UnlessExpression do
      io << "#{node.type_name}\n".colorize(:blue)
      recurse [node.condition, node.body, node.alternative].compact
    end

    visit AST::ElseExpression do
      io << "#{node.type_name}\n".colorize(:blue)
      recurse [node.body]
    end

    visit AST::WhileExpression, AST::UntilExpression do
      io << "#{node.type_name}\n".colorize(:blue)
      recurse [node.condition, node.body]
    end

    visit AST::LogicalExpression, AST::EqualityExpression, AST::RelationalExpression, AST::BinaryExpression do
      io << "#{node.type_name}".colorize(:cyan)
      io << "|#{node.operator}\n"
      recurse [node.left, node.right]
    end

    visit AST::UnaryExpression do
      io << "#{node.type_name}".colorize(:cyan)
      io << "|#{node.operator}\n"
      recurse [node.operand]
    end

    visit AST::FunctionCall do
      io << "#{node.type_name}\n".colorize(:white)
      recurse node.children
    end

    visit AST::MemberAccessExpression do
      io << "#{node.type_name}|#{node.member}\n".colorize(:white)
      recurse [node.receiver]
    end

    visit AST::MemberAssignmentExpression do
      io << "#{node.type_name}|#{node.member}\n".colorize(:white)
      recurse [node.receiver, node.value]
    end

    visit AST::AccessExpression do
      io << "#{node.type_name}\n".colorize(:white)
      recurse [node.target, node.key]
    end

    visit AST::AccessSetExpression do
      io << "#{node.type_name}\n".colorize(:white)
      recurse [node.target, node.key, node.value]
    end

    visit AST::MapEntryDefinition do
      io << "#{node.type_name}\n".colorize(:dark_gray)
      recurse [node.key, node.value]
    end

    visit AST::ValueInterpolation do
      io << "#{node.type_name}\n".colorize(:white)
      recurse [node.value]
    end



    visit AST::Ident, AST::Const do
      io << "#{node.type_name}".colorize(:dark_gray)
      io << "(#{node.name})\n"
    end

    visit AST::IntegerLiteral, AST::FloatLiteral, AST::StringLiteral, AST::SymbolLiteral, AST::BooleanLiteral do
      io << "#{node.type_name}".colorize(:yellow)
      io << "(#{node.value})\n"
    end

    visit AST::NilLiteral do
      io << "#{node.type_name}".colorize(:yellow)
      io << "(nil)\n"
    end

    visit AST::ListLiteral, AST::MapLiteral do
      io << "#{node.type_name}\n".colorize(:yellow)
      recurse [node.elements]
    end



    COLORS = [
      # :green, :blue, :magenta, :cyan,
      :light_green, :light_blue, :light_magenta, :light_cyan,
      :light_gray, :dark_gray
    ]

    macro recurse(children)
      current_color = COLORS.sample
      {{children}}.each_with_index do |child, child_index|
        str = String.build do |str|
          old_buf = @io
          @io = str
          child.accept(self)
          @io = old_buf
        end

        str.lines.each_with_index do |line, line_index|
          if line_index == 0
            if node.children.size > 1 && child_index < node.children.size-1
              io << "├─".colorize(current_color)
            else
              io << "└─".colorize(current_color)
            end
          else
            if node.children.size > 1 && child_index < node.children.size-1
              io << "│ ".colorize(current_color)
            else
              io << "  ".colorize(current_color)
            end
          end

          io << line
          io << "\n"
        end
      end
    end
  end
end