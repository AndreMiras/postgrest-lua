# PostgREST Lua

[![Unit tests](https://github.com/AndreMiras/postgrest-lua/actions/workflows/unittests.yml/badge.svg)](https://github.com/AndreMiras/postgrest-lua/actions/workflows/unittests.yml)
[![Publish](https://github.com/AndreMiras/postgrest-lua/actions/workflows/publish.yml/badge.svg)](https://github.com/AndreMiras/postgrest-lua/actions/workflows/publish.yml)
[![LuaRocks](https://img.shields.io/luarocks/v/AndreMiras/postgrest)](https://luarocks.org/modules/AndreMiras/postgrest)

Naive PostgREST Lua library.

## Roadmap

- [x] authentication support
- [ ] insert support
- [x] select support
  - [x] basic (select wildcard)
  - [x] vertical filtering
  - [x] horizontal filtering
- [ ] update support
- [ ] delete support

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
local database = require "postgrest.database"
local cjson = require "cjson"
local api_base_url = "http://localhost:3000"
local supabase = database:new(api_base_url)
local todos = supabase:from("todos"):select():execute()
cjson.encode(todos)
```

With Supabase:

```lua
local database = require "postgrest.database"
local cjson = require "cjson"
local project_id = os.getenv("SUPABASE_PROJECT_ID")
local public_anon_key = os.getenv("SUPABASE_PUBLIC_ANON_KEY")
local service_role_key = os.getenv("SUPABASE_SERVICE_ROLE_KEY")
local api_base_url = "https://" .. project_id .. ".supabase.co/rest/v1/"
local auth_headers = {apikey = public_anon_key, authorization = "Bearer " .. service_role_key}
local supabase = database:new(api_base_url, auth_headers)
local todos = supabase:from("todos"):select():execute()
cjson.encode(todos)
```

Injecting a JSON library:

```lua
local lunajson = require 'lunajson'
local todos = supabase("rest/v1/todos"):select():execute(lunajson)
```

Vertical filtering:

```lua
QueryBuilder:select("column1", "column2")
-- or alternatively
QueryBuilder:select{"column1", "column2"}
```

Horizontal filtering:

```lua
supabase:from("todos"):select():filter{id__eq = 1}:execute()
-- or alternatively
supabase:from("todos"):select():filter{id = 1}:execute()
-- or alternatively
supabase:from("todos"):select():filter("id=eq.1"):execute()
```

Same goes for other operators described in the PostgREST documentation:
https://postgrest.org/en/stable/api.html#operators

## Development

### Tests

Install dev dependencies:

```sh
luarocks/dev
```

Start the PostgreSQL database and the PostgREST service:

```sh
docker compose up
```

Then run the tests:

```sh
make test
```

### Format & Lint

```sh
make format
make lint
```
