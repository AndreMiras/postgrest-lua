-- integration tests
local database = require "postgrest.database"
local utils = require "postgrest.utils"
local lunajson = require "lunajson"
local json = utils.require_json()

local api_base_url = "http://localhost:3000"
local default_rows = json.decode([[
    [
        {"id":1,"done":false,"task":"finish tutorial 0","due":null},
        {"id":2,"done":false,"task":"pat self on back","due":null}
    ]
]])

describe("postgrest", function()

    describe("select", function()
        it("should return all rows", function()
            local supabase = database:new(api_base_url)
            local todos = supabase("todos"):select():execute()
            assert.same(default_rows, todos)
        end)

        it("should accept other JSON libraries", function()
            local supabase = database:new(api_base_url)
            local todos = supabase("todos"):select():execute(lunajson)
            assert.same(default_rows, todos)
        end)

        it("should be explicit on missing JSON implementations", function()
            local supabase = database:new(api_base_url)
            stub(utils, "require_json")
            assert.has.errors(function()
                supabase("todos"):select():execute()
            end, utils.MISSING_JSON_IMPLEMENTATION_ERROR)
            assert.stub(utils.require_json).was.called()
            utils.require_json:revert()
        end)
    end)

end)
