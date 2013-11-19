class User
  include Mongoid::Document
  field :u_nickName, type: String  
  field :u_motd, type: String  
  field :u_picture, type: String  
  field :u_password, type: String
  field :u_facebook_id, type: String
end
