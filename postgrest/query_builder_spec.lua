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

    describe("key_to_operator", function()

        it("should work with gte", function()
            local expected = {column = "foobar", operator = "gte"}
            local key = "foobar__gte"
            local column_and_operator = QueryBuilder.key_to_operator(key)
            assert.same(expected, column_and_operator)
        end)

        it("should work with no operator", function()
            local expected = {column = "foobar", operator = "eq"}
            local key = "foobar"
            local column_and_operator = QueryBuilder.key_to_operator(key)
            assert.same(expected, column_and_operator)
        end)
    end)

end)

