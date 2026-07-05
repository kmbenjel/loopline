require "test_helper"

class VotingFlowTest < ActionDispatch::IntegrationTest
  setup do
    @user = users(:two)          # has not voted on dark_mode
    @post = posts(:dark_mode)    # votes_count: 1
  end

  test "guest sees vote counts but is pointed to sign in" do
    get board_path(boards(:acme))
    assert_response :success
    assert_select ".vote-btn", minimum: 1
  end

  test "signed-in user can upvote and un-vote a post" do
    sign_in_as(@user)

    assert_difference -> { @post.reload.votes_count }, +1 do
      post post_vote_path(@post), headers: { "Accept" => "text/vnd.turbo-stream.html" }
    end
    assert_response :success
    assert_match "turbo-stream", @response.media_type

    assert_difference -> { @post.reload.votes_count }, -1 do
      delete post_vote_path(@post), headers: { "Accept" => "text/vnd.turbo-stream.html" }
    end
    assert_response :success
  end

  test "voting twice does not double-count" do
    sign_in_as(@user)
    post post_vote_path(@post)
    assert_no_difference -> { @post.reload.votes_count } do
      post post_vote_path(@post)
    end
  end

  test "guest cannot vote" do
    assert_no_difference -> { @post.reload.votes_count } do
      post post_vote_path(@post)
    end
    assert_response :redirect
  end
end
