class BookShelf
  include Mongoid::Document
  field :u_categories, type: Array
end
