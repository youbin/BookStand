Project::Application.routes.draw do

  get 'users/regist/:id' => 'users#regist'

  # users_controller
  # get function
  get "users" => 'users#index'
  get "users/facebook" => 'users#facebook_user'
  get "users/:id" => 'users#bookshelf'
  get "users/:id/user/:visit" => 'users#userview'
  get "users/:id/sub" => 'users#subview'
  get "users/:id/wish" => 'users#wishview'
  get "users/:id/follow" => 'users#follow_list'

  get "users/test" => 'users#test'

  get 'get_user/:u_nickName'	=> 'users#get'

  # post function
  post "users" => 'users#create'
  post "users/edit" => 'users#edit'
  post "users/follow" => 'users#follow'
  post "users/unfollow" => 'users#unfollow'
  post "users/wish" => 'users#wish'
  post "users/unwish" => 'users#unwish'
  post "users/cadd" => 'users#add_category'
  post "users/cremove" => 'users#remove_category'
  post 'users/sign_in'	=> 'users#sign_in'
  post 'users/facebook'	=> 'users#facebook_login'

  # categoires_controller
  # get function
  get "categories" => 'categories#index'
  get "categories/:id" => 'categories#booklist'

  # post function
  post "categories" => 'categories#create'
  post "categories/edit" => 'categories#edit'
  post "categories/add" => 'categories#add_book'
  post "categories/remove" => 'categories#remove_book'
  post "categories/move" => 'categories#move_book'

  # books_controller
  # get function
  get "books" => 'books#index'
  get "books/new" => 'books#new'
#  get "books/:id" => 'books#show'
  get "books/:id" => 'books#detail'
  get "books/:id/starNum/:score" => 'books#starNum'
  get "books/:id/review/:review_id" => 'books#review'
  get "books/:id/unreview/:unreview_id" => 'books#unreview'
  get "books/:id/likeCount/" => 'books#likeCount'
  get "books/:id/unlikeCount/" => 'books#unlikeCount' 

  get "books/attach_book/:u_id/:category_id/:isbn"	=> 'books#attach_book'
  get "books/attach_book_with_nickname/:u_nickName/:category_index/:isbn"	=> "books#attach_book_with_nickName"

  #post function
  post "books" => 'books#create'
  post "books/attach" => 'books#attach_book'
  post "books/edit" => 'books#edit'
  post "books/review" => 'books#review'
  post "books/average" => 'books#average_star'
  post "books/:id/unreview" => 'books#unreview'


  # comment_controller
  # get function
  get	'comment/:b_id/:r_id/:cm_id'			=> 'comment#get'
  get	'comment/show/:b_id/:r_id/:cm_id'		=> 'comment#show'
  get	'comment/:b_id/:r_id/'				=> 'comment#index'
  get	'comment/delete/:b_id/:r_id/:cm_id'		=> 'comment#delete'

  # post function
  post	"comment"					=> 'comment#create'

  # review_controller
  # get function
  get 'review/:b_id/:r_id'				=> 'review#get'
  get 'review/show/:b_id/:r_id'				=> 'review#show'
  get 'review/:b_id'					=> 'review#index'

  # post function
  post 'review'						=> 'review#create'
  post 'update_review'					=> 'review#update'

  # feed_controller
  # get function
  get 'feed/:f_id'					=> 'feed#get'
  get 'feed/show/:f_id'					=> 'feed#show'
  get 'feed'						=> 'feed#index'
  get 'recent_book'					=> 'feed#getRecentTopBookFeeds'
  get 'recent_review'					=> 'feed#getRecentTopReviewFeeds'

  # ownnewsfeed_controller
  # get function
  get 'ownnewsfeed/:id'					=> 'ownnewsfeed#get'
  get 'ownnewsfeed/show/:id'				=> 'ownnewsfeed#show'
  get 'ownnewsfeed'					=> 'ownnewsfeed#index'

  # booknewsfeed_controller
  # get function
  get 'booknewsfeed/:id'				=> 'booknewsfeed#get'
  get 'booknewsfeed/show/:id'				=> 'booknewsfeed#show'
  get 'booknewsfeed'					=> 'booknewsfeed#index'

  # displaynewsfeed_controller
  # get function
  get 'displaynewsfeed/:id/:last_f_id'			=> 'displaynewsfeed#get'
  get 'displaynewsfeed'					=> 'displaynewsfeed#index'
  get 'displaynewsfeed_more/:id/:last_f_id'		=> 'displaynewsfeed#more'
  get 'fake_displaynewsfeed'				=> 'displaynewsfeed#make_fake_feeds'

  # ranking_controller
  # get function
  get 'ranking/update'					=> 'ranking#update_ranking_data_until_now'
  get 'ranking/all_rankings'				=> 'ranking#all_rankings'
  get 'ranking/number_of_users/:number_of_users'	=> 'ranking#user_activity_ranking'

  # post function
  post 'ranking'					=> 'ranking#user_activity_ranking'


  # The priority is based upon order of creation: first created -> highest priority.
  # See how all your routes lay out with "rake routes".

  # You can have the root of your site routed with "root"
  # root 'welcome#index'

  # Example of regular route:
  #   get 'products/:id' => 'catalog#view'

  # Example of named route that can be invoked with purchase_url(id: product.id)
  #   get 'products/:id/purchase' => 'catalog#purchase', as: :purchase

  # Example resource route (maps HTTP verbs to controller actions automatically):
  #   resources :products

  # Example resource route with options:
  #   resources :products do
  #     member do
  #       get 'short'
  #       post 'toggle'
  #     end
  #
  #     collection do
  #       get 'sold'
  #     end
  #   end

  # Example resource route with sub-resources:
  #   resources :products do
  #     resources :comments, :sales
  #     resource :seller
  #   end

  # Example resource route with more complex sub-resources:
  #   resources :products do
  #     resources :comments
  #     resources :sales do
  #       get 'recent', on: :collection
  #     end
  #   end
  
  # Example resource route with concerns:
  #   concern :toggleable do
  #     post 'toggle'
  #   end
  #   resources :posts, concerns: :toggleable
  #   resources :photos, concerns: :toggleable

  # Example resource route within a namespace:
  #   namespace :admin do
  #     # Directs /admin/products/* to Admin::ProductsController
  #     # (app/controllers/admin/products_controller.rb)
  #     resources :products
  #   end
end
