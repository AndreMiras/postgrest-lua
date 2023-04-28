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

    describe("map", function()

        it("should return a new table and not mutate the original", function()
            local expected = {2, 4, 6}
            local func = function(value) return value * 2 end
            local tabl = {1, 2, 3}
            local new_table = utils.map(func, tabl)
            assert.same(expected, new_table)
            assert.same(tabl, {1, 2, 3})
        end)

    end)

end)
