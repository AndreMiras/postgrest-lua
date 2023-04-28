local utils = {}

function utils.require_json()
    local list = {"cjson", "dkjson", "json"}
    for _, lib in ipairs(list) do
        local json_ok, json = pcall(require, lib)
        if json_ok then
            pcall(json.use_lpeg) -- optional feature in dkjson
            return json
        end
    end
end

function utils.table_length(tabl)
    local count = 0
    for _ in pairs(tabl) do count = count + 1 end
    return count
end

function utils.map(func, tabl)
    local new_t = {}
    for i, v in ipairs(tabl) do new_t[i] = func(v) end
    return new_t
end

return utils
