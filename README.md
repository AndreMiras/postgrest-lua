# PostgREST Lua

[![Unit tests](https://github.com/AndreMiras/postgrest-lua/actions/workflows/unittests.yml/badge.svg)](https://github.com/AndreMiras/postgrest-lua/actions/workflows/unittests.yml)
[![Coverage Status](https://coveralls.io/repos/github/AndreMiras/postgrest-lua/badge.svg)](https://coveralls.io/github/AndreMiras/postgrest-lua)
[![Publish](https://github.com/AndreMiras/postgrest-lua/actions/workflows/publish.yml/badge.svg)](https://github.com/AndreMiras/postgrest-lua/actions/workflows/publish.yml)
[![LuaRocks](https://img.shields.io/luarocks/v/AndreMiras/postgrest)](https://luarocks.org/modules/AndreMiras/postgrest)

A Lua library for PostgREST.

## Roadmap

- [x] authentication support
- [x] insert support
- [x] select support
  - [x] basic (select wildcard)
  - [x] vertical filtering
  - [x] horizontal filtering
- [x] update support
- [x] delete support
- [ ] RPC support

## Install

```sh
luarocks install postgrest
```

We also need to install one JSON library such as `cjson` or `dkjson`:

```sh
luarocks install dkjson
```

## Usage

With PostgREST:

```lua
local Database = require "postgrest.database"
local cjson = require "cjson"
local api_base_url = "http://localhost:3000"
local db_instance = Database:new(api_base_url)
local todos = db_instance:from("todos"):select():execute()
-- or alternatively
local todos = db_instance("todos"):select():execute()
cjson.encode(todos)
```

With Supabase:

```lua
local Database = require "postgrest.database"
local cjson = require "cjson"
local project_id = os.getenv("SUPABASE_PROJECT_ID")
local public_anon_key = os.getenv("SUPABASE_PUBLIC_ANON_KEY")
local service_role_key = os.getenv("SUPABASE_SERVICE_ROLE_KEY")
local api_base_url = "https://" .. project_id .. ".supabase.co/rest/v1"
local auth_headers = {apikey = public_anon_key, authorization = "Bearer " .. service_role_key}
local supabase = Database:new(api_base_url, auth_headers)
local todos = supabase:from("todos"):select():execute()
cjson.encode(todos)
```

Injecting a JSON library:

```lua
local lunajson = require "lunajson"
Database:set_json_implementation(lunajson)
local todos = Database:from("todos"):select():execute()
```

Insert:

```lua
local values = {done = true, task = "insert support"}
db_instance:from("todos"):insert(values):execute()
```

Vertical filtering:

```lua
QueryBuilder:select("column1", "column2")
-- or alternatively
QueryBuilder:select{"column1", "column2"}
```

Horizontal filtering:

```lua
db_instance:from("todos"):select():filter{id__eq = 1}:execute()
-- or alternatively
db_instance:from("todos"):select():filter{id = 1}:execute()
-- or alternatively
db_instance:from("todos"):select():filter("id=eq.1"):execute()
-- we also support the `in` operator using tables:
db_instance:from("todos"):select():filter{id__in = {1, 2, 3}}:execute()
```

Same goes for other operators described in the PostgREST documentation:
https://postgrest.org/en/stable/api.html#operators

Updates:

```lua
local values = {done = true, task = "learn lua"}
db_instance:from("todos"):update(values):execute()
```

Delete:

```lua
db_instance:from("todos"):delete():filter{id = 4}:execute()
```

## Logger

It's possible to log the requests to the REST API by using a logger callback.

```lua
function request_logger(method, url, payload, headers)
    print("method: " .. method .. " url: " .. url)
end
Database.request_logger = request_logger
```

## Development

### Tests

Install dependencies:

```sh
make luarocks
```

Start the PostgreSQL database, the PostgREST service and load fixtures:

```sh
make docker/compose/recreate
make docker/compose/psql/init
```

Then run the tests:

```sh
make test
```

Teardown everything:

```sh
make docker/compose/down
```

### Format & Lint

```sh
make format
make lint
```
