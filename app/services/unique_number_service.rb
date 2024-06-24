# app/services/unique_number_service.rb
class UniqueNumberService
    KEY = 'unique_number'
    INITIAL_VALUE = 10000
  
    def self.next_number
      ensure_initial_value
      number = $redis.incr(KEY)
      Logger.new(STDOUT).info("UniqueNumberService: next_number: #{number}")
        number
    end
  
    def self.ensure_initial_value
      current_value = $redis.get(KEY).to_i
      if current_value < INITIAL_VALUE
        $redis.set(KEY, INITIAL_VALUE - 1)
      end
    end
  end
  