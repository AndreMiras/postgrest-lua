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

function QueryBuilder:select(columns, ...)
    if type(columns) == "table" then
        self.columns = columns
    else
        self.columns = {columns, ...}
    end
    return self
end

-- decompose the key to comlumn and operator
function QueryBuilder.key_to_operator(key)
    local column, operator = key:match('^(.-)__?(.*)$')
    return operator and {column = column, operator = operator} or
               {column = key, operator = 'eq'}
end

function QueryBuilder:filter_table(kwargs)
    local filter_table = {}
    for key, value in pairs(kwargs) do
        local column_and_operator = QueryBuilder.key_to_operator(key)
        local filter_str = column_and_operator.column .. "=" ..
                               column_and_operator.operator .. "." ..
                               tostring(value)
        table.insert(filter_table, filter_str)
    end
    self.filter_str = table.concat(filter_table, "&")
    return self
end

function QueryBuilder:filter_raw(kwargs)
    self.filter_str = kwargs
    return self
end

function QueryBuilder:filter(kwargs)
    return type(kwargs) == "table" and self:filter_table(kwargs) or
               self:filter_raw(kwargs)
end

-- mutate the request headers by upserting
function QueryBuilder.add_headers(request, headers)
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
    local columns = self.columns
    local filter_str = self.filter_str
    local url = api_base_url .. "/" .. table_name .. "?"
    if columns then url = url .. "select=" .. table.concat(self.columns, ",") end
    if filter_str then url = url .. "&" .. filter_str end
    local request = http_request.new_from_uri(url)
    request.headers:upsert("content-type", "application/json")
    QueryBuilder.add_headers(request, auth_headers)
    local headers, stream = assert(request:go())
    local body = assert(stream:get_body_as_string())
    if headers:get ":status" ~= "200" then error(body) end
    return json_implementation.decode(body)
end

return QueryBuilder
