class FeedController < ApplicationController
  before_action	:set_feed, only: [:show, :get]
  protect_from_forgery :only => [:create]

  def index
    @feeds = Feed.all
  end

  def show
  end

  def get
    respond_to do |format|
      format.json { render :json => @feed}
    end
  end

  def getFeeds *feeds
    Feed.getFeeds(*feeds)
  end

  def getRecentTopBookFeeds
    book_activities = BookActivity.getBookActivities
    return_book_activities = Array.new
    count_of_books = 0
    book_activities.each do |book_activity|
      next if BookDetail.where(:_id => book_activity[0]).exists? == false
      if (count_of_books >= 10)
        break
      end
      count_of_books = count_of_books + 1
      book_detail_info = BookDetail.find(book_activity[0])
      book_info = Book.find(book_activity[0])
      book_info['b_category'] = book_detail_info['b_category']
      book_info['b_author'] = book_detail_info['b_author']
      book_info['b_translator'] = book_detail_info['b_translator']
      book_info['b_publisher'] = book_detail_info['b_publisher']
      book_info['b_publishDate'] = book_detail_info['b_publishDate']
      book_info['b_lastUpdateDate'] = Time.at(book_activity[1])
      return_book_activities << book_info
    end
    render json: return_book_activities, status: :ok
  end

  def getRecentTopReviewFeeds
    Log.debug(self, 'no parameters', 'begin')
    review_activities = ReviewActivity.getReviewActivities
    Log.debug(self, review_activities, 'review activities')
    return_review_activities = Hash.new
    review_activities_array = Array.new
    book_hash = Hash.new
    user_hash = Hash.new
    count_of_reviews = 0
    Log.debug(self, 'no parameters', 'loop start for review_activities array')
    review_activities.each_with_index do |review_activity, index|
      Log.debug(self, {:index => index, :count_of_reviews => count_of_reviews, :review_activity => review_activity}, 'index and count of index for review_activity')
      if (count_of_reviews >= 10)
        break
      end
      review_detail_info = Review.hgetall review_activity[0]
      Log.debug(self, review_detail_info, 'review_detail_info for review_activity')
      next if review_detail_info == nil
      count_of_reviews = count_of_reviews + 1
      review_activities_array << review_detail_info
      if user_hash[review_detail_info['u_id']] == nil and User.where(:id => review_detail_info['u_id']).exists?
        user_detail = User.find(review_detail_info['u_id'])
        user_basic = Hash.new
        user_basic[:_id] = user_detail[:_id]
        user_basic[:u_nickName] = user_detail[:u_nickName]
        user_basic[:u_picture] = user_detail[:u_picture]
        user_hash[review_detail_info['u_id']] = user_basic
        Log.debug(self, user_basic, 'user_basic')
      end
      if book_hash[review_detail_info['b_id']] == nil and Book.where(:id => review_detail_info['b_id']).exists?
        book_detail = Book.find(review_detail_info['b_id'])
        book_basic = Hash.new
        book_basic[:_id] = book_detail[:_id]
        book_basic[:b_title] = book_detail[:b_title]
        book_hash[review_detail_info['b_id']] = book_basic
        Log.debug(self, book_basic, 'book_basic')
      end
    end
    Log.debug(self, 'no parameters', 'end of loop for review_activities array')
    return_review_activities['reviews'] = review_activities_array
    return_review_activities['users'] = user_hash
    return_review_activities['books'] = book_hash
    Log.debug(self, return_review_activities, 'end')
    render json: return_review_activities, status: :ok
  end

  def createFeedWithHash hash
    Log.debug(self, hash, 'begin')
    feed = Feed.new
    hash_args = CommonMethods.makeArgs(hash, *Feed.fields)
    feed_hash = feed.hmset(*hash_args)
    if feed.save == false
      return nil
    end
    type = hash['type']
    if type == 'review' or type == 'comment' or type == 'enroll'
      Log.debug(self, {:user_id => feed_hash['u_id'], :action_type => type}, 'begin-RankingController-user_action')
      RankingController.user_action(feed_hash['u_id'], type)
      Log.debug(self, {:user_id => feed_hash['u_id'], :action_type => type}, 'end-RankingController-user_action')
      BookActivity.setBookActivity(feed_hash['b_id'], feed_hash['f_time'].to_i)
      if type == 'review'
        review = Review.find(feed_hash['b_id'], feed_hash['r_id'])
        review_detail = review.hgetReview
        if review_detail[1] != ''
          ReviewActivity.setReviewActivity(feed_hash['b_id'], feed_hash['r_id'], feed_hash['f_time'].to_i)
        end
      end
      book = BooknewsfeedController.new
      book.setBookNewsfeed feed_hash
      display = DisplaynewsfeedController.new
      display.setDisplayNewsfeed feed_hash
    elsif type == 'follow'
      display = DisplaynewsfeedController.new
      display.copyFeedsFromFollower feed_hash
    else type == 'unfollow'
      display = DisplaynewsfeedController.new
      display.removeFeedsFromFollower feed_hash
    end
    own = OwnnewsfeedController.new
    own.setOwnNewsfeed feed_hash
    Log.debug(self, hash, 'end')
  end
   
  def create
    Log.debug(self, params, 'begin')
    params_feed = ActiveSupport::JSON.decode(params[:feed])
    feed = Feed.new
    hash_args = CommonMethods.makeArgs(params_feed, *Feed.fields)
    feed_hash = feed.hmset(*hash_args)
    respond_to do |format|
      if feed.save
        format.json { render :json => feed_hash }
      end
    end
    Log.debug(self, params, 'end')
  end

  private
    def set_feed
      f_id = params[:f_id]
      feed = Feed.find(f_id)
      @feed = feed.hgetall
    end
end
