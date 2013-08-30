class DisplaynewsfeedController < ApplicationController
  before_action	:set_feed, only: [:show, :get]
  protect_from_forgery :only => [:setDisplayNewsfeed]

  def index
    @feeds = DisplayNewsfeed.all
  end

  def show
  end

  def copyFeedsFromFollower hash
    Log.debug(self, hash, 'begin')
    u_id = hash['u_id']
    fr_id = hash['fr_id']
    own = OwnnewsfeedController.new
    u_feed = own.getOwnNewsfeed u_id
    display = DisplayNewsfeed.find fr_id
    display.sadd(u_feed)
    Log.debug(self, hash, 'end')
  end

  def removeFeedsFromFollower hash
    Log.debug(self, hash, 'begin')
    u_id = hash['u_id']
    fr_id = hash['fr_id']
    own = OwnnewsfeedController.new
    u_feed = own.getOwnNewsfeed u_id
    display = DisplayNewsfeed.find fr_id
    display.srem(u_feed)
    Log.debug(self, hash, 'end')
  end

  def setDisplayNewsfeed hash
    Log.debug(self, hash, 'begin')
    followers = UserDetail.find(hash['u_id']).u_followers
    fr_id = hash['fr_id']
    f_id = hash['f_id']

    followers.each do |follower|
      if follower != fr_id
        display = DisplayNewsfeed.find follower
        display.sadd(f_id)
      end
    end
    Log.debug(self, hash, 'end')
  end

  def get
    feeds = @feed["feeds"]
    feedController = FeedController.new
    reviewController = ReviewController.new
    commentController = CommentController.new
    userController = UsersController.new
    feed_array = feedController.getFeeds *feeds
    return_array = Array.new
    feed_array.each do |feed_hash|
      type = feed_hash["type"]
      if (type == 'comment' or type == 'enroll' or type == 'review')
        hash = Hash.new
        hash["type"] = type
        user = Hash.new
        user_info = userController.userview2 feed_hash['u_id']
        user["id"] = feed_hash['u_id']
        user["thumb"] = user_info['u_picture']
        user["nickname"] = user_info['u_nickName']
        hash["user"] = user
        book = Hash.new
        book["id"] = feed_hash["b_id"]
        book["name"] = "book_name"
        book["thumb"] = "book_thumb_image.png"
        book["category"] = "book category > category"
        book["author"] = "authur_name"
        book["translator"] = "translator name"
        book["publisher"] = "publisher"
        book["publishDate"] = Time.now
        book["starPoint"] = 3.5
        book["likeCount"] = 10
        book["reviewCount"] = 10
        hash["book"] = book
        if (type == 'review' or type == 'comment')
          review = Hash.new
          review["id"] = feed_hash["r_id"]
          review_array = reviewController.getReview feed_hash["b_id"], feed_hash["r_id"]
          review["review"] = review_array[1]
          review["time"] = review_array[2]
          hash["review"] = review
          review_user = Hash.new
          #review_user_info = userController.userview2 review_array[0]
          review_user_info = userController.userview2 feed_hash['u_id']
          review_user["id"] = review_array[0]
          review_user["thumb"] = review_user_info['u_picture']
          review_user["nickname"] = review_user_info['u_nickName']
          hash["review_user"] = review_user
        end
        if (type == 'comment')
          comment = Hash.new
          comment["id"] = feed_hash["cm_id"]
          comment_array = commentController.getComment feed_hash["b_id"], feed_hash["r_id"], feed_hash["cm_id"]
          comment["comment"] = comment_array[1]
          comment["time"] = comment_array[2]
          hash["comment"] = comment
          comment_user = Hash.new
          comment_user_info = userController.userview2 comment_array[0]
          comment_user["id"] = comment_array[0]
          comment_user["thumb"] = comment_user_info['u_picture']
          comment_user["nickname"] = comment_user_info['u_nickName']
          hash["comment_user"] = comment_user
        end
        return_array << hash
      end
    end 
p return_array
    respond_to do |format|
      format.json { render :json => return_array }
    end
  end

  private
    def set_feed
      u_id = params[:id]
      display = DisplayNewsfeed.find(u_id)
      @feed = display.smembers
    end
end
