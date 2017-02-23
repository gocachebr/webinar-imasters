-- include libraries
local cjson = require "cjson"
local redis = require "resty.redis"

-- variables
local cn = ngx.var.host
local red = redis:new()
local ret = {}
local err = nil
local k = "domain:"..cn

-- connect redis
red:set_timeout(1000) -- 1 sec
local ok, err = red:connect("127.0.0.1", 6379)
if not ok then
    ngx.say("failed to connect: ", err)
    return
end

-- get backend
local ret, err = red:hgetall(k)
if not err then
    c = red:array_to_hash(ret)
else
    ngx.say("failed to get backend: ", err)
end

ngx.var.backend = c.backend 
