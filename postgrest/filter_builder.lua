local utils = require "postgrest.utils"
local http_request = require "http.request"
local http_util = require "http.util"

local FilterBuilder = {}
FilterBuilder.__index = FilterBuilder

function FilterBuilder:new(database, table_name, method, query_parameters,
                           payload)
    local s = setmetatable({}, self)
    s.database = database
    s.table_name = table_name
    s.method = method
    s.query_parameters = query_parameters
    s.payload = payload
    return s
end

-- decompose the key to comlumn and operator
-- operator default to "eq" if not found
function FilterBuilder.key_to_operator(key)
    local column, operator = key:match("^(.-)__([^_]+)$")
    return operator and {column = column, operator = operator} or
               {column = key, operator = 'eq'}
end

function FilterBuilder.quoted(value) return '"' .. value .. '"' end

function FilterBuilder.quote_if_string(value)
    return type(value) == "string" and FilterBuilder.quoted(value) or value
end

function FilterBuilder.to_postgrest_string(value)
    return type(value) == "table" and "(" ..
               table.concat(utils.map(FilterBuilder.quote_if_string, value), ",") ..
               ")" or tostring(value)
end

function FilterBuilder.filter_table(kwargs)
    local filter_table = {}
    for key, value in pairs(kwargs) do
        local column_and_operator = FilterBuilder.key_to_operator(key)
        local filter_str = column_and_operator.column .. "=" ..
                               column_and_operator.operator .. "." ..
                               FilterBuilder.to_postgrest_string(value)
        table.insert(filter_table, filter_str)
    end
    return table.concat(filter_table, "&")
end

function FilterBuilder:filter(kwargs)
    self.filter_str = type(kwargs) == "table" and self.filter_table(kwargs) or
                          kwargs
    return self
end

-- mutate the request headers by upserting
function FilterBuilder.add_headers(request, headers)
    if not headers then return request end
    for key, value in pairs(headers) do request.headers:upsert(key, value) end
    return request
end

function FilterBuilder.raise_for_status(headers, stream)
    local body = assert(stream:get_body_as_string())
    local status = tonumber(headers:get(":status"))
    if status < 200 or status >= 300 then
        error("Request failed with status: " .. status .. " and body: " .. body)
    end
    return status, body
end

function FilterBuilder:execute()
    local json_implementation = self.database:get_json_implementation_or_error()
    local request_logger = self.database.request_logger
    local api_base_url = self.database.api_base_url
    local auth_headers = self.database.auth_headers
    local table_name = self.table_name
    local filter_str = self.filter_str
    local method = self.method
    local query_parameters = self.query_parameters
    local payload = self.payload
    local url = api_base_url .. "/" .. table_name
    if filter_str then table.insert(query_parameters, filter_str) end
    if utils.table_length(query_parameters) > 0 then
        url = url .. "?" .. table.concat(query_parameters, "&")
    end
    local request = http_request.new_from_uri(http_util.encodeURI(url))
    request.headers:upsert("content-type", "application/json")
    request.headers:upsert(":method", method)
    FilterBuilder.add_headers(request, auth_headers)
    if utils.table_length(payload) > 0 then
        request:set_body(json_implementation.encode(payload));
    end
    if request_logger then
        request_logger(method, url, payload, request.headers)
    end
    local headers, stream = assert(request:go())
    local _, body = self.raise_for_status(headers, stream)
    return #body > 0 and json_implementation.decode(body)
end

return FilterBuilder
