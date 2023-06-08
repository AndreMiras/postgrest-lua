local QueryBuilder = require "postgrest.query_builder"

describe("query_builder", function()

    describe("select", function()
        it("should accept variable columns count", function()
            local expected_columns = {"foo", "bar"}
            local expected_select_str = "select=foo,bar"
            local database = nil
            local table_name = nil
            local query_builder = QueryBuilder:new(database, table_name)
            query_builder:select("foo", "bar")
            assert.same(expected_columns, query_builder.select_columns)
            assert.same(expected_select_str, query_builder.select_str)
        end)

        it("should accept table type as columns", function()
            local expected_columns = {"foo", "bar"}
            local expected_select_str = "select=foo,bar"
            local database = nil
            local table_name = nil
            local columns = {"foo", "bar"}
            local query_builder = QueryBuilder:new(database, table_name)
            query_builder:select(columns)
            assert.same(expected_columns, query_builder.select_columns)
            assert.same(expected_select_str, query_builder.select_str)
        end)

        it("should work with empty columns table object", function()
            local expected_columns = {}
            local expected_query_parameters = {}
            local expected_select_str = nil
            local database = nil
            local table_name = nil
            local columns = {}
            local query_builder = QueryBuilder:new(database, table_name)
            query_builder:select(columns)
            assert.same(expected_columns, query_builder.select_columns)
            assert.same(expected_query_parameters,
                        query_builder.query_parameters)
            assert.same(expected_select_str, query_builder.select_str)
        end)

        it("should work with nil columns object", function()
            local expected_columns = {}
            local expected_query_parameters = {}
            local expected_select_str = nil
            local database = nil
            local table_name = nil
            local columns = nil
            local query_builder = QueryBuilder:new(database, table_name)
            query_builder:select(columns)
            assert.same(expected_columns, query_builder.select_columns)
            assert.same(expected_query_parameters,
                        query_builder.query_parameters)
            assert.same(expected_select_str, query_builder.select_str)
        end)
    end)

end)

