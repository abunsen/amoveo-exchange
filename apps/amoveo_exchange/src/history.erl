% This is a record of the trades that have been completed.
-module(history).
-behaviour(gen_server).
-export([start_link/0,code_change/3,handle_call/3,handle_cast/2,handle_info/2,init/1,terminate/2,
	read/1]).
init(ok) -> {ok, []}.
start_link() -> gen_server:start_link({local, ?MODULE}, ?MODULE, ok, []).
code_change(_OldVsn, State, _Extra) -> {ok, State}.
terminate(_, _) -> io:format("died!"), ok.
handle_info(_, X) -> {noreply, X}.
handle_cast(_, X) -> {noreply, X}.
handle_call({read, Many}, _From, X) -> 
    {reply, X, X};
handle_call(_, _From, X) -> {reply, X, X}.

read(Many) -> gen_server:call(?MODULE, {read, Many}).

%After a payment has been used as part of a trade, we don't want to reuse that same payment for a different trade. So it needs to be removed from the history.
delete(Height, From) ->
    ok.
