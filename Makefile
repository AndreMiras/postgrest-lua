LUA_MODULES ?= lua_modules
BUSTED=$(LUA_MODULES)/bin/busted
LUA_CHECK=$(LUA_MODULES)/bin/luacheck
LUA_FORMAT=$(LUA_MODULES)/bin/lua-format
NODE_PRETTIER=npx prettier
define DEV_DEPENDENCIES
busted \
luacheck
endef
ifdef CI
DOCKER_TTY=--no-TTY
endif


docker/compose/recreate:
	# make sure we start from a clean environment (to please the CI)
	docker compose down --volumes
	docker compose up --no-start --force-recreate
	docker compose start

docker/compose/down:
	docker-compose down --volumes

docker/compose/psql:
	docker compose exec db psql --username postgres

docker/compose/psql/init:
	docker compose exec $(DOCKER_TTY) db psql --set ON_ERROR_STOP=1 --username postgres --file /host/scripts/init.sql

luarocks/dev:
	for dependency in $(DEV_DEPENDENCIES); do \
	luarocks install --tree $(LUA_MODULES) $$dependency ; \
	done
	luarocks install --tree $(LUA_MODULES) --server=https://luarocks.org/dev luaformatter

test:
	$(BUSTED) postgrest/

lint/luacheck:
	$(LUA_CHECK) postgrest/*.lua

lint/luaformatter:
	$(LUA_FORMAT) --check *.rockspec postgrest/*.lua

lint/nodeprettier:
	$(NODE_PRETTIER) --check *.md docs/ .github/

lint: lint/luacheck lint/luaformatter

format/luaformatter:
	$(LUA_FORMAT) --in-place *.rockspec postgrest/*.lua

format/nodeprettier:
	$(NODE_PRETTIER) --write *.md docs/ .github/

format: format/luaformatter format/nodeprettier
