#!/bin/sh
set -e

echo "Starting entrypoint script"

# Start Redis server in the background
redis-server --port 6380 --daemonize yes

# Wait for Redis to be available
echo "Waiting for Redis to be available..."
until redis-cli -p 6380 ping | grep -q PONG; do
    sleep 1
done

echo "Redis server started in the background"

# Run the Lua script to generate a unique number
redis-cli -p 6380 --eval /usr/local/etc/redis/unique_number.lua unique_numbers_set

echo "Lua script executed"

# Stop the background Redis server
redis-cli -p 6380 shutdown

# Start Redis server in the foreground to keep the container alive
exec redis-server --port 6380 --protected-mode no
