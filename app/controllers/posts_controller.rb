class PostsController < ApplicationController
  allow_unauthenticated_access only: %i[ show ]
  before_action :set_board, only: %i[ new create ]
  before_action :set_post, only: %i[ show edit update destroy status ]
  before_action :require_author, only: %i[ edit update destroy ]
  before_action :require_board_owner, only: %i[ status ]

  def show
  end

  def new
    @post = @board.posts.build
  end

  def create
    @post = @board.posts.build(post_params)
    @post.user = Current.user
    if @post.save
      redirect_to @post.board, notice: "Feedback posted."
    else
      @posts = @board.posts.popular.includes(:user)
      render "boards/show", status: :unprocessable_entity
    end
  end

  def edit
  end

  def update
    if @post.update(post_params)
      redirect_to @post, notice: "Post updated."
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    board = @post.board
    @post.destroy
    redirect_to board, notice: "Post deleted.", status: :see_other
  end

  # Board owner moves a post across roadmap statuses.
  def status
    if Post.statuses.key?(params[:status]) && @post.update(status: params[:status])
      redirect_to @post, notice: "Status updated to #{@post.status_label}."
    else
      redirect_to @post, alert: "Invalid status."
    end
  end

  private

  def set_board
    @board = Board.find_by!(slug: params[:board_id])
  end

  def set_post
    @post = Post.includes(:board, :user).find(params[:id])
  end

  def require_author
    redirect_to @post, alert: "Only the author can do that." unless @post.user == Current.user
  end

  def require_board_owner
    redirect_to @post, alert: "Only the board owner can do that." unless @post.board.user == Current.user
  end

  def post_params
    params.require(:post).permit(:title, :description)
  end
end
