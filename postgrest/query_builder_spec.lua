local QueryBuilder = require "postgrest.query_builder"
local http_request = require "http.request"

describe("query_builder", function()

    describe("select", function()
        it("should accept variable columns count", function()
            local expected_columns = {"foo", "bar"}
            local expected_select_str = "select=foo,bar"
            local database = nil
            local table_name = nil
            local query_builder = QueryBuilder:new(database, table_name)
            query_builder:select("foo", "bar")
            assert.same(expected_columns, query_builder.columns)
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
            assert.same(expected_columns, query_builder.columns)
            assert.same(expected_select_str, query_builder.select_str)
        end)

        it("should work with empty columns table object", function()
            local expected_columns = {}
            local expected_select_str = ""
            local database = nil
            local table_name = nil
            local columns = {}
            local query_builder = QueryBuilder:new(database, table_name)
            query_builder:select(columns)
            assert.same(expected_columns, query_builder.columns)
            assert.same(expected_select_str, query_builder.select_str)
        end)

        it("should work with nil columns object", function()
            local expected_columns = {}
            local expected_select_str = ""
            local database = nil
            local table_name = nil
            local columns = nil
            local query_builder = QueryBuilder:new(database, table_name)
            query_builder:select(columns)
            assert.same(expected_columns, query_builder.columns)
            assert.same(expected_select_str, query_builder.select_str)
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

    describe("add_headers", function()

        it("should work no headers", function()
            local url = "http://localhost"
            local request = http_request.new_from_uri(url)
            local default_len = request.headers:len()
            local headers = nil
            local returned_request = QueryBuilder.add_headers(request, headers)
            assert.same(request, returned_request)
            assert.equal(request.headers:len(), default_len)
        end)

        it("should upsert headers", function()
            local url = "http://localhost"
            local request = http_request.new_from_uri(url)
            local default_len = request.headers:len()
            local headers = {key1 = "value1", key2 = "value2"}
            local returned_request = QueryBuilder.add_headers(request, headers)
            assert.same(request, returned_request)
            assert.equal(request.headers:len(), default_len + 2)
        end)
    end)

    describe("filter", function()

        it("should work with basic filtering", function()
            local filter = {id = 1}
            local expected = "id=eq.1"
            local database = nil
            local table_name = nil
            local query_builder = QueryBuilder:new(database, table_name)
            query_builder:filter(filter)
            assert.same(expected, query_builder.filter_str)
        end)

        it("should work with an operator", function()
            local filter = {id__eq = 1}
            local expected = "id=eq.1"
            local database = nil
            local table_name = nil
            local query_builder = QueryBuilder:new(database, table_name)
            query_builder:filter(filter)
            assert.same(expected, query_builder.filter_str)
        end)

        it("should work with a raw filter", function()
            local filter = "id=eq.1"
            local expected = filter
            local database = nil
            local table_name = nil
            local query_builder = QueryBuilder:new(database, table_name)
            query_builder:filter(filter)
            assert.same(expected, query_builder.filter_str)
        end)

    end)

end)

