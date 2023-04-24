local constants = require "postgrest.constants"
local query_builder = require "postgrest.query_builder"
local utils = require "postgrest.utils"

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

function Database:set_json_implementation(json_implementation)
    self.json_implementation = json_implementation
    return self
end

function Database:get_json_implementation_or_error()
    local json_implementation = self.json_implementation or utils.require_json()
    if json_implementation == nil then
        error(constants.MISSING_JSON_IMPLEMENTATION_ERROR)
    end
    return json_implementation
end

function Database:from(table_name) return query_builder:new(self, table_name) end

function Database:__call(table_name) return self:from(table_name) end

return Database
