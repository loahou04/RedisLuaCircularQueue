RedisLuaCircularQueue
=====================

A simple straight forward redis circular queue based on antirez's circular queue blog (http://oldblog.antirez.com/post/250).

The script turns redis itself into a queue manager.  All consumers will call the redis script in order to grab the next item off of the queue.  Can be used with multiple queue items.  Consumers should be on a pulling method (whether it be timeout or a fired off event) to grab the next item in the queue.


Usage
=====================

redis-cli: eval "$(cat /path/to/getNextQItem.lua)" 4 KEYS1 KEYS2 KEYS3 KEYS4

--KEYS[1]
	-- limit for searching for next processable queue item
--KEYS[2]
	-- Queue to pop items off of
--KEYS[3]
	--current UTC time in milliseconds
--KEYS[4]
	--allowable processing time in milliseconds
--KEYS[5]
	--item retry limit

