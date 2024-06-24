class UniqueNumberService
    KEY = 'unique_number'
  
    def self.next_number
      number = $redis.incr(KEY)
      format('%08d', number)
    end
  end
  