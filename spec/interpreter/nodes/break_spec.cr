require "../../spec_helper.cr"
require "../../support/nodes.cr"
require "../../support/interpret.cr"

describe "Interpreter - Break" do
  describe "when used inside a block" do
    it "returns from the function that called the block" do
      itr = parse_and_interpret %q(
        def foo(&block)
          block(1)
          :did_not_leave_foo
        end

        foo do |a|
          break 1
        end
      )

      itr.stack.pop.should eq(val(1))
    end

    it "immediately stops execution of the containing block" do
      itr = parse_and_interpret %q(
        def foo(&block)
          block(1)
          :did_not_leave_foo
        end

        foo do |a|
          break 1
          :did_not_leave_block
        end
      )

      itr.stack.pop.should eq(val(1))
    end
  end
end
