# PostgREST Lua

[![Unit tests](https://github.com/AndreMiras/postgrest-lua/actions/workflows/unittests.yml/badge.svg)](https://github.com/AndreMiras/postgrest-lua/actions/workflows/unittests.yml)

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

## Usage

```lua
local database = require("postgrest.database")
local api_base_url = "http://localhost:3000"
local supabase = database:new(api_base_url)
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
docker-compose start
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
