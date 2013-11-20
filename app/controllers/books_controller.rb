class BooksController < ApplicationController
  before_action :set_book, only: [:show, :edit, :update, :destroy]
  protect_from_forgery :only => [:create, :update, :destroy]

  # GET /books
  # GET /books.json
  def index
    @books = Book.all
    @book_details = BookDetail.all
    @book_reviews = BookReview.all
  end

  # GET /books/1
  # GET /books/1.json
  def show
    
  end

  def attach_book_with_nickName
    isbn = params[:isbn]
    category_index = params[:category_index].to_i
    u_nickName = params[:u_nickName]
    user = User.where(:u_nickName => u_nickName)
    if (user.empty?)
      render json: nil
      return
    end
    user = user[0]
    bookshelf = BookShelf.find(user._id)
    u_categories = bookshelf.u_categories
    category_id = u_categories[category_index]

    book = Book.where(:b_id => isbn)
    if (book.empty?)
      book = Book.new
      book[:b_id] = isbn
      get_data_path = '/root/workspace/project/lib/assets/book_add.py ' + isbn + " " + category_id + " " + book._id + " " + user._id
      output = IO.popen('python ' + get_data_path)
      Kernel.sleep(3.0)
      render json: book
    else
      book = book.first
      book_id = book._id
      category = CategoriesController.new
      category.add_book book_id, category_id, user._id.to_s
      book_enroll_hash = Hash.new
      book_enroll_hash['f_time'] = Time.now
      book_enroll_hash['b_id'] = book_id
      book_enroll_hash['u_id'] = user._id.to_s
      book_enroll_hash['type'] = 'enroll'
      feedController = FeedController.new
      feedController.createFeedWithHash book_enroll_hash
      render json: book
    end
  end

  def attach_book
    isbn = params[:isbn]
    category_id = params[:category_id]
 
    book = Book.where(:b_id => isbn)
    if book.empty?
      book = Book.new
      book[:b_id] = isbn
      get_data_path = '/root/workspace/project/lib/assets/book_add.py ' + isbn + " " + category_id + " " + book._id + " " + params[:u_id]
      output = IO.popen('python ' + get_data_path)
<<<<<<< HEAD
      Kernel.sleep(3.0)
