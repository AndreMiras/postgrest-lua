LUA_MODULES ?= lua_modules
BUSTED=$(LUA_MODULES)/bin/busted
LUA_CHECK=$(LUA_MODULES)/bin/luacheck
LUA_FORMAT=$(LUA_MODULES)/bin/lua-format
NODE_PRETTIER=npx prettier
define DEV_DEPENDENCIES
busted \
luacheck
endef


docker-compose/psql:
	docker-compose exec db psql --username postgres

docker-compose/psql/init:
	docker-compose exec db psql --username postgres --file /host/scripts/init.sql

luarocks/dev:
	for dependency in $(DEV_DEPENDENCIES); do \
	luarocks install --tree $(LUA_MODULES) $$dependency ; \
	done
	luarocks install --tree $(LUA_MODULES) --server=https://luarocks.org/dev luaformatter

test:
	$(BUSTED) src/

lint/luacheck:
	$(LUA_CHECK) src/*.lua

lint/luaformatter:
	$(LUA_FORMAT) --check *.rockspec src/*.lua

lint/nodeprettier:
	$(NODE_PRETTIER) --check *.md .github/

lint: lint/luacheck lint/luaformatter

format/luaformatter:
	$(LUA_FORMAT) --in-place *.rockspec src/*.lua

format/nodeprettier:
	$(NODE_PRETTIER) --write *.md .github/

format: format/luaformatter format/nodeprettier
