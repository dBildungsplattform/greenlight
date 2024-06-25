local min = 10000
local max = 99999
local key = KEYS[1]

-- Generate a random number between min and max
local function generate_number()
    return math.random(min, max)
end

-- Check if the number is unique
local function is_unique(number)
    return redis.call("SISMEMBER", key, number) == 0
end

-- Generate a unique number
local function generate_unique_number()
    local number = generate_number()
    while not is_unique(number) do
        number = generate_number()
    end
    return number
end

-- Generate a unique number and add it to the set
local unique_number = generate_unique_number()
redis.call("SADD", key, unique_number)
return unique_number