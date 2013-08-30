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
