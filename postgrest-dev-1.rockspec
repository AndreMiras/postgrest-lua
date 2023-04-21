package = "postgrest"
version = "dev-1"
source = {
    url = "git+https://github.com/AndreMiras/postgrest-lua",
    branch = "main"
}
description = {
    summary = "Basic PostgREST Lua library.",
    detailed = "Basic PostgREST Lua library.",
    homepage = "https://github.com/AndreMiras/postgrest-lua",
    license = "MIT"
}
dependencies = {"http >= 0.4"}
build = {
    type = "builtin",
    modules = {
        ["postgrest.database"] = "postgrest/database.lua",
        ["postgrest.query_builder"] = "postgrest/query_builder.lua",
        ["postgrest.utils"] = "postgrest/utils.lua"
    }
}
