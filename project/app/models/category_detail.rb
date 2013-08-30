class CategoryDetail
  include Mongoid::Document
  field :c_books, type: Array
end
