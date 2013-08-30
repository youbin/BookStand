$redis = Redis.new(:host => 'localhost', :port => 6379)
Redis::Objects.redis = $redis
#$redis_ns = Redis::Namespace.new(cnfg[:namespace], :redis => $redis) if cnfg[:namespace]

# To clear out the db before each test
#$redis.flushdb if Rails.env = "test"
