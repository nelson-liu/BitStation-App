class CommentsController < ApplicationController
  before_filter :ensure_signed_in_without_redirect, only: [:new, :create, :destroy]
  before_filter :assign_transaction

  COMMENTS_INDEX_LIMIT = 10

  def destroy
    @comment = @transaction.comments.find(params[:id])

    begin
      (@error = 'You can only delete your own comments. ' and raise) unless @comment.user == current_user

      @comment.destroy!
      @success = true
    rescue
    end

    respond_to do |format|
      format.js
    end
  end

  def index
    @comments = @transaction.comments.limit(COMMENTS_INDEX_LIMIT).order('created_at DESC')

    render layout: false
  end

  def new
    @comment = Comment.new

    render layout: false
  end

  def create
    begin
      @comment = @transaction.comments.create!(comment_params.merge({user_id: current_user.id}))
      @success = true
    rescue => e
      @error = 'Invalid content. '
    end

    respond_to do |format|
      format.js do
        if @success
          @rendered_comment = render_to_string(partial: 'comment', layout: false, formats: [:html], locals: {comment: @comment})
        end
      end
    end
  end

  private

    def assign_transaction
      @transaction = Transaction.find(params[:transaction_id])
    end

    def comment_params
      params.require(:comment).permit(:content)
    end
end
