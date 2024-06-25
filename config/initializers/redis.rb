require 'redis'

redis_host = ENV.fetch("REDIS_PIN_STORE_HOST", "localhost")
redis_port = ENV.fetch("REDIS_PIN_STORE_PORT", 6379)

Logger.new(STDOUT).info("Connecting to Redis at #{redis_host}:#{redis_port}")

$redis_pin_store = Redis.new(host: redis_host, port: redis_port)
