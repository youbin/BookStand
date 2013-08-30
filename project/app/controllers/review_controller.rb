class ReviewController < ApplicationController
  before_action	:set_review, only: [:show, :get]
  protect_from_forgery :only => [:create]

  def index
    reviews = Review.all(params[:b_id])
    respond_to do |format|
      format.json { render json: reviews, status: :ok }
    end
  end

  def show
    @review["b_id"] = params[:b_id]
  end

  def get
    respond_to do |format|
      format.json { render :json => @review}
    end
  end

  def getReview b_id, r_id
    review = Review.find(b_id, r_id)
    return review.hgetReview
  end

  def addCm_idToReview(b_id, r_id, cm_id)
    review = Review.find(b_id, r_id)
    review.saddToCm_id(cm_id)
  end
   
  def create
    Log.debug(self, params, 'begin')
    params['r_time'] = Time.now
    b_id = params['b_id']
    review = Review.new(b_id)
    hash_args = CommonMethods.makeArgs(params, *Review.fields)
    review_hash = review.hmset(*hash_args)
    respond_to do |format|
      if review.save
        format.json { render json: review_hash, status: :created}
      end
    end
    review_hash["b_id"] = b_id
    review_hash["type"] = 'review'
    review_hash["f_time"] = review_hash["r_time"]
    book = BooksController.new
    book.review b_id, review_hash["r_id"]
    feed = FeedController.new
    feed.createFeedWithHash review_hash
    Log.debug(self, params, 'end')
  end

  private
    def set_review
      b_id = params[:b_id]
      r_id = params[:r_id]
      review = Review.find(b_id, r_id)
      @review = review.hgetall
    end
end
