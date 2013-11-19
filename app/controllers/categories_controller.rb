class CategoriesController < ApplicationController
  protect_from_forgery :only => [:create, :update, :destroy]  

  def index
    @categories = Category.all
    render json: @categories, status: :created
  end

  def create
    category = Category.new(ActiveSupport::JSON.decode(params[:category]))
    category_detail = CategoryDetail.new(:c_books => Array.new)
    category_id = category._id
    category_detail._id = category_id
    
    if category.c_bookCount == nil
      category.c_bookCount = 0
    end

    user_category = BookShelf.find(params[:user_id])
    bookshelf = user_category.u_categories
    new_bookshelf = bookshelf.push(category_id.to_s)

    if category.save && category_detail.save && user_category.update(:u_categories => new_bookshelf)
      render json: {"category" => category, "category_detail" => category_detail, "user_category" => user_category}, status: :created
    else
      render status: :bad_request
    end
  end

  def add_book book_id, category_id, user_id

    @category = CategoryDetail.find(category_id)
    books = @category.c_books
    if !books.include?(book_id.to_s)
      new_books = books.push(book_id.to_s)
      @book = Book.find(book_id.to_s)
      
      belongs = @book.b_belongs
      belong_users = []
      if belongs == nil
        belongs = []
      end
      belong_data = user_id + ':' + category_id
      if !belongs.include?(belong_data)
        belongs = belongs.push(belong_data)
      end
      for i in belongs
        if !belong_users.include?(i.split(':')[0])
          belong_users.push(i.split(':')[0])
        end
      end
      belong_count = belong_users.length

      @category.update(:c_books => new_books)
      @book.update(:b_belongs => belongs, :b_belongCount => belong_count)
    end

#    if @category.update(:c_books => new_books)
#      hash = CommonMethods.makeHash('type', 'enroll', 'u_id', params[:u_id], 'b_id', book_id, 'f_time', Time.now)
#      feed = FeedController.new
#      feed.createFeedWithHash hash
#      render json: @category, status: :accepted
#    else
#      render status: :bad_request
#    end
  end

  def remove_book
    category_id = params[:category_id]
    book_id = params[:b_id]

    @category = CategoryDetail.find(category_id)
    books = @category.c_books
    books.delete(book_id)

    @category[:b_id] = book_id

    @book = Book.find(book_id)
    belongs = @book.b_belongs
    belong_users = []
    for i in belongs
      if i.split(':')[1] === category_id
        belongs.delete(i)
      else
        if !belong_users.include?(i.split(':')[0])
          belong_users.push(i.split(':')[0])
        end
      end
    end
    belong_count = belong_users.length
    
    if @category.update(:c_books => books) && @book.update(:b_belongs => belongs, :b_belongCount => belong_count)
      render json: @category, status: :accepted
    else
      render status: :bad_request
    end
  end

  def move_book
    category_id = params[:category_id]
    book_id = params[:b_id]
    
    new_category_id = params[:new_category_id]

    @category = CategoryDetail.find(category_id)
    books = @category.c_books
    books.delete(book_id)

    @new_category = CategoryDetail.find(new_category_id)
    new_books = @new_category.c_books
    if !books.include?(book_id)
      new_books = new_books.push(book_id)
    end

    if @category.update(:c_books => books) && @new_category.update(:c_books => new_books)
      render json: @category, status: :accepted
    else
      render status: :bad_request
    end
  end
  

  def booklist
    list = CategoryDetail.find(params[:id]).c_books
    @bookid = BookDetail.find(list)
    render json: @bookid, status: :accepted
  end

  # PATCH/PUT /users/1
  # PATCH/PUT /users/1.json
  def edit
    @category = Category.find(params[:id])
    @update_category = ActiveSupport::JSON.decode(params[:category])
    if @category.update(@update_category)
      render json: @category, status: :accepted
    else
      render status: :bad_reequest
    end
  end

  # DELETE /users/1
  # DELETE /users/1.json
  def destroy
    @category.destroy
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_category
      @category = User.find(params[:id])
    end
end
