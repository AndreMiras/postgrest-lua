local FilterBuilder = require "postgrest.filter_builder"

local QueryBuilder = {}
QueryBuilder.__index = QueryBuilder

function QueryBuilder:new(database, table_name)
    local s = setmetatable({}, self)
    s.database = database
    s.table_name = table_name
    s.method = nil
    s.query_parameters = {}
    s.payload = {}
    return s
end

function QueryBuilder:select(columns, ...)
    self.method = "GET"
    if type(columns) == "table" then
        self.select_columns = columns
    else
        self.select_columns = {columns, ...}
    end
    self.select_str = #self.select_columns > 0 and "select=" ..
                          table.concat(self.select_columns, ",") or nil
    if self.select_str then
        table.insert(self.query_parameters, self.select_str)
    end
    return FilterBuilder:new(self.database, self.table_name, self.method,
                             self.query_parameters, self.payload)
end

function QueryBuilder:update(values)
    self.method = "PATCH"
    self.payload = values
    return FilterBuilder:new(self.database, self.table_name, self.method,
                             self.query_parameters, self.payload)
end

function QueryBuilder:insert(values)
    self.method = "POST"
    self.payload = values
    return FilterBuilder:new(self.database, self.table_name, self.method,
                             self.query_parameters, self.payload)
end

function QueryBuilder:delete()
    self.method = "DELETE"
    return FilterBuilder:new(self.database, self.table_name, self.method,
                             self.query_parameters, self.payload)
end

return QueryBuilder
