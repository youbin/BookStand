class UsersController < ApplicationController
  before_action :set_user, only: [:show, :edit, :update, :destroy]
  protect_from_forgery :only => [:create, :update, :destroy]  

  # GET /users
  # GET /users.json
  def index
    @users = User.all
  end

  # POST /users
  # POST /users.json
  def create
    @user = User.new(ActiveSupport::JSON.decode(params[:user]))
    @user_wish = UserWish.new(:u_books => Array.new)
    @user_detail = UserDetail.new(:u_followers => Array.new, :u_followings => Array.new, :u_visitor => 0)
    @bookshelf = BookShelf.new(:u_categories => Array.new)
    user_id = @user._id
    @user_wish._id = user_id
    @user_detail._id = user_id
    @bookshelf._id = user_id

    if @user.save && @user_wish.save && @user_detail.save && @bookshelf.save
      render json: {"user" => @user, "user_wish" => @user_wish, "user_detail" => @user_detail, "bookshelf" => @bookshelf}, status: :created
    else
      render status: :bad_request
    end
  end

  def follow
    user_id = params[:id]
    add_id = params[:user_id]

    @detail = UserDetail.find(user_id)
    followers = @detail.u_followers
    new_followers = followers.push(add_id)

    @follower_detail = UserDetail.find(add_id)
    followings = @follower_detail.u_followings
    new_followings = followings.push(user_id)

    if @detail.update(:u_followers => new_followers) && @follower_detail.update(:u_followings => new_followings)
      hash = CommonMethods.makeHash('type', 'follow', 'u_id', user_id, 'fr_id', add_id, 'f_time', Time.now)
      feed = FeedController.new
      feed.createFeedWithHash hash
      render json: {"detail" => @detail, "f_detail" => @follower_detail}, status: :accepted
    else
      render status: :bad_request
    end
  end

  def unfollow
    user_id = params[:id]
    remove_id = params[:user_id]

    @detail = UserDetail.find(user_id)
    followers = @detail.u_followers
    followers.delete(@remove_id)

    @follower_detail = UserDetail.find(remove_id)
    followings = @follower_detail.u_followings
    followings.delete(user_id)

    if @detail.update(:u_followers => followers) && @follower_detail.update(:u_followings => followings)
      hash = CommonMethods.makeHash('type', 'unfollow', 'u_id', user_id, 'fr_id', remove_id, 'f_time', Time.now)
      feed = FeedController.new
      feed.createFeedWithHash hash
      render json: {"detail" => @detail, "f_detail" => @follower_detail}, status: :accepted
    else
      render status: :bad_request
    end
  end

  def wish
    user_id = params[:id]
    wish_id = params[:wish_id]

    @wish = UserWish.find(user_id)
    wishlist = @wish.u_books
    new_wishlist = wishlist.push(wish_id)

    if @wish.update(:u_books => new_wishlist)
      render json: @wish, status: :accepted
    else
      render status: :bad_request
    end
  end
  
  def unwish
    user_id = params[:id]
    wish_id = params[:wish_id]

    @wish = UserWish.find(user_id)
    wishlist = @wish.u_books
    wishlist.delete(wish_id)

    if @wish.update(:u_books => wishlist)
      render json: @wish, status: :accepted
    else
      render status: :bad_request
    end
  end

  def add_category
    user_id = params[:id]
    category_id = params[:category_id]

    @category = BookShelf.find(user_id)
    bookshelf = @category.u_books
    new_bookshelf = bookshelf.push(category_id)

    if @category.update(:u_categories => new_bookshelf)
      render json: @category, status: :accepted
    else
      render status: :bad_request
    end
  end

  def remove_category
    user_id = params[:id]
    category_id = params[:category_id]

    @category = BookShelf.find(user_id)
    bookshelf = @category.u_books
    bookshelf.delete(category_id)

    if @category.update(:u_categories => bookshelf)
      render json: @category, status: :accepted
    else
      render status: :bad_request
    end
  end
  

  def bookshelf
    categories = BookShelf.find(params[:id]).u_categories
    render json: Category.find(categories)
  end

  def userview
    render json: User.find(params[:id])
  end

  def userview2 id
    return User.find(id)
  end

  def subview
    render json: UserDetail.find(params[:id])
  end

  def wishview
    books = UserWish.find(params[:id]).u_books
    render json: BookDetail.find(books)
  end

  def follow_list
    followers = UserDetail.find(params[:id]).u_followers
    followings = UserDetail.find(params[:id]).u_followings
    @follower = User.find(followers)
    @following = User.find(followings)
    render json: {"first" => followers, "second" => followings, "followers" => @follower, "followings" => @following}
  end

  # PATCH/PUT /users/1
  # PATCH/PUT /users/1.json
  def update
    @user = User.find(params[:id])
    @update_user = ActiveSupport::JSON.decode(params[:user])
    if @user.update(@update_user)
      render json: @user, status: :accepted
    else
      render status: :bad_reequest
    end
  end

  # DELETE /users/1
  # DELETE /users/1.json
  def destroy
    @user.destroy
    respond_to do |format|
      format.html { redirect_to users_url }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_user
      @user = User.find(params[:id])
    end
end
