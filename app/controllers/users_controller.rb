class UsersController < ApplicationController
  before_action :set_user, only: [:show, :edit, :update, :destroy]
  protect_from_forgery :only => [:create, :update, :destroy]  

  # GET /users
  # GET /users.json
  def index
    @users = User.all
#    render json: @users, status: :ok
  end

  # POST /users
  # POST /users.json
  def create
    userData = ActiveSupport::JSON.decode(params[:user])
    isUser = User.where(:u_nickName => userData["u_nickName"])
    if isUser == [] or userData["u_nickName"] === ""
      @user = User.new(userData)
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
    else
      render text: "exist"
    end
  end

  def facebook_user
    list = []
    User.where(:u_facebook_id.ne => nil).each do |i|
      list.push({:u_facebook_id =>i.u_facebook_id , :u_id => i._id.to_s})
    end
    render json: list
  end

  def regist
    user = User.find(params[:id])
    userdetail = UserDetail.find(params[:id])
    followings = userdetail.u_followings
    followers = userdetail.u_followers

    userwish = UserWish.find(params[:id])
    bookshelf = BookShelf.find(params[:id])
    categories = bookshelf.u_categories
    wish = []
    for i in userwish.u_books
      wish.push({"book" => Book.find(i), "bookdetail" => BookDetail.find(i)})
    end
    book = []
    for i in categories
      for j in CategoryDetail.find(i.to_s).c_books
        book.push({"book" => Book.find(j), "bookdetail" => BookDetail.find(j)})
      end
    end
        categorydatas = Category.find(categories)
        detaildatas = CategoryDetail.find(categories)
        return_array = Array.new
        for i in 0..detaildatas.length - 1
          if detaildatas[i].c_books.length >= 3
            thumblist = detaildatas[i].c_books[-3..-1]
            categorydatas[i].c_mainThumb = Book.find(thumblist);
          else 
            if detaildatas[i].c_books.length == 2
              thumblist = detaildatas[i].c_books[-2..-1]
              categorydatas[i].c_mainThumb = Book.find(thumblist);
            else
              if detaildatas[i].c_books.length == 1
                thumblist = detaildatas[i].c_books
                categorydatas[i].c_mainThumb = Book.find(thumblist);
              else
                categorydatas[i].c_mainThumb = []
              end
            end
          end
        end
    render json: { 
      "user" => {"user" => user, "followings" => User.find(followings), "followers" => User.find(followers)},
      "category" => categorydatas,
      "wish" => wish,
      "book" => book
    }
  end

  def sign_in
    if User.where(:u_nickName => params[:u_nickName]).empty?
      render text: "no user"
    else 
      if User.where(:u_nickName => params[:u_nickName], :u_password => params[:u_password]).empty?
        render text: "wrong password"
      else
        if params[:u_nickName] == "" or params[:u_password] == ""
          render text: "no user"
        else
          user = User.where(:u_nickName => params[:u_nickName], :u_password => params[:u_password]).first
          user_id = user._id
          userdetail = UserDetail.find(user_id)
          followings = userdetail.u_followings
          followers = userdetail.u_followers

          userwish = UserWish.find(user_id)
          bookshelf = BookShelf.find(user_id)
          categories = bookshelf.u_categories
          wish = []
          for i in userwish.u_books
            wish.push({"book" => Book.find(i), "bookdetail" => BookDetail.find(i)})
          end
          book = []
          for i in categories
            for j in CategoryDetail.find(i.to_s).c_books
              book.push({"book" => Book.find(j), "bookdetail" => BookDetail.find(j)})
            end
          end
          categorydatas = Category.find(categories)
          detaildatas = CategoryDetail.find(categories)
          return_array = Array.new
          for i in 0..detaildatas.length - 1
            if detaildatas[i].c_books.length >= 3
              thumblist = detaildatas[i].c_books[-3..-1]
              categorydatas[i].c_mainThumb = Book.find(thumblist);
            else 
              if detaildatas[i].c_books.length == 2
                thumblist = detaildatas[i].c_books[-2..-1]
                categorydatas[i].c_mainThumb = Book.find(thumblist);
              else
                if detaildatas[i].c_books.length == 1
                  thumblist = detaildatas[i].c_books
                  categorydatas[i].c_mainThumb = Book.find(thumblist);
                else
                  categorydatas[i].c_mainThumb = []
                end
              end
            end
          end
          render json: { 
            "user" => {"user" => user, "followings" => User.find(followings), "followers" => User.find(followers)},
            "category" => categorydatas,
            "wish" => wish,
            "book" => book
          }
        end
      end
    end
  end

  def facebook_login
    if User.where(:u_facebook_id => params[:facebook_id]).empty?
      render text: "not exist"
    else
      user = User.where(:u_facebook_id => params[:facebook_id]).first
      user_id = user._id
      userdetail = UserDetail.find(user_id)
      followings = userdetail.u_followings
      followers = userdetail.u_followers

      userwish = UserWish.find(user_id)
      bookshelf = BookShelf.find(user_id)
      categories = bookshelf.u_categories
      wish = []
      for i in userwish.u_books
        wish.push({"book" => Book.find(i), "bookdetail" => BookDetail.find(i)})
      end
      book = []
      for i in categories
        for j in CategoryDetail.find(i.to_s).c_books
          book.push({"book" => Book.find(j), "bookdetail" => BookDetail.find(j)})
        end
      end
      categorydatas = Category.find(categories)
      detaildatas = CategoryDetail.find(categories)
      return_array = Array.new
      for i in 0..detaildatas.length - 1
        if detaildatas[i].c_books.length >= 3
          thumblist = detaildatas[i].c_books[-3..-1]
          categorydatas[i].c_mainThumb = Book.find(thumblist);
        else 
          if detaildatas[i].c_books.length == 2
            thumblist = detaildatas[i].c_books[-2..-1]
            categorydatas[i].c_mainThumb = Book.find(thumblist);
          else
            if detaildatas[i].c_books.length == 1
              thumblist = detaildatas[i].c_books
              categorydatas[i].c_mainThumb = Book.find(thumblist);
            else
              categorydatas[i].c_mainThumb = []
            end
          end
        end
      end
      render json: { 
        "user" => {"user" => user, "followings" => User.find(followings), "followers" => User.find(followers)},
        "category" => categorydatas,
        "wish" => wish,
        "book" => book
      }
    end
  end

  def get
    user = User.where(:u_nickName => params[:u_nickName])
    render json: user, status: :ok
  end

  def follow
    user_id = params[:id]
    add_id = params[:user_id]

    @detail = UserDetail.find(user_id)
    followings = @detail.u_followings
    if !followings.include?(add_id)
      new_followings = followings.push(add_id)
    else
      new_followings = followings
    end

    @following = User.find(add_id)

    @following_detail = UserDetail.find(add_id)
    followers = @following_detail.u_followers
    if !followers.include?(user_id)
      new_followers = followers.push(user_id)
    else
      new_followers = followers
    end

    if @detail.update(:u_followings => new_followings) && @following_detail.update(:u_followers => new_followers)
      hash = CommonMethods.makeHash('type', 'follow', 'u_id', user_id, 'fr_id', add_id, 'f_time', Time.now)
      feed = FeedController.new
      feed.createFeedWithHash hash
      render json: {"detail" => @detail, "f_user" => @following, "f_detail" => @following_detail}, status: :accepted
    else
      render status: :bad_request
    end
  end

  def unfollow
    user_id = params[:id]
    remove_id = params[:user_id]

    @detail = UserDetail.find(user_id)
    followings = @detail.u_followings
    followings.delete(remove_id)

    @following = User.find(remove_id)

    @following_detail = UserDetail.find(remove_id)
    followers = @following_detail.u_followers
    followers.delete(user_id)
    if @detail.update(:u_followings => followings) && @following_detail.update(:u_followers => followers)
      hash = CommonMethods.makeHash('type', 'unfollow', 'u_id', user_id, 'fr_id', remove_id, 'f_time', Time.now)
      feed = FeedController.new
      feed.createFeedWithHash hash
      render json: {"detail" => @detail, "f_user" => @following, "f_detail" => @following_detail}, status: :accepted
    else
      render status: :bad_request
    end
  end

  def wish
    user_id = params[:id]
    wish_id = params[:wish_id]

    @wish = UserWish.find(user_id)
    wishlist = @wish.u_books
    if !wishlist.include?(wish_id)
      new_wishlist = wishlist.push(wish_id)
    else
      new_wishlist = wishlist
    end
    @wish[:b_id] = wish_id

    @book = Book.find(wish_id)
    wishes = @book.b_wishes
    if wishes == nil
      wishes = []
    end
    if !wishes.include?(user_id)
      wishes = wishes.push(user_id)
    end
    wish_count = wishes.length

    if @wish.update(:u_books => new_wishlist) && @book.update(:b_wishes => wishes, :b_likeCount => wish_count)
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

    @wish[:b_id] = wish_id

    @book = Book.find(wish_id)
    wishes = @book.b_wishes
    wishes.delete(user_id)
    wish_count = wishes.length

    if @wish.update(:u_books => wishlist) && @book.update(:b_wishes => wishes, :b_likeCount => wish_count)
      render json: @wish, status: :accepted
    else
      render status: :bad_request
    end
  end

  def add_category
    user_id = params[:id]
    category_id = params[:category_id]

    @category = BookShelf.find(user_id)
    bookshelf = @category.u_categories
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
    bookshelf = @category.u_categories
    bookshelf.delete(category_id)

    if @category.update(:u_categories => bookshelf)
      render json: @category, status: :accepted
    else
      render status: :bad_request
    end
  end
  

  def bookshelf
    categories = BookShelf.find(params[:id]).u_categories
    categorydatas = Category.find(categories)
    detaildatas = CategoryDetail.find(categories)
    return_array = Array.new
    for i in 0..detaildatas.length - 1
      if detaildatas[i].c_books.length >= 3
        thumblist = detaildatas[i].c_books[-3..-1]
        categorydatas[i].c_mainThumb = Book.find(thumblist);
      else 
        if detaildatas[i].c_books.length == 2
          thumblist = detaildatas[i].c_books[-2..-1]
          categorydatas[i].c_mainThumb = Book.find(thumblist);
        else
          if detaildatas[i].c_books.length == 1
            thumblist = detaildatas[i].c_books
            categorydatas[i].c_mainThumb = Book.find(thumblist);
          else
            categorydatas[i].c_mainThumb = []
          end
        end
      end
    end
    render json: categorydatas
  end

  def userview
    user = User.find(params[:id])
    userdetail = UserDetail.find(params[:id])
    if userdetail[:u_visitor] == nil
      u_visitor = params[:visit].to_i
    else
      u_visitor = userdetail[:u_visitor] + params[:visit].to_i
    end
    userdetail[:u_visitor] = u_visitor
    if userdetail.save
      user[:visitor] = u_visitor
      user[:followings] = userdetail.u_followings.length
      user[:followers] = userdetail.u_followers.length
      render json: user
    end
  end

  def userview2 id
    return User.find(id.to_s)
  end

  def subview
    userdata = User.find(params[:id])
    userdetail = UserDetail.find(params[:id])
    render json: {"_id" => userdata._id, "nickname" => userdata.u_nickName, "facebook_id" => userdata.u_facebook_id, "followers" => userdetail.u_followers.length, "followings" => userdetail.u_followings.length, "following" => userdetail.u_followings, "visitor" => userdetail.u_visitor }
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
    render json: {"followers" => @follower, "followings" => @following}
  end

  # PATCH/PUT /users/1
  # PATCH/PUT /users/1.json
  def edit
    @user = User.find(params[:id])
    @update_user = ActiveSupport::JSON.decode(params[:user])
    Log.debug(self, {'user' => @user, 'update_user' => @update_user}, 'begin')
    if @user[:u_nickName] == @update_user[:u_nickName] or User.where(:u_nickName => @update_user[:u_nickName]).empty?
      if params[:thumbnail].to_s === params[:thumbnail]
        path = File.join("/root/workspace/project/public/images/user/", params[:id] + ".png")
        File.open(path, "wb") {
          |f| f.write(params[:thumbnail]) 
        }
        @update_user[:u_picture] = params[:id]
      else
        if params[:thumbnail]
          path = File.join("/root/workspace/project/public/images/user/", params[:id] + ".png")
          File.open(path, "wb") {
            |f| f.write(params[:thumbnail].read) 
          }
          @update_user[:u_picture] = params[:id]
        else
          @update_user[:u_picture] = @user[:u_picture]
        end
      end
      if @user.update(@update_user)
        render json: @user, status: :accepted
      else
        render status: :bad_reequest
      end
    else
      render text: "exist"
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
