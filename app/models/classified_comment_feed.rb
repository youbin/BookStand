class ClassifiedCommentFeed
  attr_reader	:u_id, :b_id, :r_id
  alias :id :u_id

  def initialize u_id, b_id, r_id
    @u_id = u_id
    @b_id = b_id
    @r_id = r_id
  end

  def self.find u_id, b_id, r_id
    return self.new u_id, b_id, r_id
  end

  def key?
    "classified_feed:comment:#@u_id:#@b_id:#@r_id"
  end

  def zadd(*args)
    result = $redis.zadd(self.key?, *args)
    $redis.sadd('classified_feed:review', self.key?)
    res = Hash.new
    res['u_id'] = @u_id
    res['b_id'] = @b_id
    res['r_id'] = @r_id
    res['result'] = result
    return res
  end

  def zall
    zset = $redis.zrange(self.key?, 0, -1, :withscores => :true)
    res = Hash.new
    res['u_id'] = @u_id
    res["b_id"] = @b_id
    res["r_id"] = @r_id
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
