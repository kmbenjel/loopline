require "test_helper"

class BoardsFlowTest < ActionDispatch::IntegrationTest
  setup { @user = users(:one) }

  test "anyone can view the boards index and a board" do
    get root_path
    assert_response :success
    assert_select ".board-card", minimum: 1

    get board_path(boards(:acme))
    assert_response :success
    assert_select "h1", text: "Acme Feedback"
  end

  test "signed-in user creates a board with an auto slug" do
    sign_in_as(@user)
    assert_difference -> { Board.count }, +1 do
      post boards_path, params: { board: { name: "New Product", description: "Hi" } }
    end
    board = Board.order(:created_at).last
    assert_equal "new-product", board.slug
    assert_redirected_to board_path(board)
  end

  test "guest is redirected to sign in when creating a board" do
    assert_no_difference -> { Board.count } do
      post boards_path, params: { board: { name: "Nope" } }
    end
    assert_redirected_to new_session_path
  end

  test "signed-in user posts feedback to a board" do
    sign_in_as(@user)
    board = boards(:acme)
    assert_difference -> { board.posts.count }, +1 do
      post board_posts_path(board), params: { post: { title: "Faster search" } }
    end
    assert_redirected_to board_path(board)
  end

  test "board owner can move a post across roadmap statuses" do
    sign_in_as(users(:one)) # owner of acme
    patch status_post_path(posts(:integrations)), params: { status: "planned" }
    assert_equal "planned", posts(:integrations).reload.status
  end

  test "non-owner cannot change post status" do
    sign_in_as(users(:two)) # not the acme board owner
    patch status_post_path(posts(:integrations)), params: { status: "done" }
    assert_not_equal "done", posts(:integrations).reload.status
  end
end
