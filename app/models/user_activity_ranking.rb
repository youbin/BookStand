class UserActivityRanking < CommonMethods
  include Redis::Objects
  attr_reader :user_id_key
  sorted_set :feed_score
  sorted_set :last_activity_time
  sorted_set :last_activity_time_as_ymd
  value :feed_score_for_user

  def self.feed_score_sorted_set_key
    return "user_activity_ranking:feed_score"
  end

  def self.last_activity_time_sorted_set_key
    return "user_activity_ranking:last_activity_time"
  end

  def self.last_activity_time_as_ymd_sorted_set_key
    return "user_activity_ranking:last_activity_time:ymd"
  end

  def initialize(user_id_key = nil)
    @user_id_key = user_id_key
    @feed_score = Redis::SortedSet.new(UserActivityRanking.feed_score_sorted_set_key)
    @feed_score_for_user = Redis::Value.new(UserActivityRanking.feed_score_sorted_set_key + ":#{@user_id_key}")
    @last_activity_time = Redis::SortedSet.new(UserActivityRanking.last_activity_time_sorted_set_key)
    @last_activity_time_as_ymd = Redis::SortedSet.new(UserActivityRanking.last_activity_time_as_ymd_sorted_set_key)
  end

  # set score and timestamp for user_id
  def add_score_with_timestamp(feed_score, last_activity_timestamp)
    if (@feed_score_for_user == nil)
      @feed_score_for_user.value = feed_score
    else
      @feed_score_for_user.value = feed_score + @feed_score_for_user.value.to_i
    end
    @feed_score[@user_id_key] = @feed_score_for_user.value
    @last_activity_time[@user_id_key] = last_activity_timestamp.to_i
    @last_activity_time_as_ymd[@user_id_key] = (last_activity_timestamp.to_date - Date.new(2013,1,1)).to_i
  end

  def timestamp_to_year_month_day(timestamp)
    super(timestamp)
  end

  def self.ranked_user_list(start, stop, withscores = false)
    ranked_user_list = ranked_user_list_with_score(start, stop, withscores)
    ranked_user_list = ranked_user_list.map { |hash| hash.keys[0] }
    return ranked_user_list
  end

  def self.ranked_user_list_with_score(start, stop, withscores = false)
    user_id_to_retrieve, user_members = user_id_array_from_rangebyscore_last_activity_time_as_ymd(start, stop, withscores)
    user_id_hash_keys, user_id_hash_by_score = user_id_hash_by_score_and_keys_for_user_id_array_to_retrieve(user_id_to_retrieve)
    feed_score_hash = feed_score_hash_for_user(user_members)

    user_id_hash_by_real_feed_score = combine_user_id_hash_by_score_with_feed_score_hash(user_id_hash_keys, user_id_hash_by_score, feed_score_hash)

    user_id_with_feed_score_array = convert_user_id_hash_by_score_to_user_id_with_feed_score_array(user_id_hash_keys, user_id_hash_by_real_feed_score)

    number_of_users_in_ranking = stop - start + 1

    return user_id_with_feed_score_array.first(number_of_users_in_ranking)
  end

  def self.convert_user_id_hash_by_score_to_user_id_with_feed_score_array(user_id_hash_keys, user_id_hash_by_score)
    user_id_with_feed_score_array = Array.new
    user_id_hash_keys.each { |ymd| user_id_with_feed_score_array = user_id_with_feed_score_array + user_id_hash_by_score[ymd] }

    return user_id_with_feed_score_array
  end

  def self.combine_user_id_hash_by_score_with_feed_score_hash(user_id_hash_keys, user_id_hash_by_score, feed_score_hash)
    user_id_hash_keys.each do |ymd|
      user_id_hash_by_score[ymd].each do |user_id_and_score|
        user_id_and_score[user_id_and_score.keys.last] = feed_score_hash[user_id_and_score.keys.last]
      end
      user_id_hash_by_score[ymd] = user_id_hash_by_score[ymd].sort_by { |hash| -hash.values[0].to_i }
    end

    return user_id_hash_by_score
  end

  def self.feed_score_hash_for_user(user_members)
    user_members_key = user_members.map {|user_id| feed_score_sorted_set_key + ":#{user_id}"}
    feed_score_array = $redis.mget(user_members_key)
    feed_score_hash = Hash.new
    user_members.each_with_index do |user_id, index|
      feed_score_hash[user_id] = feed_score_array[index]
    end
    return feed_score_hash
  end

  def self.user_id_hash_by_score_and_keys_for_user_id_array_to_retrieve(user_id_array_to_retrieve)
    user_id_hash_keys = Array.new
    user_id_hash_by_score = Hash.new
    user_id_array_to_retrieve.each do |user_id_with_score|
      user_score = user_id_with_score[1]
      user_id = user_id_with_score[0]
      if (user_id_hash_by_score[user_score] == nil)
        user_id_hash_by_score[user_score] = Array.new
        user_id_hash_keys << user_score
      end
      user_id_hash_by_score[user_score] << {user_id => 0}
    end
    return user_id_hash_keys, user_id_hash_by_score
  end

  def self.user_id_array_from_rangebyscore_last_activity_time_as_ymd(start, stop, withscores = false)
    last_activity_time_as_ymd = Redis::SortedSet.new(last_activity_time_as_ymd_sorted_set_key)

    last_index_of_last_activity_time_as_ymd = last_activity_time_as_ymd.length - 1
    stop = (stop > last_index_of_last_activity_time_as_ymd ? last_index_of_last_activity_time_as_ymd : stop)
    start_day_difference = last_activity_time_as_ymd.revrange(stop, stop, :with_scores => true)[0][1].to_i
    stop_day_difference = last_activity_time_as_ymd.revrange(start, start, :with_scores => true)[0][1].to_i

    user_id_array_to_retrieve = last_activity_time_as_ymd.rangebyscore(start_day_difference, stop_day_difference, :with_scores => withscores).reverse
    user_id_array = user_id_array_to_retrieve.map {|user_id, user_score| user_id}
    return user_id_array_to_retrieve, user_id_array
  end

  def self.all_user_activity_ranking_datas(withscores = false)
    all_user_activity_ranking_datas = Hash.new

    user_id_to_retrieve, user_members = user_id_array_from_rangebyscore_last_activity_time_as_ymd(0, -1, withscores)
    user_id_hash_keys, user_id_hash_by_score = user_id_hash_by_score_and_keys_for_user_id_array_to_retrieve(user_id_to_retrieve)
    feed_score_hash = feed_score_hash_for_user(user_members)

    user_id_hash_by_real_feed_score = combine_user_id_hash_by_score_with_feed_score_hash(user_id_hash_keys, user_id_hash_by_score, feed_score_hash)
    all_user_activity_ranking_datas[:user_id_hash_by_feed_score] = user_id_hash_by_real_feed_score

    all_user_activity_ranking_datas[:data_structure] = {:day_difference_from_2013_1_1 => {:user_id => "feed_count"}}

    return all_user_activity_ranking_datas
  end

  def self.update_ranking_data_until_now
    user_activity_hash = retrieve_uesr_activities_as_hash
    last_activity_time_sorted_set = Redis::SortedSet.new(last_activity_time_sorted_set_key)
    last_activity_time_as_ymd_sorted_set = Redis::SortedSet.new(last_activity_time_as_ymd_sorted_set_key)
    feed_score_sorted_set = Redis::SortedSet.new(feed_score_sorted_set_key)
    last_activity_time_sorted_set.clear
    last_activity_time_as_ymd_sorted_set.clear
    feed_score_sorted_set.clear

    feed_score_keys = $redis.keys(feed_score_sorted_set_key + ":*")
    $redis.del(*feed_score_keys)

    user_activity_hash.each do |user_id, user_activity|
      if (user_activity[:last_activity_time] == nil)
        user_activity[:last_activity_time] = Time.new(2013,1,1)
      end
      if (user_activity[:feed_count] == nil)
        user_activity[:feed_count] = 0
      end
      last_activity_time = user_activity[:last_activity_time].to_s.to_time
      last_activity_date = user_activity[:last_activity_time].to_s.to_date
      last_activity_time_sorted_set[user_id] = last_activity_time.to_i
      last_activity_time_as_ymd_sorted_set[user_id] = (last_activity_date - Date.new(2013,1,1)).to_i
      feed_score_sorted_set[user_id] = user_activity[:feed_count]
      feed_score_for_user = Redis::Value.new(feed_score_sorted_set_key + ":#{user_id}")
      feed_score_for_user.value = user_activity[:feed_count]
    end

    return user_activity_hash
  end

  def self.retrieve_uesr_activities_as_hash
    own_newsfeed_prefix = "own_newsfeed"
    feed_prefix = "feed"
    user_own_newsfeed_keys = $redis.keys(own_newsfeed_prefix + ":*")
    user_id_array = Array.new
    user_own_newsfeed_keys.each do |user_own_newsfeed_key|
      user_id_array << user_own_newsfeed_key.sub(own_newsfeed_prefix + ":", "")
    end
    user_activity_hash = Hash.new

    user_own_newsfeed_keys.each_with_index do |user_own_newsfeed_key, index|
      feed_array_for_user = $redis.smembers(user_own_newsfeed_key)
      user_id = user_id_array[index]
      if (feed_array_for_user.length > 0)
        user_activity_hash[user_id] = Hash.new
      end
      feed_array_for_user.each do |feed_id|
        feed_for_user = $redis.hgetall(feed_prefix + ":" + feed_id.to_s)
        type_of_feed = feed_for_user['type']
        if (type_of_feed == 'enroll' or type_of_feed == 'review' or type_of_feed == 'comment')
          if (user_activity_hash[user_id][:feed_count] == nil)
            user_activity_hash[user_id][:feed_count] = 0
          end
          user_activity_hash[user_id][:feed_count] = user_activity_hash[user_id][:feed_count] + 1
          user_activity_hash[user_id][:last_activity_time] = feed_for_user['f_time']
        end
      end
    end

    return user_activity_hash
  end

end
