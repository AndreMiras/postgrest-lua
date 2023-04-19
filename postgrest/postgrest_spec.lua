-- integration tests
local database = require "postgrest.database"
local cjson = require "cjson"

local api_base_url = "http://localhost:3000"
local default_rows = cjson.decode([[
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
    end)

end)
