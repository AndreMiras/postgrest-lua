LUA_MODULES ?= lua_modules
BUSTED=$(LUA_MODULES)/bin/busted
LUA_CHECK=$(LUA_MODULES)/bin/luacheck
LUA_FORMAT=$(LUA_MODULES)/bin/lua-format
LUA_COVERALLS=$(LUA_MODULES)/bin/luacov-coveralls
FULL_VERSION=$(VERSION)-1
ROCKSPEC=rockspecs/postgrest-$(FULL_VERSION).rockspec
ROCKSPEC_DEV=postgrest-dev-1.rockspec
NODE_PRETTIER=npx prettier
define DEV_DEPENDENCIES
busted \
dkjson \
luacheck \
luacov-coveralls \
luajwtjitsi \
lunajson
endef
ifdef CI
DOCKER_TTY=--no-TTY
endif

# Check that given variables are set and all have non-empty values,
# die with an error otherwise.
# https://stackoverflow.com/a/10858332
#
# Params:
#   1. Variable name(s) to test.
#   2. (optional) Error message to print.
check_defined = \
    $(strip $(foreach 1,$1, \
        $(call __check_defined,$1,$(strip $(value 2)))))
__check_defined = \
    $(if $(value $1),, \
      $(error Undefined $1$(if $2, ($2))))


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
	docker compose exec $(DOCKER_TTY) db \
	psql --set ON_ERROR_STOP=1 --username postgres --file /host/scripts/init.sql && \
	docker compose restart postgrest

luarocks/dev:
	for dependency in $(DEV_DEPENDENCIES); do \
	luarocks install --tree $(LUA_MODULES) $$dependency ; \
	done
	wget https://github.com/Koihik/vscode-lua-format/raw/ea490d1/bin/linux/lua-format -O $(LUA_FORMAT) && \
	chmod +x $(LUA_FORMAT)

luarocks/deps:
	luarocks install --only-deps --tree $(LUA_MODULES) $(ROCKSPEC_DEV)

luarocks: luarocks/dev luarocks/deps

release/prepare:
	@# other variables derive from VERSION
	@:$(call check_defined, VERSION)
	cp $(ROCKSPEC_DEV) $(ROCKSPEC)
	sed 's/version = "dev-1"/version = "'$(FULL_VERSION)'"/' --in-place $(ROCKSPEC)
	sed 's/branch = "main"/tag = "'$(VERSION)'"/' --in-place $(ROCKSPEC)

release/commit:
	@# other variables derive from VERSION
	@:$(call check_defined, VERSION)
	git add $(ROCKSPEC)
	git commit -a -m ":bookmark: $(VERSION)"
	git tag -a $(VERSION) -m ":bookmark: $(VERSION)"

release/push:
	@:$(call check_defined, VERSION)
	git push
	git push origin $(VERSION)

release: release/prepare release/commit release/push

test:
	$(BUSTED) --verbose --coverage postgrest/

coveralls:
	$(LUA_COVERALLS) --verbose

lint/luacheck:
	$(LUA_CHECK) postgrest/*.lua

lint/luaformatter:
	$(LUA_FORMAT) --check *.rockspec postgrest/*.lua

lint/nodeprettier:
	$(NODE_PRETTIER) --check *.md docs/ .github/

lint: lint/luacheck lint/luaformatter lint/nodeprettier

format/luaformatter:
	$(LUA_FORMAT) --in-place *.rockspec postgrest/*.lua

format/nodeprettier:
	$(NODE_PRETTIER) --write *.md docs/ .github/

format: format/luaformatter format/nodeprettier
