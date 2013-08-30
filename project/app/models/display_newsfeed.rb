class DisplayNewsfeed
  attr_reader	:u_id
  alias :id :u_id

  def initialize u_id
    @u_id = u_id
  end

  def self.find u_id
    return self.new u_id
  end

  def key?
    "display_newsfeed:#@u_id"
  end

  def sadd(*args)
    addedSet = $redis.sadd(self.key?, *args)
    $redis.sadd('display_newsfeed', self.key?)
    res = Hash.new
    res["u_id"] = @u_id
    res["feeds"] = addedSet
    return res
  end

  def smembers
    set = $redis.smembers(self.key?)
    res = Hash.new
    res["u_id"] = @u_id
    res["feeds"] = set
    return res
  end

  def srem(*args)
    removedSet = $redis.srem(self.key?, *args)
    res = Hash.new
    res["u_id"] = @u_id
    res["feeds"] = removedSet
    return res
  end

  def exists?
    $redis.exists self.key?
  end

  def self.all
    keys = $redis.smembers('display_newsfeed')
    members = $redis.pipelined do
      keys.each do |key|
        $redis.smembers(key)
      end
    end
    res = Array.new
    i = 0
    members.each do |member|
      hash = Hash.new
      hash["key"] = keys[i]
      hash["feeds"] = member
      res << hash
      i = i + 1
    end
    return res
  end
end 
