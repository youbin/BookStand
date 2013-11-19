class ClassifiedEnrollFeed
  attr_reader	:u_id, :fr_id
  alias :id :u_id

  def initialize u_id, fr_id
    @u_id = u_id
    @fr_id = fr_id
  end

  def self.find u_id, fr_id
    return self.new u_id, fr_id
  end

  def key?
    "classified_feed:enroll:#@u_id:#@fr_id"
  end

  def zadd(*args)
    result = $redis.zadd(self.key?, *args)
    $redis.sadd('classified_feed:enroll', self.key?)
    res = Hash.new
    res['u_id'] = @u_id
    res['fr_id'] = @fr_id
    res['result'] = result
    return res
  end

  def zall
    zset = $redis.zrange(self.key?, 0, -1, :withscores => :true)
    res = Hash.new
    res["u_id"] = @u_id
    res['fr_id'] = @fr_id
    res["feeds"] = zset
    return res
  end

  def zfeeds_withoutscores
    return $redis.zrange(self.key?, 0, -1)
  end

  def exists?
    $redis.exists self.key?
  end

end 
