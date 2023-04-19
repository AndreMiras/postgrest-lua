local query_builder = require "postgrest.query_builder"
local Database = {}
Database.__index = Database

function Database:new(api_base_url, auth_headers)
    local s = setmetatable({}, self)
    s.api_base_url = api_base_url
    s:auth(auth_headers)
    return s
end

function Database:auth(auth_headers)
    self.auth_headers = auth_headers
    return self
end

function Database:__call(table_name) return query_builder:new(self, table_name) end
Database.__call = Database.__call

return Database
