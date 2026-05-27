require "test_helper"

class TodosControllerTest < ActionDispatch::IntegrationTest
  setup do
    @todo = todos(:one)
    sign_in_as(users(:one)) # auth is now required app-wide
  end

  test "should get index" do
    get todos_url
    assert_response :success
  end

  test "should get new" do
    get new_todo_url
    assert_response :success
  end

  test "should create todo" do
    assert_difference("Todo.count") do
      post todos_url, params: { todo: { description: @todo.description } }
    end

    assert_redirected_to todo_url(Todo.last)
  end

  test "should show todo" do
    get todo_url(@todo)
    assert_response :success
  end

  test "should get edit" do
    get edit_todo_url(@todo)
    assert_response :success
  end

  test "should update todo" do
    patch todo_url(@todo), params: { todo: { description: @todo.description } }
    assert_redirected_to todo_url(@todo)
  end

  test "should destroy todo" do
    assert_difference("Todo.count", -1) do
      delete todo_url(@todo)
    end

    assert_redirected_to todos_url
  end

  # --- Part 4: high-priority Turbo Streams toggle ---

  test "toggle_priority flips the flag and responds with a Turbo Stream" do
    assert_not @todo.high_priority, "fixture should start not high priority"

    patch toggle_priority_todo_url(@todo),
          headers: { "Accept" => "text/vnd.turbo-stream.html" }

    # The story's hard requirement: prove the response is a Turbo Stream,
    # not plain HTML.
    assert_equal "text/vnd.turbo-stream.html", response.media_type
    assert @todo.reload.high_priority, "toggling should flip high_priority on"

    # And it must replace ONLY this row, targeting its dom_id.
    assert_match %r{<turbo-stream action="replace" target="todo_#{@todo.id}">},
                 response.body
  end

  test "toggle_priority falls back to an HTML redirect for non-Turbo requests" do
    patch toggle_priority_todo_url(@todo)

    assert_redirected_to todos_url
    assert @todo.reload.high_priority
  end
end
