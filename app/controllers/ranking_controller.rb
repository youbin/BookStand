class RankingController < ApplicationController
  require 'json'
  protect_from_forgery :only => [:user_activity_ranking]

  def all_rankings
    user_activity_rankings = UserActivityRanking.all_user_activity_ranking_datas(true)
    render json: user_activity_rankings, status: :ok
  end

  def self.user_action(user_id = nil, action_type = nil)
    Log.debug(self, {:user_id => user_id, :action_type => action_type}.to_s, 'begin')
    # ToDo - set score by type. not set to be '1' as default
    score = 1
    if (action_type == 'enroll' or action_type == 'review' or action_type == 'comment')
      score = 1
    end

    # update user ranking with score and timestamp
    user_activity_ranking = UserActivityRanking.new(user_id)
    user_activity_ranking.add_score_with_timestamp(score, Time.now)
 
    Log.debug(self, user_activity_ranking.to_s, 'end')
    return user_activity_ranking
  end

  def user_activity_ranking
    # get parameters & set parameters for UserActivityRanking Model
    # start = (params[:from_rank_number] == nil ? 0 : params[:from_rank_number].to_i)
    start = 0
    number_of_users = (params[:number_of_users] == nil ? 10 : params[:number_of_users].to_i)
    current_user_list = params[:current_user_list]
    current_user_list = (current_user_list == nil ? nil : eval(current_user_list))
    if (number_of_users.to_i <= 0)
      number_of_users = 10
    end
    stop = start + number_of_users - 1

    ranked_user_list = UserActivityRanking.ranked_user_list(start, stop, true)

    user_list_to_find = (current_user_list == nil ? ranked_user_list : ranked_user_list - current_user_list)

    user_data_list = User.find(user_list_to_find)

    user_data_hash = Hash.new

    user_data_list.each do |user_data|
      user_data_hash[user_data[:_id].to_s] = {:u_nickName => user_data[:u_nickName], :u_picture => user_data[:u_picture]}
    end

    # user_data_list = user_data_list.map {|row| {:id => row[:_id].to_s, :u_nickName => row[:u_nickName], :u_picture => row[:u_picture] }}

    ranked_user_hash = { :ranked_user_list => ranked_user_list, :users => user_data_hash, :current => current_user_list }

    render json: ranked_user_hash, status: :ok
  end

  def update_ranking_data_until_now
    update_status =  UserActivityRanking.update_ranking_data_until_now

    render json: update_status, status: :ok
  end

end
