class UserWish
  include Mongoid::Document

  field :u_books, type: Array

end
