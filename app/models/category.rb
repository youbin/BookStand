class Category
  include Mongoid::Document
  field :c_name, type: String
  field :c_color, type: String
  field :c_bookCount, type: Integer
  field :c_mainThumb, type: Array
end
