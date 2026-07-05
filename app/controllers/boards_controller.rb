class BoardsController < ApplicationController
  allow_unauthenticated_access only: %i[ index show roadmap ]
  before_action :set_board, only: %i[ show roadmap edit update destroy ]
  before_action :require_owner, only: %i[ edit update destroy ]

  def index
    @boards = Board.order(created_at: :desc)
  end

  def show
    @posts = @board.posts.popular.includes(:user)
    @post = Post.new
  end

  def roadmap
    @columns = {
      planned:     @board.posts.where(status: :planned).popular.includes(:user),
      in_progress: @board.posts.where(status: :in_progress).popular.includes(:user),
      done:        @board.posts.where(status: :done).popular.includes(:user)
    }
  end

  def new
    @board = Board.new
  end

  def create
    @board = Current.user.boards.build(board_params)
    if @board.save
      redirect_to @board, notice: "Board created."
    else
      render :new, status: :unprocessable_entity
    end
  end

  def edit
  end

  def update
    if @board.update(board_params)
      redirect_to @board, notice: "Board updated."
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    @board.destroy
    redirect_to boards_path, notice: "Board deleted.", status: :see_other
  end

  private

  def set_board
    @board = Board.find_by!(slug: params[:id])
  end

  def require_owner
    redirect_to @board, alert: "Only the owner can do that." unless @board.user == Current.user
  end

  def board_params
    params.require(:board).permit(:name, :description)
  end
end
