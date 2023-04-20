local utils = require "postgrest.utils"
local http_request = require "http.request"

local QueryBuilder = {}
QueryBuilder.__index = QueryBuilder

QueryBuilder.MISSING_JSON_IMPLEMENTATION_ERROR = "Missing JSON implementation"

function QueryBuilder:new(database, table_name)
    local s = setmetatable({}, self)
    s.database = database
    s.table_name = table_name
    return s
end

function QueryBuilder:select(columns)
    self.columns = columns
    return self
end

local function add_headers(request, headers)
    if not headers then return request end
    for key, value in pairs(headers) do request.headers:upsert(key, value) end
    return request
end

function QueryBuilder:execute(json_implementation)
    json_implementation = json_implementation or utils.require_json()
    if json_implementation == nil then
        error(self.MISSING_JSON_IMPLEMENTATION_ERROR)
    end
    local api_base_url = self.database.api_base_url
    local auth_headers = self.database.auth_headers
    local table_name = self.table_name
    local request = http_request.new_from_uri(api_base_url .. "/" .. table_name)
    request.headers:upsert("content-type", "application/json")
    add_headers(request, auth_headers)
    local headers, stream = assert(request:go())
    local body = assert(stream:get_body_as_string())
    if headers:get ":status" ~= "200" then error(body) end
    return json_implementation.decode(body)
end

return QueryBuilder
