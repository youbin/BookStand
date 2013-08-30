class BookReview
  require 'autoinc'
  include Mongoid::Document
  include Mongoid::Autoinc

  field :b_id, type: Integer
  field :b_reviews, type: Array

  belongs_to :Book
end
