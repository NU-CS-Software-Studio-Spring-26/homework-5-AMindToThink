require "test_helper"

class TodoTest < ActiveSupport::TestCase
  test "is valid with a normal description" do
    assert Todo.new(description: "buy milk").valid?
  end

  test "is invalid with a blank description" do
    todo = Todo.new(description: "")
    assert_not todo.valid?
    assert_includes todo.errors[:description], "can't be blank"
  end

  test "is invalid with a nil description" do
    todo = Todo.new(description: nil)
    assert_not todo.valid?
    assert_includes todo.errors[:description], "can't be blank"
  end

  test "is invalid when description exceeds 500 characters" do
    todo = Todo.new(description: "a" * 501)
    assert_not todo.valid?
    assert_includes todo.errors[:description], "is too long (maximum is 500 characters)"
  end

  test "is valid at exactly 500 characters" do
    assert Todo.new(description: "a" * 500).valid?
  end

  test "cannot persist an invalid todo" do
    assert_no_difference("Todo.count") do
      Todo.create(description: "")
    end
  end
end
