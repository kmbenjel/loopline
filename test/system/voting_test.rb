require "application_system_test_case"

# Browser-level checks for rendering, auth-gated controls, and navigation.
# The vote mutation itself (POST -> vote row + counter + Turbo Stream response)
# is covered deterministically in test/integration/voting_flow_test.rb, which is
# the right layer for it and avoids headless-CI click/async flakiness.
class VotingTest < ApplicationSystemTestCase
  # Fixture users have the password "password" (see test/fixtures/users.yml).
  def sign_in(user)
    visit new_session_path
    fill_in "Email", with: user.email_address
    fill_in "Password", with: "password"
    find("input[type=submit]").click
    assert_text "Sign out" # confirm authentication succeeded
  end

  test "a signed-in user sees an interactive upvote button on each idea" do
    sign_in(users(:two))
    visit board_path(boards(:acme))

    assert_text "Dark mode"
    within "##{dom_id(posts(:dark_mode), :vote)}" do
      # Real submit button (button_to form), not a sign-in link.
      assert_selector "button.vote-btn"
      assert_selector ".count", text: "1"
    end
  end

  test "a guest sees vote counts but is sent to sign in when voting" do
    visit board_path(boards(:acme))

    within "##{dom_id(posts(:dark_mode), :vote)}" do
      assert_selector ".count", text: "1"
      find("a.vote-btn").click # guests get a link, not a button
    end
    assert_selector "h1", text: "Sign in"
  end

  test "the public roadmap groups ideas by status" do
    visit board_path(boards(:acme))
    click_on "Roadmap"

    assert_selector "h1", text: "Roadmap"
    within ".roadmap-cols" do
      assert_text "Dark mode" # fixture status: planned
    end
  end
end
