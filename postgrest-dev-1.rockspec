package = "postgrest"
version = "dev-1"
source = {url = "git+https://github.com/AndreMiras/postgrest-lua"}
description = {
    summary = "Basic PostgREST Lua library.",
    detailed = "Basic PostgREST Lua library.",
    homepage = "https://github.com/AndreMiras/postgrest-lua",
    license = "MIT"
}
dependencies = {"lua-cjson >= 2.1", "http >= 0.4"}
build = {
    type = "builtin",
    modules = {
        database = "src/database.lua",
        postgrest_spec = "src/postgrest_spec.lua",
        query_builder = "src/query_builder.lua"
    }
}
