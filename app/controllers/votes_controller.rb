class VotesController < ApplicationController
  before_action :set_post

  def create
    @post.votes.find_or_create_by(user: Current.user)
    respond_to_vote
  end

  def destroy
    @post.votes.where(user: Current.user).destroy_all
    respond_to_vote
  end

  private

  def set_post
    @post = Post.find(params[:post_id])
  end

  def respond_to_vote
    @post.reload
    respond_to do |format|
      format.turbo_stream do
        render turbo_stream: turbo_stream.replace(
          helpers.dom_id(@post, :vote),
          partial: "posts/vote_button",
          locals: { post: @post }
        )
      end
      format.html { redirect_back fallback_location: @post }
    end
  end
end
