local query_builder = require "src.query_builder"
local Database = {}
Database.__index = Database

function Database:new(api_base_url, token)
    local s = setmetatable({}, self)
    s.api_base_url = api_base_url
    s:auth(token)
    return s
end

function Database:auth(token)
    self.token = token
    return self
end

function Database:__call(table_name) return query_builder:new(self, table_name) end
Database.__call = Database.__call

return Database
