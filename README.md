# PostgREST Lua

[![Unit tests](https://github.com/AndreMiras/postgrest-lua/actions/workflows/unittests.yml/badge.svg)](https://github.com/AndreMiras/postgrest-lua/actions/workflows/unittests.yml)
[![Publish](https://github.com/AndreMiras/postgrest-lua/actions/workflows/publish.yml/badge.svg)](https://github.com/AndreMiras/postgrest-lua/actions/workflows/publish.yml)

Basic PostgREST Lua library.

This is still at a very early stage of development and the API will certainly change.

## Roadmap

- [x] authentication support
- [ ] insert support
- [ ] select support
  - [x] basic (select wildcard)
  - [ ] column selection
  - [ ] filtering
- [ ] update support
- [ ] delete support

## Install

```sh
luarocks install --server=https://luarocks.org/dev postgrest
```

## Usage

With PostgREST:

```lua
local database = require("postgrest.database")
local api_base_url = "http://localhost:3000"
local supabase = database:new(api_base_url)
local todos = supabase("todos"):select():execute()
```

With Supabase:

```lua
local database = require("postgrest.database")
local service_role_key = os.getenv("SERVICE_ROLE_KEY")
local auth_headers = {apikey = service_role_key}
local api_base_url = "https://<project-id>.supabase.co"
local supabase = database:new(api_base_url, auth_headers)
local todos = supabase("todos"):select():execute()
```

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
