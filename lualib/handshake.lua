-- include libraries
local cjson = require "cjson"
local redis = require "resty.redis"
local ssl = require "ngx.ssl"

-- variables
local server_name = ssl.server_name()
local cn = ssl.server_name()
local k = "domain:"..cn
local red = redis:new()
local ret = {}
local err = nil

ngx.log(ngx.ERR,"Requested ssl server_name="..tostring(server_name))

-- connect redis
red:set_timeout(1000) -- 1 sec
local ok, err = red:connect("127.0.0.1", 6379)
if not ok then
    ngx.say("failed to connect: ", err)
    return
end

-- get cert and pem to redis
local ret, err = red:hgetall(k)
if not err then
    c = red:array_to_hash(ret)
else
    ngx.say("failed to get key and cert: ", err) 
end

local cert = c.certificate
local pkey = c.priv_key

-- convert cert from pem to der
local c, err = ssl.cert_pem_to_der(cert)
if not c then
    ngx.say("Failed to convert pem cert to der cert for common name ", cn, ": ", err)
    return
end

-- set der cert
local ok, err = ssl.set_der_cert(c)
if not ok then
    ngx.say("Failed to set DER cert for common name ", cn, ": ", err)
    return
end

-- convert pkey from pem to der
local p, err = ssl.priv_key_pem_to_der(pkey)
if not p then
    ngx.say("Failed to convert priv key pem cert to der for common name ", cn, ": ", pkey)
    return
end

--set der pkey
local ok, err = ssl.set_der_priv_key(p)
if not ok then
    ngx.say("Failed to set DER private key for common name ", cn, ": ", err)
    return
end
