class CommonMethods

  def self.makeHash(*args)
    args_size = args.size
    if args_size % 2 != 0
      return false
    end
    result = Hash.new
    i = 0
    while i < args_size
      result[args[i]] = args[i+1]
      i = i + 2
    end
    p result
    return result
  end

  def self.makeParArgs(*args)
    args_size = args.size
    if args_size % 2 != 0
      return false
    end
    result = Array.new
    i = 0
    j = 0
    while i < args_size
      if args[i+1] != nil
        result[j] = args[i]
        result[j+1] = args[i+1]
        j = j + 2
      end
      i = i + 2
    end
    return result
  end

  def self.makeArgs(params, *args)
    args_size = args.size
    result = Array.new
    i = 0
    while i < args_size
      result << args[i]
      result << params[args[i]]
      i = i + 1
    end
    return result
  end

end
    
