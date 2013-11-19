class DisplaynewsfeedController < ApplicationController
  before_action	:set_saved_feed, only: [:get, :more]
  before_action :set_feed, only: [:get]
  before_action :set_saved_fake_feed, only: [:make_fake_feeds]
  protect_from_forgery :only => [:setDisplayNewsfeed]

  def index
    @feeds = DisplayNewsfeed.all
  end

  def copyFeedsFromFollower hash
    Log.debug(self, hash, 'begin')
    u_id = hash['u_id']
    fr_id = hash['fr_id']
    own = OwnnewsfeedController.new
    u_feed = own.getOwnNewsfeed fr_id
    display = DisplayNewsfeed.find u_id
    if u_feed.size > 0
      display.sadd(u_feed)
    end
    Log.debug(self, hash, 'end')
  end

  def removeFeedsFromFollower hash
    Log.debug(self, hash, 'begin')
    u_id = hash['u_id']
    fr_id = hash['fr_id']
    own = OwnnewsfeedController.new
    u_feed = own.getOwnNewsfeed fr_id
    display = DisplayNewsfeed.find u_id
    if u_feed.size > 0
      display.srem(u_feed)
    end
    Log.debug(self, hash, 'end')
  end

  def setDisplayNewsfeed hash
    Log.debug(self, hash, 'begin')
    followers = UserDetail.find(hash['u_id']).u_followers
    fr_id = hash['fr_id']
    f_id = hash['f_id']

    display = DisplayNewsfeed.find(hash['u_id'])
    display.sadd(f_id)

    followers.each do |follower|
      if follower != fr_id
        display = DisplayNewsfeed.find follower
        display.sadd(f_id)
      end
    end
    Log.debug(self, hash, 'end')
  end

  def sort_by_value feed_array
    feed_array.sort!{|t1, t2| t2.to_i <=> t1.to_i}
    return feed_array
  end

  def sort_by_feed_id feed_array
    feed_array.sort!{|t1, t2| t2['f_id'].to_i <=> t1['f_id'].to_i}
    return feed_array
  end

  def feed_index_hash_from_array feed_array
    result_feed_hash = Hash.new
    feed_array.each_with_index do |feed_hash, index|
      result_feed_hash[feed_hash['f_id']] = index
    end
    return result_feed_hash
  end

  def remove_invalid_feed feed_array
    new_feed_array = Array.new
    feed_array.each do |feed_hash|
      type = feed_hash['type']
      next if (User.where(:id => feed_hash['u_id']).exists? == false)
      if (type == 'enroll')
        new_feed_array << feed_hash
      elsif ((type == 'review' or type == 'comment') and Review.exists?(feed_hash['b_id'], feed_hash['r_id']))
        new_feed_array << feed_hash
      elsif (type == 'comment' and Comment.exists?(feed_hash['b_id'], feed_hash['r_id'], feed_hash['cm_id']))
        new_feed_array << feed_hash
      end
    end
    return new_feed_array
  end

  def classify_feeds_by_type feed_array
    new_feed_hash = Hash.new
    feed_array.each_with_index do |feed_hash, i|
      type = feed_hash['type']
      u_id = feed_hash['u_id']
      b_id = feed_hash['b_id']
      r_id = feed_hash['r_id']
      cm_id = feed_hash['cm_id']
      f_time = feed_hash['f_time']
      if (type == 'enroll')
        if (new_feed_hash['enroll'] == nil)
          new_feed_hash['enroll'] = Hash.new
        end
        if (new_feed_hash['enroll'][u_id] == nil)
          new_feed_hash['enroll'][u_id] = Array.new
        end
        new_feed_hash['enroll'][u_id] << feed_hash['f_id']
      elsif (type == 'review')
        if (new_feed_hash['review'] == nil)
          new_feed_hash['review'] = Hash.new
        end
        if (new_feed_hash['review'][b_id] == nil)
          new_feed_hash['review'][b_id] = Array.new
        end
        new_feed_hash['review'][b_id] << feed_hash['f_id']
      elsif (type == 'comment')
        if (new_feed_hash['comment'] == nil)
          new_feed_hash['comment'] = Hash.new
        end
        if (new_feed_hash['comment'][b_id] == nil)
          new_feed_hash['comment'][b_id] = Hash.new
        end
        if (new_feed_hash['comment'][b_id][r_id] == nil)
          new_feed_hash['comment'][b_id][r_id] = Array.new
        end
        new_feed_hash['comment'][b_id][r_id] << feed_hash['f_id']
      end
    end
    return new_feed_hash
  end

  def make_will_save_display_newsfeed feed_array, classified_feed_hash
    will_save_display_newsfeed = Array.new
    enroll_feed_hash = classified_feed_hash['enroll']
    review_feed_hash = classified_feed_hash['review']
    comment_feed_hash = classified_feed_hash['comment']
    if (enroll_feed_hash == nil)
      enroll_feed_hash = Array.new
    end
    if (review_feed_hash == nil) 
      review_feed_hash = Array.new
    end
    if (comment_feed_hash == nil) 
      comment_feed_hash = Array.new
    end
    enroll_feed_hash.each do |key, value|
      feed_set = Hash.new
      feed_set['f_id'] = value[0]
      feed_set['related_f_id'] = value.reverse!
      will_save_display_newsfeed << feed_set
    end
    review_feed_hash.each do |key, value|
      feed_set = Hash.new
      feed_set['f_id'] = value[0]
      feed_set['related_f_id'] = value.reverse!
      will_save_display_newsfeed << feed_set
    end
    comment_feed_hash.each do |key, value_for_comment|
      value_for_comment.each do |key, value|
        feed_set = Hash.new
        feed_set['f_id'] = value[0]
        feed_set['related_f_id'] = value.reverse!
        will_save_display_newsfeed << feed_set
      end
    end
    will_save_display_newsfeed = sort_by_feed_id(will_save_display_newsfeed)
    return will_save_display_newsfeed
  end

  def save_classified_feed classified_feed_hash, feed_array, feed_index_hash
    enroll_feed_hash = classified_feed_hash['enroll']
    review_feed_hash = classified_feed_hash['review']
    comment_feed_hash = classified_feed_hash['comment']
    if (enroll_feed_hash == nil)
      enroll_feed_hash = Array.new
    end
    if (review_feed_hash == nil) 
      review_feed_hash = Array.new
    end
    if (comment_feed_hash == nil) 
      comment_feed_hash = Array.new
    end
    enroll_feed_hash.each do |key, value|
      enroll_feed = ClassifiedEnrollFeed.find(@u_id, feed_array[feed_index_hash[value[0]]]['u_id'])
      zset = Array.new
      value.each do |f_id|
        index = feed_index_hash[f_id]
        element = Array.new
        element << feed_array[index]['f_time'].to_time.to_i
        element << feed_array[index]['f_id']
        zset << element
      end
      enroll_feed.zadd(zset)
    end
    review_feed_hash.each do |key, value|
      review_feed = ClassifiedReviewFeed.find(@u_id, feed_array[feed_index_hash[value[0]]]['b_id'])
      zset = Array.new
      value.each do |f_id|
        index = feed_index_hash[f_id]
        element = Array.new
        element << feed_array[index]['f_time'].to_time.to_i
        element << feed_array[index]['f_id']
        zset << element
      end
      review_feed.zadd(zset)
    end
    comment_feed_hash.each do |key, value_for_comment|
      value_for_comment.each do |key, value|
        comment_feed = ClassifiedCommentFeed.find(@u_id, feed_array[feed_index_hash[value[0]]]['b_id'], feed_array[feed_index_hash[value[0]]]['r_id'])
        zset = Array.new
        value.each do |f_id|
          index = feed_index_hash[f_id]
          element = Array.new
          element << feed_array[index]['f_time'].to_time.to_i
          element << feed_array[index]['f_id']
          zset << element
        end
        comment_feed.zadd(zset)
      end
    end
  end

  def retrieve_real_data_from_feed_array will_display_feed_array, feed_array, feed_index_hash
    display_newsfeed_hash = Hash.new
    display_newsfeed_hash['feeds'] = Array.new
    display_newsfeed_hash['users'] = Hash.new
    display_newsfeed_hash['books'] = Hash.new
    display_newsfeed_hash['reviews'] = Hash.new
    display_newsfeed_hash['comments'] = Hash.new
    will_display_feed_array.each do |f_id|
      index = feed_index_hash[f_id]
      feed_hash = feed_array[index]
      display_newsfeed_hash['feeds'] << feed_hash
      type = feed_hash['type']
      if (type == 'comment' or type == 'enroll' or type == 'review')
        if display_newsfeed_hash['users'][feed_hash['u_id']] == nil and User.where(:_id => feed_hash['u_id']).exists?
          display_newsfeed_hash['users'][feed_hash['u_id']] = User.find(feed_hash['u_id'])
        end

        if display_newsfeed_hash['books'][feed_hash['b_id']] == nil and Book.where(:_id => feed_hash['b_id']).exists?
          display_newsfeed_hash['books'][feed_hash['b_id']] = Book.find(feed_hash['b_id'])
          if (display_newsfeed_hash['books'][feed_hash['b_id']]['b_reviewCount'] == nil)
            display_newsfeed_hash['books'][feed_hash['b_id']]['b_reviewCount'] = 0
          end
          book_detail_info = BookDetail.find(feed_hash['b_id'])
          display_newsfeed_hash['books'][feed_hash['b_id']]['b_category'] = book_detail_info['b_category']
          display_newsfeed_hash['books'][feed_hash['b_id']]['b_author'] = book_detail_info['b_author']
          display_newsfeed_hash['books'][feed_hash['b_id']]['b_translator'] = book_detail_info['b_translator']
          display_newsfeed_hash['books'][feed_hash['b_id']]['b_publisher'] = book_detail_info['b_publisher']
          display_newsfeed_hash['books'][feed_hash['b_id']]['b_publishDate'] = book_detail_info['b_publishDate']
        end
        if (type == 'review' or type == 'comment')
          if display_newsfeed_hash[feed_hash['r_id']] == nil
            review = Review.find(feed_hash['b_id'], feed_hash['r_id'])
            review_array = review.hgetReview
            review_id = "#{feed_hash['b_id']}:#{feed_hash['r_id']}"
            if review_array != nil
              if display_newsfeed_hash['users'][review_array[0]] == nil and User.where(:_id => review_array[0]).exists?
                display_newsfeed_hash['users'][review_array[0]] = User.find(review_array[0])
              end
              display_newsfeed_hash['reviews'][review_id] = Hash.new
              Review.fields.each_with_index do |field, index|
                display_newsfeed_hash['reviews'][review_id][field] = review_array[index]
              end
            else
              display_newsfeed_hash['feeds'].delete(feed_hash)
            end
          end
        end
        if (type == 'comment')
          if display_newsfeed_hash['comments'][feed_hash['cm_id']] == nil
            comment = Comment.find(feed_hash['b_id'], feed_hash['r_id'], feed_hash['cm_id'])
            comment_array = comment.hgetComment
            comment_id = "#{feed_hash['b_id']}:#{feed_hash['r_id']}:#{feed_hash['cm_id']}"
            if comment_array != nil
              if display_newsfeed_hash['users'][comment_array[0]] == nil and User.where(:_id => comment_array[0]).exists?
                display_newsfeed_hash['users'][comment_array[0]] = User.find(comment_array[0])
              end
              display_newsfeed_hash['comments'][comment_id] = Hash.new
              display_newsfeed_hash['comments'][comment_id]['u_id'] = comment_array[0]
              display_newsfeed_hash['comments'][comment_id]['cm_comment'] = comment_array[1]
              display_newsfeed_hash['comments'][comment_id]['cm_time'] = comment_array[2]
            else
              display_newsfeed_hash['feeds'].delete(feed_hash)
            end
          end
        end
      end
      if (display_newsfeed_hash['feeds'].count >= 10)
        break
      end
    end 
    return display_newsfeed_hash
  end

  def get_array_larger_than_f_id last_f_id, source_feed_array
    destination_feed_array = nil
    if (last_f_id != nil)
      destination_feed_array = Array.new
      source_feed_array.each do |f_id|
        if (f_id.to_i > last_f_id.to_i)
          destination_feed_array << f_id
        end
      end
    else
      destination_feed_array = source_feed_array
    end
    return destination_feed_array
  end

  def get_array_smaller_than_f_id last_f_id, source_feed_array
    destination_feed_array = nil
    if (last_f_id != nil)
      destination_feed_array = Array.new
      source_feed_array.each do |f_id|
        if (f_id.to_i < last_f_id.to_i)
          destination_feed_array << f_id
        end
      end
    else
      destination_feed_array = source_feed_array
    end
    return destination_feed_array
  end

  def update_saved_display_newsfeed will_save_display_newsfeed, saved_feeds, feed_array, feed_index_hash
    saved_display = SavedDisplayNewsfeed.find(@u_id)
    last_updated_f_id = 0
    will_save_display_newsfeed.each do |feed|
      f_id = feed['f_id']
      index = feed_index_hash[f_id]
      feed_hash = feed_array[index]
      type = feed_hash['type']
      if (type == 'enroll')
        classified_enroll = ClassifiedEnrollFeed.find(@u_id, feed_hash['u_id'])
        classified_enroll_feeds = classified_enroll.zfeeds_withoutscores
        saved_display.srem(classified_enroll_feeds.last)
        saved_feeds.delete_if{|item| item == classified_enroll_feeds.last}
        new_classified_enroll = Array.new
        new_classified_enroll << feed_hash['f_time'].to_time.to_i
        new_classified_enroll << f_id
        classified_enroll.zadd(new_classified_enroll)
        saved_display.sadd(f_id)
        saved_feeds << f_id
        if (f_id.to_i > last_updated_f_id)
          last_updated_f_id = f_id.to_i
        end
      elsif (type == 'review')
        classified_review = ClassifiedReviewFeed.find(@u_id, feed_hash['b_id'])
        classified_review_feeds = classified_review.zfeeds_withoutscores
        saved_display.srem(classified_review_feeds.last)
        saved_feeds.delete_if{|item| item == classified_review_feeds.last}
        new_classified_review = Array.new
        new_classified_review << feed_hash['f_time'].to_time.to_i
        new_classified_review << f_id
        classified_review.zadd(new_classified_review)
        saved_display.sadd(f_id)
        saved_feeds << f_id
        if (f_id.to_i > last_updated_f_id)
          last_updated_f_id = f_id.to_i
        end
      elsif (type == 'comment')
        classified_comment = ClassifiedCommentFeed.find(@u_id, feed_hash['b_id'], feed_hash['r_id'])
        classified_comment_feeds = classified_comment.zfeeds_withoutscores
        saved_display.srem(classified_comment_feeds.last)
        saved_feeds.delete_if{|item| item == classified_comment_feeds.last}
        new_classified_comment = Array.new
        new_classified_comment << feed_hash['f_time'].to_time.to_i
        new_classified_comment << f_id
        classified_comment.zadd(new_classified_comment)
        saved_display.sadd(f_id)
        saved_feeds << f_id
        if (f_id.to_i > last_updated_f_id)
          last_updated_f_id = f_id.to_i
        end
      end
    end
    if (last_updated_f_id > 0)
      saved_display.set_last_f_id(last_updated_f_id)
    end
    return saved_feeds
  end

  def get_feed_data_array_with_feed_array *feed_array
    feed_array = Feed.getFeeds(*feed_array)
    feed_array = sort_by_feed_id(feed_array)
    return remove_invalid_feed(feed_array)
  end

  def display_from_saved_feeds last_displayed_f_id, saved_feeds
    after_last_f_id_feeds = get_array_larger_than_f_id(last_displayed_f_id, saved_feeds)
    if (after_last_f_id_feeds == nil or after_last_f_id_feeds.count == 0)
      render json: nil, status: :ok
      return
    end
    saved_feeds = sort_by_value(after_last_f_id_feeds)
    saved_feeds = saved_feeds.first(10)
    after_last_f_id_feeds = after_last_f_id_feeds + saved_feeds
    feed_array = get_feed_data_array_with_feed_array(*after_last_f_id_feeds)
    feed_index_hash = feed_index_hash_from_array(feed_array)
    feed_array = retrieve_real_data_from_feed_array(saved_feeds, feed_array, feed_index_hash)
    render json: feed_array, status: :ok
  end

  def get
    last_displayed_f_id = params[:last_f_id]
    feeds = @display_source_hash['feeds']

    last_saved_f_id = @saved_display_source_hash['last_f_id']
    saved_feeds = @saved_display_source_hash['feeds']
    after_last_f_id_feeds = get_array_larger_than_f_id(last_saved_f_id, feeds)

    if after_last_f_id_feeds.count == 0
      display_from_saved_feeds(last_displayed_f_id, saved_feeds)
      return
    else
      feed_array = get_feed_data_array_with_feed_array(*after_last_f_id_feeds)
      if (feed_array == nil or feed_array.count == 0)
        display_from_saved_feeds(last_displayed_f_id, saved_feeds)
        return
      end
      feed_index_hash = feed_index_hash_from_array(feed_array)
      classified_feed_hash = classify_feeds_by_type(feed_array)
      save_classified_feed(classified_feed_hash, feed_array, feed_index_hash)
      will_save_display_newsfeed = make_will_save_display_newsfeed(feed_array, classified_feed_hash)
      saved_feeds = update_saved_display_newsfeed(will_save_display_newsfeed, saved_feeds, feed_array, feed_index_hash)
      saved_feeds = sort_by_value(saved_feeds)
      saved_feeds = get_array_larger_than_f_id(last_displayed_f_id, saved_feeds)
      after_last_f_id_feeds = saved_feeds - after_last_f_id_feeds
      if (last_displayed_f_id == 0)
        saved_feeds = saved_feeds.first(10)
      end
      additional_feed_array = get_feed_data_array_with_feed_array(*after_last_f_id_feeds)
      feed_array = feed_array + additional_feed_array
      feed_index_hash = feed_index_hash_from_array(feed_array)
    end
    feed_array = retrieve_real_data_from_feed_array(saved_feeds, feed_array, feed_index_hash)
    render json: feed_array, status: :ok
  end

  def more
    last_displayed_f_id = params[:last_f_id]
    last_saved_f_id = @saved_display_source_hash['last_f_id']
    saved_feeds = @saved_display_source_hash['feeds']

    saved_feeds = get_array_smaller_than_f_id(last_displayed_f_id, saved_feeds)
    saved_feeds = sort_by_value(saved_feeds)
    saved_feeds = saved_feeds.first(10)
    feed_array = get_feed_data_array_with_feed_array(*saved_feeds)
    feed_index_hash = feed_index_hash_from_array(feed_array)
    
    feed_array = retrieve_real_data_from_feed_array(saved_feeds, feed_array, feed_index_hash)
    render json: feed_array, status: :ok
  end

  def make_fake_feeds
    last_fake_f_id = @fake_display_source_hash['last_f_id']
    fake_feeds = @fake_display_source_hash['feeds']
    last_feed_f_id = Feed.last_f_id
    if (last_fake_f_id == nil)
      last_fake_f_id = 0
    end
    last_fake_f_id = last_fake_f_id + 1
    feed_list_array = (last_fake_f_id.to_i..last_feed_f_id.to_i).to_a
    fake_feeds = Feed.getFeeds(*feed_list_array)
