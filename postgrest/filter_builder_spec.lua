local FilterBuilder = require "postgrest.filter_builder"
local http_request = require "http.request"

describe("filter_builder", function()

    describe("key_to_operator", function()

        it("should work with gte", function()
            local expected = {column = "foobar", operator = "gte"}
            local key = "foobar__gte"
            local column_and_operator = FilterBuilder.key_to_operator(key)
            assert.same(expected, column_and_operator)
        end)

        it("should work with no operator", function()
            local expected = {column = "foobar", operator = "eq"}
            local key = "foobar"
            local column_and_operator = FilterBuilder.key_to_operator(key)
            assert.same(expected, column_and_operator)
        end)
    end)

    describe("add_headers", function()

        it("should work no headers", function()
            local url = "http://localhost"
            local request = http_request.new_from_uri(url)
            local default_len = request.headers:len()
            local headers = nil
            local returned_request = FilterBuilder.add_headers(request, headers)
            assert.same(request, returned_request)
            assert.equal(request.headers:len(), default_len)
        end)

        it("should upsert headers", function()
            local url = "http://localhost"
            local request = http_request.new_from_uri(url)
            local default_len = request.headers:len()
            local headers = {key1 = "value1", key2 = "value2"}
            local returned_request = FilterBuilder.add_headers(request, headers)
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
            local filter_builder = FilterBuilder:new(database, table_name)
            filter_builder:filter(filter)
            assert.same(expected, filter_builder.filter_str)
        end)

        it("should work with an operator", function()
            local filter = {id__eq = 1}
            local expected = "id=eq.1"
            local database = nil
            local table_name = nil
            local filter_builder = FilterBuilder:new(database, table_name)
            filter_builder:filter(filter)
            assert.same(expected, filter_builder.filter_str)
        end)

        it("should work with a raw filter", function()
            local filter = "id=eq.1"
            local expected = filter
            local database = nil
            local table_name = nil
            local filter_builder = FilterBuilder:new(database, table_name)
            filter_builder:filter(filter)
            assert.same(expected, filter_builder.filter_str)
        end)

    end)

end)

