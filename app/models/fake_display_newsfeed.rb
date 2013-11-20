class FakeDisplayNewsfeed

  def key?
    "fake_display_newsfeed"
  end

  def last_f_id_key?
    "fake_display_newsfeed:last_f_id"
  end

  def sadd(*args)
    result = $redis.sadd(self.key?, *args)
    res = Hash.new
    res["u_id"] = @u_id
    res["feeds"] = result
    return res
  end

  def set_last_f_id last_f_id
    return $redis.set(self.last_f_id_key?, last_f_id)
  end

  def srem(*args)
    result = $redis.srem(self.key?, *args)
    res = Hash.new
    res['u_id'] = @u_id
    res['feeds'] = result
    return res
  end

  def smembers
    set = $redis.smembers(self.key?)
    last_f_id = $redis.get(self.last_f_id_key?)
    res = Hash.new
    res["u_id"] = @u_id
    res["last_f_id"] = last_f_id
    res["feeds"] = set
    return res
  end

  def exists?
    $redis.exists self.key?
  end

end 
