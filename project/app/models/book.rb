class Book
  require 'autoinc'
  include Mongoid::Document
  include Mongoid::Autoinc

  field :b_id, type: Integer
  field :b_title, type: String
  field :b_thumb, type: String
  field :b_totalStar, type: Float
  field :b_starNum, type: Integer
  field :b_likeCount, type: Integer
  field :b_belongCount, type: Integer
  field :b_count, type: Integer
  
has_many :BookDetail
  has_many :BookReview
end
