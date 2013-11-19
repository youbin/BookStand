class ReviewController < ApplicationController
  before_action	:set_review, only: [:show, :get]
  # before_action :set_book_detail, only: [:get]
  protect_from_forgery :only => [:create, :update]

  def index
    reviews = Review.all(params[:b_id])
    render json: reviews, status: :ok
  end

  def show
    @review["b_id"] = params[:b_id]
  end

  def get
    # @review[:book_detail] = @book_detail
    render json: @review, status: :ok
  end

  def getReview b_id, r_id
    review = Review.find(b_id, r_id)
    return review.hgetReview
  end

  def addCm_idToReview(b_id, r_id, cm_id)
    review = Review.find(b_id, r_id)
    review.saddToCm_id(cm_id)
  end

  def modify_review_count b_id, point
    book = Book.find(b_id)
    reviewCount = book.b_reviewCount
    if (reviewCount == nil)
      reviewCount = 0
    end
    reviewCount = reviewCount + point
    book.update(:b_reviewCount => reviewCount)
  end

  def increase_review_count b_id
    modify_review_count(b_id, 1)
  end

  def decrease_review_count b_id
    modify_review_count(b_id, -1)
  end

  def update
    Log.debug(self, params, 'begin')
    b_id = params[:b_id]
    if (b_id == nil or b_id == '(null)' or
        params[:r_id] == nil or params[:r_id] == '(null)')
      render json: 'error', status: :ok
      return
    end
    review = Review.find(b_id, params[:r_id])
    review_detail = review.hgetReview
    params['r_time'] = Time.now
    if params[:r_review] != ''
      ReviewActivity.setReviewActivity(b_id, params[:r_id], params['r_time'].to_i)
    end
    if (params[:r_review] == '' and review_detail[Review.fields.index('r_review')] != '')
      decrease_review_count(b_id)
    elsif (params[:r_review] != '' and review_detail[Review.fields.index('r_review')] == '')
      increase_review_count(b_id)
    end
    hash_args = CommonMethods.makeArgs(params, *Review.fields)
    review_hash = review.hmset(*hash_args)
    booksController = BooksController.new
    booksController.average_star(b_id, review_detail[Review.fields.index('r_starPoint')].to_f, params[:r_starPoint].to_f)
    render json: nil ,status: :ok
    Log.debug(self, params, 'end')
  end
   
  def create
    Log.debug(self, params, 'begin')
    params['r_time'] = Time.now
    b_id = params['b_id']
    review = Review.new(b_id)
    hash_args = CommonMethods.makeArgs(params, *Review.fields)
    review_hash = review.hmset(*hash_args)
    if review.save
      render json: review_hash, status: :created
    end
    review_hash["b_id"] = b_id
    review_hash["type"] = 'review'
    review_hash["f_time"] = review_hash["r_time"]
    if (params[:r_review] != '')
      increase_review_count(b_id)
    end
    book = BooksController.new
    book.average_star(b_id, -1.0, params['r_starPoint'].to_f)
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
