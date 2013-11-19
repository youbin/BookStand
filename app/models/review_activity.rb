class ReviewActivity
  attr_reader	:r_id
  alias :id :r_id

  @key = 'review_activity'

  def self.setReviewActivity(b_id, r_id, time)
    res = $redis.zadd(@key, time, "review:#{b_id}:#{r_id}")
    return res
  end

  def self.getReviewActivities
    res = $redis.zrevrange(@key, 0, -1, :withscores => true)
    return res
  end
end
