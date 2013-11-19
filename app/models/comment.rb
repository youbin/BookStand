class Comment
  attr_reader :b_id
  attr_reader :r_id
  attr_reader :cm_id
  alias :id :cm_id

  @@fields = ["u_id", "cm_comment", "cm_time"]
 
  def initialize(b_id, r_id, cm_id = nil)
    @b_id = b_id
    @r_id = r_id
    if cm_id == nil
      @cm_id = Comment.getCm_id(b_id, r_id)
    else
      @cm_id = cm_id
    end
  end
 
  def self.find(b_id, r_id, cm_id)
    return self.new(b_id, r_id, cm_id)
  end

  def self.exists?(b_id, r_id, cm_id)
    return $redis.exists("comment:#{b_id}:#{r_id}:#{cm_id}")
  end

  def self.delete(b_id, r_id, cm_id)
    return $redis.srem("comment:#{b_id}:#{r_id}", "comment:#{b_id}:#{r_id}:#{cm_id}")
  end

  def self.fields
    return @@fields
  end

  def self.reviewKey?(b_id, r_id)
    return "comment:#{b_id}:#{r_id}"
  end

  def bookKey?
    return "comment:#@b_id"
  end

  def reviewKey?
    return "comment:#@b_id:#@r_id"
  end

  def key?
    return "comment:#@b_id:#@r_id:#@cm_id"
  end

  def hmset(*args)
    args = CommonMethods.makeParArgs(*args)
    $redis.hmset(self.key?, args)
    res = CommonMethods.makeHash(*args)
    res["cm_id"] = @cm_id
    return res
  end

  def hgetComment
    if $redis.exists(self.key?)
      return $redis.hmget(self.key?, 'u_id', 'cm_comment', 'cm_time')
    else
      return nil
    end
  end


  def hgetall
    res = $redis.hgetall(self.key?)
    res["cm_id"] = @cm_id
    return res
  end

  def save
    book_key = self.bookKey?
    review_key = self.reviewKey?
    $redis.sadd(review_key, self.key?)
    $redis.sadd(book_key, review_key)
    $redis.sadd('comment', book_key)
    self.saved?
  end

  def saved?
    $redis.exists self.key?
  end

  def self.getCm_id(b_id, r_id)
    key = Comment.reviewKey?(b_id, r_id) + ':global_cm_id'
    $redis.multi
    $redis.incr(key)
    $redis.exec
    cm_id = $redis.get(key)
    return cm_id
  end

  def self.all(b_id, r_id)
    review_key = Comment.reviewKey?(b_id, r_id)
    keys = $redis.smembers(review_key)
    userController = UsersController.new
    contents = Array.new
    user = Hash.new
    res = Array.new
    $redis.pipelined do
      keys.each do |key|
        contents << $redis.hmget(key, @@fields) 
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
      hash["key"] = keys[i]
      hash["cm_id"] = keys[i].split(/:/)[3]
      for j in 0..@@fields.size - 1
        hash[@@fields[j]] = res_contents[j]
      end
      res << hash
      i = i + 1
    end
    result = Hash.new
    result["comments"] = res
    result["users"] = user
    return result
  end
end
