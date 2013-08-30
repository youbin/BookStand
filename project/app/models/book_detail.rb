class BookDetail
  require 'autoinc'
  include Mongoid::Document
  include Mongoid::Autoinc

  field :b_id, type: Integer
  field :b_title, type:String
  field :b_category, type: String
  field :b_author, type: String
  field :b_translator, type: String
  field :b_publisher, type: String
  field :b_publishDate, type: DateTime
  field :b_date, type: Date

  belongs_to :Book
end
