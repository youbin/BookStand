class OwnnewsfeedController < ApplicationController
  before_action	:set_feed, only: [:show, :get]
  protect_from_forgery :only => [:setOwnNewsfeed]

  def index
    @feeds = OwnNewsfeed.all
  end

  def show
  end

  def getOwnNewsfeed u_id
    Log.debug(self, u_id, 'begin')
    own = OwnNewsfeed.find u_id
    own_hash = own.smembers
    Log.debug(self, u_id, 'end')
    return own_hash['feeds']
  end

  def setOwnNewsfeed hash
    Log.debug(self, hash, 'begin')
    own = OwnNewsfeed.find hash["u_id"]
    own.sadd(hash["f_id"])
    Log.debug(self, hash, 'end')
  end

  def get
    respond_to do |format|
      format.json { render :json => @feed}
    end
  end

  private
    def set_feed
      u_id = params[:id]
      own = OwnNewsfeed.find(u_id)
      @feed = own.smembers
    end
end
