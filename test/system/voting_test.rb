require "application_system_test_case"

class VotingTest < ApplicationSystemTestCase
  # Fixture users have the password "password" (see test/fixtures/users.yml).
  def sign_in(user)
    visit new_session_path
    fill_in "Email", with: user.email_address
    fill_in "Password", with: "password"
    find("input[type=submit]").click
    assert_text "Sign out" # confirm authentication succeeded
  end

  test "a signed-in user upvotes a post and the count updates live" do
    user = users(:two) # has not voted on dark_mode yet
    post = posts(:dark_mode)
    sign_in(user)

    visit board_path(boards(:acme))
    assert_text "Dark mode"

    vote = "##{dom_id(post, :vote)}"
    assert_selector "#{vote} .count", text: "1"
    find("#{vote} button.vote-btn").click

    # Turbo Stream replaces the button in place — no full page reload.
    # Capybara's assert_selector waits for the async stream to apply.
    assert_selector "#{vote} .count", text: "2"
    assert_selector "#{vote} button.voted" # button flipped to "remove vote"
    assert_equal 2, post.reload.votes_count
    # (Un-voting / destroy is covered deterministically in the integration test.)
  end

  test "a guest is sent to sign in when trying to vote" do
    visit board_path(boards(:acme))
    within "##{dom_id(posts(:dark_mode), :vote)}" do
      find("a.vote-btn").click
    end
    assert_selector "h1", text: "Sign in"
  end
end
