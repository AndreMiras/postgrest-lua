local Database = require "postgrest.database"
local FilterBuilder = require "postgrest.filter_builder"
local utils = require "postgrest.utils"
local match = require("luassert.match")

local mock_request = function(http_request, status, body)
    local json = utils.require_json()
    mock(http_request, true)
    local upsert = function() end
    local headers = {upsert = upsert}
    local get = function() return status end
    local response_headers = {get = get}
    local get_body_as_string = function() return json.encode(body) end
    local stream = {get_body_as_string = get_body_as_string}
    local go = function() return response_headers, stream end
    local request = {headers = headers, go = go}
    local new_from_uri = spy.new(function() return request end)
    http_request.new_from_uri = new_from_uri
end

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

        it("should work with single underscore", function()
            local expected = {column = "foo_bar", operator = "eq"}
            local key = "foo_bar"
            local column_and_operator = FilterBuilder.key_to_operator(key)
            assert.same(expected, column_and_operator)
        end)

        it("should work with single underscore and an operator", function()
            local expected = {column = "foo_bar", operator = "lte"}
            local key = "foo_bar__lte"
            local column_and_operator = FilterBuilder.key_to_operator(key)
            assert.same(expected, column_and_operator)
        end)

    end)

    describe("add_headers", function()

        it("should work no headers", function()
            local http_request = require "http.request"
            local url = "http://localhost"
            local request = http_request.new_from_uri(url)
            local default_len = request.headers:len()
            local headers = nil
            local returned_request = FilterBuilder.add_headers(request, headers)
            assert.same(request, returned_request)
            assert.equal(request.headers:len(), default_len)
        end)

        it("should upsert headers", function()
            local http_request = require "http.request"
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

        it("should work with a raw a list of numbers", function()
            local filter = {id__in = {1, 2, 3}}
            local expected = "id=in.(1,2,3)"
            local database = nil
            local table_name = nil
            local filter_builder = FilterBuilder:new(database, table_name)
            filter_builder:filter(filter)
            assert.same(expected, filter_builder.filter_str)
        end)

        it("should work with a raw a list of strings", function()
            local filter = {id__in = {"foo", "bar", "foo,bar"}}
            local expected = 'id=in.("foo","bar","foo,bar")'
            local database = nil
            local table_name = nil
            local filter_builder = FilterBuilder:new(database, table_name)
            filter_builder:filter(filter)
            assert.same(expected, filter_builder.filter_str)
        end)

    end)

    describe("execute", function()
        local http_request
        before_each(function() http_request = require "http.request" end)

        after_each(function() mock.revert(http_request) end)

        it("should return the response body", function()
            local status = 200
            local expected_response_body = "body"
            mock_request(http_request, status, expected_response_body)
            local api_base_url = "api_base_url"
            local database = mock(Database:new(api_base_url), true)
            local table_name = "table_name"
            local method = "GET"
            local query_parameters = {}
            local payload = {}
            local filter_builder = FilterBuilder:new(database, table_name,
                                                     method, query_parameters,
                                                     payload)
            local response_body = filter_builder:execute()
            assert.same(expected_response_body, response_body)
        end)

        it("should log the request", function()
            local status = 200
            local expected_response_body = "body"
            mock_request(http_request, status, expected_response_body)
            local api_base_url = "api_base_url"
            local database = mock(Database:new(api_base_url), true)
            local request_logger = spy.new(function() end)
            database.request_logger = request_logger
            local table_name = "table_name"
            local url = api_base_url .. "/" .. table_name
            local method = "GET"
            local query_parameters = {}
            local payload = {}
            local any = match._
            local filter_builder = FilterBuilder:new(database, table_name,
                                                     method, query_parameters,
                                                     payload)
            local response_body = filter_builder:execute()
            assert.same(expected_response_body, response_body)
            assert.spy(request_logger).was.called_with(method, url, any, any)
        end)

    end)

end)

