class UserDetail
  include Mongoid::Document
  field :u_visitor, type: Integer
  field :u_followings, type: Array
  field :u_followers, type: Array

end
