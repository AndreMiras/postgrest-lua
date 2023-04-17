LUA_MODULES ?= lua_modules
BUSTED=$(LUA_MODULES)/bin/busted
LUA_CHECK=$(LUA_MODULES)/bin/luacheck
LUA_FORMAT=$(LUA_MODULES)/bin/lua-format
NODE_PRETTIER=npx prettier


docker-compose/psql:
	docker-compose exec db psql --username postgres

docker-compose/psql/init:
	docker-compose exec db psql --username postgres --file /host/scripts/init.sql

test:
	$(BUSTED) src/

lint/luacheck:
	$(LUA_CHECK) src/*.lua

lint/luaformatter:
	$(LUA_FORMAT) --check src/*.lua

lint/nodeprettier:
	$(NODE_PRETTIER) --check *.md

lint: lint/luacheck lint/luaformatter

format/luaformatter:
	$(LUA_FORMAT) --in-place src/*.lua

format/nodeprettier:
	$(NODE_PRETTIER) --write *.md

format: format/luaformatter format/nodeprettier
