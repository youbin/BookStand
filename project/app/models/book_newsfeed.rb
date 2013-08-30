class BookNewsfeed
  attr_reader	:b_id
  alias :id :b_id

  def initialize b_id
    @b_id = b_id
  end

  def self.find b_id
    return self.new b_id
  end

  def key?
    "book_newsfeed:#@b_id"
  end

  def sadd(*args)
    addedSet = $redis.sadd(self.key?, *args)
    $redis.sadd('book_newsfeed', self.key?)
    res = Hash.new
    res["b_id"] = @b_id
    res["feeds"] = addedSet
    return res
  end

  def smembers
    set = $redis.smembers(self.key?)
    res = Hash.new
    res["b_id"] = @b_id
    res["feeds"] = set
    return res
  end

  def exists?
    $redis.exists self.name?
  end

  def self.all
    keys = $redis.smembers('book_newsfeed')
    res = $redis.pipelined do
      keys.each do |x|
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
