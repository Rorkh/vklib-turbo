# vklib-turbo
vklib (https://github.com/LuaFan2/vklib) implementation for turbo (https://github.com/kernelsauce/turbo)
## Examples
## Simple example
```lua
local vk = require("vklib")
local api = vk:Session(token)

api.groups.isMember{group_id = 1, user_id = 1}:cb(function(res)
    print(res.response)
end)
```
```
Output:
0
```
## Example with options
```lua
local vk = require("vklib")
local api = vk:Session(token, {raw = true, version = 5.42})

api.groups.isMember{group_id = 1, user_id = 1}:cb(function(res)
    print(res)
end)
```
```
Output:
{"response":0}
```
