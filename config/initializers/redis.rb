# config/initializers/redis.rb
require 'redis'

$redis = Redis.new(host: 'redis-service', port: 6379)
