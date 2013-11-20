class BooknewsfeedController < ApplicationController
  before_action	:set_user, only: [:show, :get]
  protect_from_forgery :only => [:setOwnNewsfeed]

  def index
    @feeds = BookNewsfeed.all
  end

  def show
  end

  def setBookNewsfeed hash
    Log.debug(self, hash, 'begin')
    book = BookNewsfeed.find hash["b_id"]
    book.sadd(hash["f_id"])
    Log.debug(self, hash, 'end')
  end

  def get
    respond_to do |format|
      format.json { render :json => @feed}
    end
  end

  private
    def set_user
      b_id = params[:id]
      book = BookNewsfeed.find(b_id)
      @feed = book.smembers
    end
end
