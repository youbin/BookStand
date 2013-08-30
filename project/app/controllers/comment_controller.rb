class CommentController < ApplicationController
  before_action	:set_comment, only: [:show, :get]
  protect_from_forgery :only => [:create]

  def index
    @comments = Comment.all(params[:b_id], params[:r_id])
    render json: @comments, status: :ok
  end

  def show
    @comment["b_id"] = params[:b_id]
    @comment["r_id"] = params[:r_id]
  end

  def get
    respond_to do |format|
      format.json { render :json => @comment}
    end
  end

  def getComment b_id, r_id, cm_id
    comment = Comment.find(b_id, r_id, cm_id)
    return comment.hgetComment
  end
   
  def create
    Log.debug(self, params, 'begin')
    params_comment = ActiveSupport::JSON.decode(params[:comment])
    params_comment['cm_time'] = Time.now
    b_id = params_comment["b_id"]
    r_id = params_comment["r_id"]
    comment = Comment.new(b_id, r_id)
    hash_args = CommonMethods.makeArgs(params_comment, *Comment.fields)
    comment_hash = comment.hmset(*hash_args)
    respond_to do |format|
      if comment.save
        format.json { render :json => comment_hash}
      end
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

  private
    def set_comment
      b_id = params[:b_id]
      r_id = params[:r_id]
      cm_id = params[:cm_id]
      comment = Comment.find(b_id, r_id, cm_id)
      @comment = comment.hgetall
    end
end
