-module(trades).
-behaviour(gen_server).
-export([start_link/0,code_change/3,handle_call/3,handle_cast/2,handle_info/2,init/1,terminate/2,
	cron/0,read/1,add/1]).
-record(trade, {veo_from, start_height, bitcoin_address, veo_to, start_time, time_limit, veo_amount, bitcoin_amount, initial_bitcoin_balance}).
-define(LOC, "trades.db").
init(ok) -> 
    process_flag(trap_exit, true),
    D = dict:store(txid, 0, dict:new()),
    utils:init(D, ?LOC).
start_link() -> gen_server:start_link({local, ?MODULE}, ?MODULE, ok, []).
code_change(_OldVsn, State, _Extra) -> {ok, State}.
terminate(_, X) -> 
    utils:save(?LOC, X),
    io:format("died!"), ok.
handle_info(_, X) -> {noreply, X}.
handle_cast(_, X) -> {noreply, X}.
handle_call({add, {From, StartHeight, BitcoinAddress, VeoTo, TimeLimit, VeoAmount, BitcoinAmount}}, _, X) ->
    IB = utils:total_received_bitcoin(BitcoinAddress),
    TXID = dict:fetch(txid, X),
    T = #trade{veo_from = From, start_height = StartHeight, bitcoin_address = BitcoinAddress, veo_to = VeoTo, start_time = erlang:timestamp(), time_limit = TimeLimit, veo_amount = VeoAmount, bitcoin_amount = BitcoinAmount, initial_bitcoin_balance = IB},
    X2 = dict:store(txid, TXID+1, X),
    X3 = dict:store(TXID, T, X2),
    {reply, TXID, X3};
handle_call({read, TXID}, _, X) ->
    Y = dict:find(TXID, X),
    {reply, Y, X};
handle_call(_, _From, X) -> {reply, X, X}.


read(X) -> gen_server:call(?MODULE, {read, X}).
add(X) -> gen_server:call(?MODULE, {add, X}).%return txid
    
update() ->
    %check if any trade is expired. if it is, delete it and move the money in that account from locked to veo.
    %check if any trade has been funded with bitcoin. if it has, then forward those veo to the different account, and delete the trade.
    ok.

cron() ->
    spawn(fun() -> cron2() end).
cron2() ->
    timer:sleep(6000),
    update(),
    cron2().
