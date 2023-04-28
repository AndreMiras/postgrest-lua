-- integration tests
local constants = require "postgrest.constants"
local Database = require "postgrest.database"
local FilterBuilder = require "postgrest.filter_builder"
local utils = require "postgrest.utils"
local http_request = require "http.request"
local jwt = require "luajwtjitsi"
local lunajson = require "lunajson"
local json = utils.require_json()

local jwt_secret = "27oAeYPHQfrmWQfOV9zRQLjlk20ROq7V"
local api_base_url = "http://localhost:3000"
local default_rows = json.decode([[
    [
        {"id":1, "done": true, "task":"finish tutorial 0","due": null},
        {"id":2, "done": true, "task":"pat self on back","due": null},
        {"id":3, "done": true, "task":"learn how to auth","due": null},
        {"id":4, "done": false, "task":"write the lua library","due": null}
    ]
]])

local function jwt_encode(role)
    local payload = {role = role}
    local algo = "HS256"
    local token, err = jwt.encode(payload, jwt_secret, algo)
    if err then error(err) end
    return token
end

describe("postgrest", function()

    describe("select", function()

        it("should return all rows", function()
            local database = Database:new(api_base_url)
            local todos = database:from("todos"):select():execute()
            assert.same(default_rows, todos)
        end)

        it("should return all rows using *", function()
            local database = Database:new(api_base_url)
            local todos = database:from("todos"):select("*"):execute()
            assert.same(default_rows, todos)
        end)

        it("from keyword can be skipped", function()
            local database = Database:new(api_base_url)
            local todos = database("todos"):select():execute()
            assert.same(default_rows, todos)
        end)

        it("should accept other JSON libraries", function()
            local database = Database:new(api_base_url)
            local todos = database:from("todos"):select():execute(lunajson)
            assert.same(default_rows, todos)
        end)

        it("should be explicit on missing JSON implementations", function()
            local database = Database:new(api_base_url)
            stub(utils, "require_json")
            assert.has.errors(function()
                database:from("todos"):select():execute()
            end, constants.MISSING_JSON_IMPLEMENTATION_ERROR)
            assert.stub(utils.require_json).was.called()
            utils.require_json:revert()
        end)

        it("should be allow to override the JSON implementation", function()
            local expected = "foo"
            local database = Database:new(api_base_url)
            assert.is_nil(database.json_implementation)
            database:set_json_implementation(expected)
            -- note how the method returns self, so it can be chained
            assert.are.equal(database,
                             database:set_json_implementation(expected))
            assert.are.equal(expected, database.json_implementation)
        end)

        it("should allow vertical filtering", function()
            local expected = {
                {id = 1, task = "finish tutorial 0"},
                {id = 2, task = "pat self on back"},
                {id = 3, task = "learn how to auth"},
                {id = 4, task = "write the lua library"}
            }
            local database = Database:new(api_base_url)
            local todos = database:from("todos"):select("id", "task"):execute()
            assert.same(expected, todos)
        end)

        it("should allow horizontal filtering eq", function()
            local expected = {{id = 1, task = "finish tutorial 0"}}
            local database = Database:new(api_base_url)
            local todos = database:from("todos"):select("id", "task"):filter{
                id = 1
            }:execute()
            assert.same(expected, todos)
        end)

        it("should allow horizontal filtering neq", function()
            local expected = {
                {id = 2, done = true, task = "pat self on back"},
                {id = 3, done = true, task = "learn how to auth"},
                {id = 4, done = false, task = "write the lua library"}
            }
            local database = Database:new(api_base_url)
            local todos = database:from("todos"):select("id", "task", "done")
                              :filter{id__neq = 1}:execute()
            assert.same(expected, todos)
        end)

        it("should allow horizontal filtering on multiple values", function()
            local expected = {
                {id = 2, done = true, task = "pat self on back"},
                {id = 3, done = true, task = "learn how to auth"}
            }
            local database = Database:new(api_base_url)
            local todos = database:from("todos"):select("id", "task", "done")
                              :filter{id__neq = 1, done__is = true}:execute()
            assert.same(expected, todos)
        end)

        it("should allow raw filter expressions", function()
            local expected = {{id = 1, task = "finish tutorial 0"}}
            local database = Database:new(api_base_url)
            local todos = database:from("todos"):select("id", "task"):filter(
                              "id=eq.1"):execute()
            assert.same(expected, todos)
        end)

        it("should allow horizontal filtering in operator", function()
            local expected = {
                {id = 2, done = true, task = "pat self on back"},
                {id = 3, done = true, task = "learn how to auth"}
            }
            local database = Database:new(api_base_url)
            local todos = database:from("todos"):select("id", "task", "done")
                              :filter{id__in = {2, 3}}:execute()
            assert.same(expected, todos)
            -- should also work with strings
            todos = database:from("todos"):select("id", "task", "done"):filter{
                task__in = {"pat self on back", "learn how to auth"}
            }:execute()
            assert.same(expected, todos)
        end)

    end)

    describe("update", function()

        local token = jwt_encode("todo_user")

        after_each(function()
            local postgres_token = jwt_encode("postgres")
            local url = api_base_url .. "/rpc/create_and_populate_todos"
            local request = http_request.new_from_uri(url)
            request.headers:upsert(":method", "POST")
            request.headers:upsert("content-type", "application/json")
            request.headers:upsert("authorization", "Bearer " .. postgres_token)
            local headers, stream = assert(request:go())
            FilterBuilder.raise_for_status(headers, stream)
        end)

        it("should not have the permission to update", function()
            local database = Database:new(api_base_url)
            local values = {task = "No permission to update without a token"}
            local error_message =
                'Request failed with status: 401 and body: ' ..
                    '{"code":"42501","details":null,"hint":null,' ..
                    '"message":"permission denied for table todos"}'
            assert.has.errors(function()
                database:from("todos"):update(values):execute()
            end, error_message)
            -- data is unchanged
            local todos = database:from("todos"):select():execute()
            assert.same(default_rows, todos)
        end)

        it("should update all rows", function()
            local task = "Oops overridden everything"
            local expected = {
                {id = 1, done = true, task = task},
                {id = 2, done = true, task = task},
                {id = 3, done = true, task = task},
                {id = 4, done = false, task = task}
            }
            local auth_headers = {authorization = "Bearer " .. token}
            local database = Database:new(api_base_url, auth_headers)
            local values = {task = task}
            database:from("todos"):update(values):execute()
            local todos = database:from("todos"):select("id", "done", "task")
                              :execute()
            assert.same(expected, todos)
        end)

        it("should update specific rows", function()
            local expected = {
                {id = 1, done = true, task = "finish tutorial 0"},
                {id = 2, done = true, task = "pat self on back"},
                {id = 3, done = true, task = "learn how to auth"},
                {id = 4, done = true, task = "learn lua"}
            }
            local auth_headers = {authorization = "Bearer " .. token}
            local database = Database:new(api_base_url, auth_headers)
            local values = {done = true, task = "learn lua"}
            database:from("todos"):update(values):filter{id = 4}:execute()
            local todos = database:from("todos"):select("id", "done", "task")
                              :execute()
            assert.same(expected, todos)
        end)

    end)

end)
