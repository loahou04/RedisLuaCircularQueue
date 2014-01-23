--KEYS[1]
	-- retry number
--KEYS[2]
	-- Queue to pop items off of
--KEYS[3]
	--current UTC time in milliseconds
--KEYS[4]
	--allowable processing time in milliseconds
--KEYS[5]
	--item retry limit

local retry = tonumber(KEYS[1])

local function itemIsNext (startTime, count, systemTime)

	--this means this is the first time this id has been queued up
	if startTime == nil then
		return true
	end

	--dont know why but i had to separate these out
	--for some reason if you do an or statement it still runs it and so if its nil
	--the runtime will complain its trying to compare a string to a number
	if startTime + tonumber(KEYS[4]) < systemTime and count < tonumber(KEYS[5]) then
		return true
	end

	return false
end


while retry > 0 do

	local item = redis.call("LPOP", KEYS[2])

	if item == false then
		return nil
	end

	local idx = 0
	local splitItem = {}
	local systemTime = tonumber(KEYS[3])

	--stupid lua's way of splitting a string
	for i in string.gmatch(item, "%d+") do
		splitItem[idx] = i
		idx=idx+1
	end
	local id = splitItem[0]
	local startTime = tonumber(splitItem[1])
	local count = tonumber(splitItem[2])

	if count == nil then
		count = 0
	end

	if itemIsNext(startTime, count, systemTime) then
		local newId = id .. "*" .. systemTime .. "*" .. count+1
		redis.call("RPUSH", KEYS[2], newId)
		return newId
	elseif count < tonumber(KEYS[5]) then
		redis.call("RPUSH", KEYS[2], item)
	end

	retry = retry - 1

end

return nil