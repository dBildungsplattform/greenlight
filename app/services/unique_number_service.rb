# app/services/unique_number_service.rb
class UniqueNumberService
  KEY = 'unique_numbers_set'
  MIN = ENV.fetch("PHONE_BRIDGE_PIN_MIN", 10000).to_i
  MAX = ENV.fetch("PHONE_BRIDGE_PIN_MAX", 99999).to_i
  MAX_ATTEMPTS = ENV.fetch("PHONE_BRIDGE_PIN_MAX_ATTEMPTS", 99999).to_i
  LUA_SCRIPT = <<-LUA
    local min = tonumber(ARGV[1])
    local max = tonumber(ARGV[2])
    local max_attempts = tonumber(ARGV[3])
    local key = KEYS[1]

    -- Generate a random number between min and max
    local function generate_number()
        math.randomseed(tonumber(redis.call('TIME')[1]) + tonumber(redis.call('TIME')[2]))
        return tostring(math.random(min, max))
    end

    -- Check if the number is unique
    local function is_unique(number)
        return redis.call("SISMEMBER", key, number) == 0
    end

    -- Generate a unique number
    local function generate_unique_number()
        local attempts = 0
        local number = generate_number()
        while not is_unique(number) do
            attempts = attempts + 1
            if attempts >= max_attempts then
                return nil
            end
            number = generate_number()
        end
        return number
    end

    -- Generate a unique number and add it to the set
    local unique_number = generate_unique_number()
    if unique_number then
        redis.call("SADD", key, unique_number)
        return unique_number
    else
        return nil
    end
  LUA

  def self.next_number
    number = $redis_pin_store.eval(LUA_SCRIPT, keys: [KEY], argv: [MIN, MAX, MAX_ATTEMPTS])
    if number
      Logger.new(STDOUT).info("UniqueNumberService: next_number: #{number}")
    else
      Logger.new(STDOUT).error("UniqueNumberService: Failed to generate a unique number after #{MAX_ATTEMPTS} attempts")
    end
    number
  end

  def self.remove_number(number)
    result = $redis_pin_store.srem(KEY, number)
    if result == 1
      Logger.new(STDOUT).info("UniqueNumberService: Removed number: #{number}")
      true
    else
      Logger.new(STDOUT).warn("UniqueNumberService: Number not found: #{number}")
      false
    end
  end

  def self.register_number(number)
    result = $redis_pin_store.sadd?(KEY, number)
    if result
      Logger.new(STDOUT).info("UniqueNumberService: Registered number: #{number}")
      true
    else
      Logger.new(STDOUT).warn("UniqueNumberService: Number already exists or error occurred: #{number}")
      false
    end
  end
end