=begin
    last_displayed_f_id = params[:last_f_id]
    feeds = @display_source_hash['feeds']

    last_saved_f_id = @saved_display_source_hash['last_f_id']
    saved_feeds = @saved_display_source_hash['feeds']
    after_last_f_id_feeds = get_array_larger_than_f_id(last_saved_f_id, feeds)

    if after_last_f_id_feeds.count == 0
      display_from_saved_feeds(last_displayed_f_id, saved_feeds)
      return
    else
      feed_array = get_feed_data_array_with_feed_array(*after_last_f_id_feeds)
      if (feed_array == nil or feed_array.count == 0)
        display_from_saved_feeds(last_displayed_f_id, saved_feeds)
        return
      end
      feed_index_hash = feed_index_hash_from_array(feed_array)
      classified_feed_hash = classify_feeds_by_type(feed_array)
      save_classified_feed(classified_feed_hash, feed_array, feed_index_hash)
      will_save_display_newsfeed = make_will_save_display_newsfeed(feed_array, classified_feed_hash)
      saved_feeds = update_saved_display_newsfeed(will_save_display_newsfeed, saved_feeds, feed_array, feed_index_hash)
      saved_feeds = sort_by_value(saved_feeds)
      saved_feeds = get_array_larger_than_f_id(last_displayed_f_id, saved_feeds)
      after_last_f_id_feeds = saved_feeds - after_last_f_id_feeds
      if (last_displayed_f_id == 0)
        saved_feeds = saved_feeds.first(10)
      end
      additional_feed_array = get_feed_data_array_with_feed_array(*after_last_f_id_feeds)
      feed_array = feed_array + additional_feed_array
      feed_index_hash = feed_index_hash_from_array(feed_array)
    end
    feed_array = retrieve_real_data_from_feed_array(saved_feeds, feed_array, feed_index_hash)
    render json: feed_array, status: :ok
=end
    render json: fake_feeds, status: :ok
  end

  private
    def set_feed
      @u_id = params[:id]
      display = DisplayNewsfeed.find(@u_id)
      @display_source_hash = display.smembers
    end
    def set_saved_feed
      @u_id = params[:id]
      saved_display = SavedDisplayNewsfeed.find(@u_id)
      @saved_display_source_hash = saved_display.smembers
    end
    def set_saved_fake_feed
      saved_fake_feeds = FakeDisplayNewsfeed.new
      @fake_display_source_hash = saved_fake_feeds.smembers
    end
end
