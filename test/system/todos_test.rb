require "application_system_test_case"

class TodosTest < ApplicationSystemTestCase
  setup do
    @todo = todos(:one)
    # auth is now required app-wide; log in through the UI before each test
    visit new_session_path
    fill_in "email_address", with: users(:one).email_address
    fill_in "password", with: "password"
    click_on "Sign in"
    assert_selector "h1", text: "Todos" # wait for the post-login redirect to land
  end

  test "visiting the index" do
    visit todos_url
    assert_selector "h1", text: "Todos"
  end

  test "should create todo" do
    visit todos_url
    click_on "New todo"

    fill_in "Description", with: @todo.description
    click_on "Create Todo"

    assert_text "Todo was successfully created"
    click_on "Back"
  end

  test "should update Todo" do
    visit todo_url(@todo)
    click_on "Edit this todo", match: :first

    fill_in "Description", with: @todo.description
    click_on "Update Todo"

    assert_text "Todo was successfully updated"
    click_on "Back"
  end

  test "should destroy Todo" do
    visit todo_url(@todo)
    click_on "Destroy this todo", match: :first

    assert_text "Todo was successfully destroyed"
  end

  test "toggling high priority updates the row in place via Turbo Stream" do
    visit todos_url

    # Row starts at grey/"Normal"; clicking the star toggles it.
    within "#todo_#{@todo.id}" do
      click_button "Mark as high priority"
    end

    # Turbo replaced ONLY this row: its toggle now offers to remove priority,
    # which is only true if the row re-rendered in place (no full reload).
    assert_selector "#todo_#{@todo.id} button[title='Remove high priority']"
    assert_selector "#todo_#{@todo.id}", text: "High priority"
  end
end
