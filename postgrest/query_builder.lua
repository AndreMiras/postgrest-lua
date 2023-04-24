local FilterBuilder = require "postgrest.filter_builder"

local QueryBuilder = {}
QueryBuilder.__index = QueryBuilder

QueryBuilder.MISSING_JSON_IMPLEMENTATION_ERROR = "Missing JSON implementation"

function QueryBuilder:new(database, table_name)
    local s = setmetatable({}, self)
    s.database = database
    s.table_name = table_name
    s.query_parameters = {}
    return s
end

function QueryBuilder:select(columns, ...)
    if type(columns) == "table" then
        self.columns = columns
    else
        self.columns = {columns, ...}
    end
    self.select_str = #self.columns > 0 and "select=" ..
                          table.concat(self.columns, ",") or ""
    if self.select_str then
        table.insert(self.query_parameters, self.select_str)
    end
    return FilterBuilder:new(self.database, self.table_name,
                             self.query_parameters)
end

return QueryBuilder
