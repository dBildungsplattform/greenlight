require 'redis'

$redis = Redis.new(host: 'redis_pin_store', port: 6379)
