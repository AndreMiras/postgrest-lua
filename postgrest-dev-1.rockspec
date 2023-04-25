package = "postgrest"
version = "dev-1"
source = {
    url = "git+https://github.com/AndreMiras/postgrest-lua",
    branch = "main"
}
description = {
    summary = "PostgREST Lua library.",
    detailed = "A PostgREST (and Supabase) library written in pure Lua",
    homepage = "https://github.com/AndreMiras/postgrest-lua",
    license = "MIT"
}
dependencies = {"http >= 0.4"}
build = {
    type = "builtin",
    modules = {
        ["postgrest.constants"] = "postgrest/constants.lua",
        ["postgrest.database"] = "postgrest/database.lua",
        ["postgrest.filter_builder"] = "postgrest/filter_builder.lua",
        ["postgrest.query_builder"] = "postgrest/query_builder.lua",
        ["postgrest.utils"] = "postgrest/utils.lua"
    }
}