=======
#      Kernel.sleep(3.0)
>>>>>>> 1ec8f89e33a3598b237a6e479a97bb677aa49db6
      render json: book
    else
      book = book.first
      book_id = book._id
      category = CategoriesController.new
      category.add_book book_id, category_id, params[:u_id]
      book_enroll_hash = Hash.new
      book_enroll_hash['f_time'] = Time.now
      book_enroll_hash['b_id'] = book_id
      book_enroll_hash['u_id'] = params[:u_id]
      book_enroll_hash['type'] = 'enroll'
      feedController = FeedController.new
      feedController.createFeedWithHash book_enroll_hash
      render json: book
    end
  end

  # GET /books/new
  def new
    @book = Book.new
    @book_detail = BookDetail.new
    @book_review = BookReview.new
  end

  # GET /books/1/edit
  def edit
  end

  # POST /books
  # POST /books.json
  def create
    @book = Book.new(:_id => params[:_id],:b_id => params[:isbn].to_s, :b_title => params[:title], :b_thumb => 0, :b_totalStar => 0, :b_starNum => 0, :b_likeCount => 0, :b_belongCount => 0)
    @book.b_count = 0
    @book.b_likeCount = 0
    book_id = @book._id
    user_id = params[:user_id]
    category_id = params[:category_id]

    @book_detail = BookDetail.new(:b_category => 0, :b_author => params[:author], :b_translator => params[:translator], :b_publisher => params[:publisher])

    @book_review = BookReview.new(:b_reviews => Array.new)

    @book_detail._id = book_id
    @book_review._id = book_id

    @book_detail.b_id = @book.b_id
    @book_detail.b_title = @book.b_title
    @book_review.b_id = @book.b_id



    if @book.save && @book_detail.save && @book_review.save
      category = CategoriesController.new
      category.add_book book_id, category_id, user_id
      book_enroll_hash = Hash.new
      book_enroll_hash['f_time'] = Time.now
      book_enroll_hash['b_id'] = @book._id
      book_enroll_hash['u_id'] = user_id
      book_enroll_hash['type'] = 'enroll'
      feedController = FeedController.new
      feedController.createFeedWithHash book_enroll_hash
      render json: {"book" => @book, "book_detail" => @book_detail, "book_review" => @book_review}, status: :created
    else
      render status :bad_request
    end
  end

  def detail
    book_id = params[:id]
    @book = Book.find(book_id)
    @book_detail = BookDetail.find(book_id)
    @book_detail[:b_totalStar] = @book.b_totalStar
    @book_detail[:b_starNum] = @book.b_starNum
    @book_detail[:b_likeCount] = @book.b_likeCount
    @book_detail[:b_belongCount] = @book.b_belongCount

    #reviews = BookReview.find(params[:isbn]).b_reviews
    #@book_review = Review.find()
    #@book_review = reviews
    render json: @book_detail, status: :accepted
  end


  # REVIEW
  # REVIEW
  def review book_id, review_id
   # book_id = params[:id]
   # review_id = params[:review_id]

    @review = BookReview.find(book_id)
    bookreview = @review.b_reviews
    new_bookreview = bookreview.push(review_id)

    @review.update(:b_reviews => new_bookreview)

    #if @review.update(:b_reviews => new_bookreview)
    #  render json: @review, status: :accepted
    #else
    #  render status: :bad_request
    #end
  end

  # UNREVIEW
  # UNREVIEW
  def unreview
    book_id = params[:id]
    unreview_id = params[:unreview_id]

    @review = BookReview.find(book_id)
    bookreview = @review.b_reviews
    bookreview.delete(unreview_id)

    if @review.update(:b_reviews => bookreview)
      render json: @review, status: :accepted
    else
      render status: :bad_request
    end    
  end


  # PATCH/PUT /books/1
  # PATCH/PUT /books/1.json
  def update
    respond_to do |format|
      if @book.update(book_params)
        format.html { redirect_to @book, notice: 'Book was successfully updated.' }
        format.json { head :no_content }
      else
        format.html { render action: 'edit' }
        format.json { render json: @book.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /books/1
  # DELETE /books/1.json
  def destroy
    @book.destroy && @book_detail.destroy && @book_review.destroy
    respond_to do |format|
      format.html { redirect_to }
      format.json { head :no_content }
    end
  end

  # Calculate TotalStar /books/
  # Calculate TotalStar /books/
  def starNum
    book_id = params[:id]
    book_score = params[:score]
    
    @book = Book.find(book_id)
    @book.b_starNum = book_score
    count = @book.b_count.to_f
    @average = ((count*@book.b_totalStar.to_f)+book_score.to_f)/(count+1)
    count = count+1
    @book.b_count = count
    @book.b_totalStar = @average.to_i
    
    if @book.update(:b_totalStar => @average, :b_count => count)
      render json: @book, status: :accepted
    else
      render status: :bad_request
    end
  end


  def average_star book_id, book_score, book_new_score
    
    @book = Book.find(book_id)
    if @book.b_count == nil
      count = 0
    else
      count = @book.b_count.to_f
    end
    @average = @book.b_totalStar
    if book_score == -1
      total = @average * count
      count = count + 1
      @average = (total + book_new_score)/count
    else
      total = @average * count
      @average = (total - book_score + book_new_score)/count
    end
    @book.update(:b_totalStar => @average, :b_count => count)
  end


  # likeCount / books/:id/likecount
  def likeCount
    book_id = params[:id]
    
    @book = Book.find(book_id)
    likecount = @book.b_likeCount
    if likecount == 0
      likecount = likecount + 1
    else
    end
    
    if @book.update(:b_likeCount => likecount)
      render json: @book, status: :accepted
    else
      render status: :bad_request
    end
  end

  # unlikeCount /books/:id/unlikecount
  def unlikeCount
    book_id = params[:id]

    @book = Book.find(book_id)
    unlikecount = @book.b_likeCount
    unlikecount = unlikecount - 1

    if @book.update(:b_likeCount => unlikecount)
      render json: @book, status: :accepted
    else
      render status: :bad_request
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_book
      @book = Book.find(params[:id])
      @book_detail = Book.find(params[:id])
      @book_review = Book.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
      def book_params
      params.require(:book).permit(:b_id, :b_title, :b_thumb, :b_totalStar, :b_starNum, :b_belongCount)
    end
   def book_detail_params
      params.require(:book_detail).permit(:b_category, :b_author, :b_translator, :b_publisher)
    end

    def book_review_params
      params.require(:book_review).permit(:b_reviews => Array.new)
    end
end
