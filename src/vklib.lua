local vk = {}

_G.TURBO_SSL = true

local turbo = require("turbo")
local escape = turbo.escape

--
-- Internal
--

vk.Version = '5.131'

--
-- Help functions
--

local function _newStack ()
        return {''}   -- starts with an empty string
end

local function _addString (stack, s)
        table.insert(stack, s)    -- push 's' into the the stack
        for i=table.getn(stack)-1, 1, -1 do
                if string.len(stack[i]) > string.len(stack[i+1]) then
                        break
                end
                stack[i] = stack[i] .. table.remove(stack)
        end
end

local function _toString(t)
        return table.concat(t)
end

--
--

function vk:Session(token, options)
        local obj = {}
                obj.token = token
                obj.options = options or {}

        local api = setmetatable({}, {__index = function(t, kg)
                local group, method, result
                local argList = _newStack()

                group = kg
                kg = setmetatable({}, {__index = function(_, km)
                        method = km

                        return setmetatable({}, {__call = function(s, f)
                                return {cb = function(this, callb)
                                        callb = callb or function(...) end
                                        if not f.v then f.v = (obj.options.version and obj.options.version) or vk.Version end

                                        for k, v in pairs(f) do
                                          _addString(argList, k .. '=' .. v .. '&')
                                        end

                                        local req = string.gsub('https://api.vk.com/method/' .. group .. '.' .. method .. '?' .. _toString(argList) .. 'access_token=' .. obj.token, "%s+", "%%20")

                                        local inst = turbo.ioloop.instance()
                                        inst:add_callback(function()
                                                local res = coroutine.yield(turbo.async.HTTPClient({verify_ca=false}):fetch(req))

                                                local error = res.error
                                                if error then
                                                        callb(error)
                                                else
                                                        local body = res.body
                                                        callb(obj.options.raw and body or escape.json_decode(body))
                                                end

                                                inst:close()
                                        end)

                                        inst:start()

                                        return true
                                end}
                        end})
                end})

                return kg
        end})

        setmetatable(obj, self)
        self.__index = self

        return api
end

return vk
