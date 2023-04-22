local QueryBuilder = require "postgrest.query_builder"

describe("query_builder", function()

    describe("select", function()
        it("should accept variable columns count", function()
            local expected = {"foo", "bar"}
            local database = nil
            local table_name = nil
            local query_builder = QueryBuilder:new(database, table_name)
            query_builder:select("foo", "bar")
            assert.same(expected, query_builder.columns)
        end)
    end)

    describe("select", function()
        it("should accept table type as columns", function()
            local expected = {"foo", "bar"}
            local database = nil
            local table_name = nil
            local columns = {"foo", "bar"}
            local query_builder = QueryBuilder:new(database, table_name)
            query_builder:select(columns)
            assert.same(expected, query_builder.columns)
        end)
    end)

end)

