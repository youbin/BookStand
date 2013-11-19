class Review
  attr_reader :b_id
  attr_reader :r_id
  alias :id :r_id

  @@fields = ["u_id", "r_review", "r_starPoint", "r_time"]
 
  def initialize(b_id, r_id = nil)
    @b_id = b_id
    if r_id == nil
      @r_id = Review.getR_id(b_id)
    else
      @r_id = r_id
    end
  end
 
  def self.find(b_id, r_id)
    return self.new(b_id, r_id)
  end

  def self.exists?(b_id, r_id)
    return $redis.exists("review:#{b_id}:#{r_id}")
  end

  def self.fields
    return @@fields
  end

  def self.bookKey?(b_id)
    return "review:#{b_id}"
  end

  def bookKey?
    return "review:#@b_id"
  end

  def key?
    return "review:#@b_id:#@r_id"
  end

  def hmset(*args)
    args = CommonMethods.makeParArgs(*args)
    $redis.hmset(self.key?, args)
    res = CommonMethods.makeHash(*args)
    res["r_id"] = @r_id
    return res
  end

  def hgetReview
    if $redis.exists(self.key?)
      return $redis.hmget(self.key?, @@fields)
    else
      return nil
    end
  end
  def hgetall
    res = $redis.hgetall(self.key?)
    res["cm_ids"] = $redis.smembers(res["cm_ids"])
    res["r_id"] = @r_id
    return res
  end

  def self.hgetall key
    Log.debug(self, {:key => key}, 'begin')
    key_split = key.split(':')
    if (key_split[1] == nil or key_split[1] == '(null)' or
        key_split[2] == nil or key_split[2] == '(null')
      return nil
    end
    res = $redis.hgetall(key)
    res['b_id'] = key_split[1]
    res['r_id'] = key_split[2]
    res['b_title'] = Book.find(key_split[1].to_s).b_title
    Log.debug(self, res, 'end')
    return res
  end

  def saddToCm_id(*args)
    $redis.sadd(self.key? + ":cm_ids", *args)
    $redis.hset(self.key?, "cm_ids", self.key? + ":cm_ids")
  end

  def save
    book_key = self.bookKey?
    $redis.sadd(book_key, self.key?)
    $redis.sadd('review', book_key)
    return self.saved?
  end

  def saved?
    $redis.exists self.key?
  end

  def self.getR_id(b_id)
    key = Review.bookKey?(b_id) + ':global_r_id'
    $redis.multi
    $redis.incr(key)
    $redis.exec
    r_id = $redis.get(key)
    return r_id
  end

  def self.all(b_id)
    bookKey = Review.bookKey?(b_id)
    keys = $redis.smembers(bookKey)
    userController = UsersController.new
    contents = Array.new
    cm_ids = Array.new
    user = Hash.new
    res = Array.new
    $redis.pipelined do
      keys.each do |key|
        contents << $redis.hmget(key, @@fields)
        cm_ids << $redis.smembers(key + ":cm_ids")
      end
    end
    contents.each do |content|
      if (user[content.value[0]] == nil and User.where(:_id => content.value[0]).exists? == true)
        user[content.value[0]] = User.find(content.value[0])
      end
    end
    i = 0
    while i < keys.size
      hash = Hash.new
      res_contents = contents[i].value
      res_cm_ids = cm_ids[i].value
      hash["key"] = keys[i]
      hash["r_id"] = keys[i].split(/:/)[2]
      for j in 0..@@fields.size - 1
        hash[@@fields[j]] = res_contents[j]
      end
      hash["cm_ids"] = res_cm_ids
      res << hash
      i = i + 1
    end
    result = Hash.new
    result["reviews"] = res
    result["users"] = user
    return result
  end
end
