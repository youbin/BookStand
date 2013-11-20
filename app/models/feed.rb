class Feed
  attr_reader	:f_id
  alias :id :f_id

  @@fields = ["type", "u_id", "b_id", "r_id", "cm_id", "fr_id", "f_time"]

  def initialize f_id = nil
    if f_id == nil
      @f_id = Feed.getF_id
    else
      @f_id = f_id
    end
  end

  def self.find f_id
    return self.new f_id
  end

  def self.fields
    return @@fields
  end

  def key?
    return "feed:#@f_id"
  end

  def last_f_id_key?
    return "feed:last_f_id"
  end

  def self.last_f_id
    return $redis.get("feed:last_f_id")
  end

  def hmset(*args)
    args = CommonMethods.makeParArgs(*args)
    $redis.hmset(self.key?, args)
    $redis.set(self.last_f_id_key?, @f_id)
    res = CommonMethods.makeHash(*args)
    res["f_id"] = @f_id
    return res
  end

  def hgetall
    Feed.hgetall self.key?
  end

  def self.hgetall key
    res = $redis.hgetall(key)
    res["f_id"] = @f_id
    return res
  end

  def save
    $redis.sadd('feed', self.key?)
    self.saved?
  end

  def saved?
    $redis.exists self.key?
  end

  def self.getF_id
    key = 'feed:global_f_id'
    $redis.multi
    $redis.incr(key)
    $redis.exec
    f_id = $redis.get(key)
    return f_id
  end

  def self.all
    keys = $redis.smembers('feed')
    res = $redis.pipelined do
      keys.each do |key|
        $redis.hgetall(key)
      end
    end
    i = 0
    res.each do |result|
      result["key"] = keys[i]
      i = i + 1
    end
    return res
  end

  def self.getFeeds(*args)
    feedArgs = *args
    res = $redis.pipelined do
      feedArgs.each do |feed|
        $redis.hgetall("feed:" + feed.to_s)
      end
    end
    i = 0
    res.each do |result|
      result["f_id"] = feedArgs[i]
      i = i + 1
    end
    return res
  end
end 
