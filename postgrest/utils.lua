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

return utils
