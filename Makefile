ERL          ?= erl
EBIN_DIRS    := $(wildcard deps/*/ebin)
APP          := gen_rabbit

all: rabbitmq-server rabbitmq-erlang-client erl 

erl: ebin/$(APP).app src/$(APP).app.src
	@$(ERL) -pa ebin -pa $(EBIN_DIRS) -noinput +B \
	  -eval 'case make:all() of up_to_date -> halt(0); error -> halt(1) end.'
rabbitmq-server:
	@(cd deps/rabbitmq-server;$(MAKE))

rabbitmq-erlang-client:
	@(cd deps/rabbitmq-erlang-client;$(MAKE) BROKER_DIR=../rabbitmq-server)


docs:
	@erl -noshell -run edoc_run application '$(APP)' '"."' '[]'

clean:
	@echo "removing:"
	@rm -fv ebin/*.beam ebin/*.app

dialyzer: erl 
	@dialyzer -Wno_return -c ebin/ | tee priv/log/dialyzer.log

ebin/$(APP).app: src/$(APP).app.src
	@echo "generating ebin/gen_rabbit.app"
	@bash support/bin/make_appfile.sh >ebin/gen_rabbit.app	