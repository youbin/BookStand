class CommentController < ApplicationController
  before_action	:set_comment, only: [:show, :get]
  before_action :set_book_detail, only: [:index]
  protect_from_forgery :only => [:create]

  def index
    @comments = Comment.all(params[:b_id], params[:r_id])
    @comments[:book_detail] = @book_detail
    render json: @comments, status: :ok
  end

  def show
    @comment["b_id"] = params[:b_id]
    @comment["r_id"] = params[:r_id]
  end

  def get
    render json: @comment, status: :ok
  end

  def getComment b_id, r_id, cm_id
    comment = Comment.find(b_id, r_id, cm_id)
    return comment.hgetComment
  end
   
  def create
    Log.debug(self, params, 'begin')
    params_comment = params
    params_comment['cm_time'] = Time.now
    b_id = params_comment["b_id"]
    r_id = params_comment["r_id"]
    comment = Comment.new(b_id, r_id)
    hash_args = CommonMethods.makeArgs(params_comment, *Comment.fields)
    comment_hash = comment.hmset(*hash_args)
    if comment.save
      render json: comment_hash, status: :ok
    comment_hash["b_id"] = b_id
    comment_hash["r_id"] = r_id
    comment_hash["type"] = 'comment'
    comment_hash["f_time"] = comment_hash["cm_time"]
    reviewController = ReviewController.new
    reviewController.addCm_idToReview(b_id, r_id, comment_hash["cm_id"])
    feedController = FeedController.new
    feedController.createFeedWithHash comment_hash
    Log.debug(self, params, 'end')
    end
  end

  def delete
    Log.debug(self, params, 'begin')
    delete_return = Comment.delete(params['b_id'], params['r_id'], params['cm_id'])
    render json: delete_return, status: :ok
    Log.debug(self, params, 'end')
  end

  private
    def set_comment
      b_id = params[:b_id]
      r_id = params[:r_id]
      cm_id = params[:cm_id]
      comment = Comment.find(b_id, r_id, cm_id)
      @comment = comment.hgetall
    end
    def set_book_detail
      b_id = params[:b_id]
      book = Book.find(b_id)
      @book_detail = BookDetail.find(b_id)
      @book_detail[:b_totalStar] = book.b_totalStar
      @book_detail[:b_starNum] = book.b_starNum
      @book_detail[:b_likeCount] = book.b_likeCount
      @book_detail[:b_belongCount] = book.b_belongCount
    end
end
