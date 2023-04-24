local utils = require "postgrest.utils"

describe("utils", function()

    describe("table_length", function()

        it("should return the real table length", function()
            local expected_length = 2
            local tabl = {key1 = "value1", key2 = "value2"}
            local length = utils.table_length(tabl)
            -- the built-in `#` operator is misbehaving by design
            assert.are.equal(#tabl, 0)
            -- the utils function is working as expected
            assert.are.equal(expected_length, length)
        end)

    end)

end)
