%we are waiting for a confirmed veo tx to know that the customer has funded their side of the trade.

-module(unconfirmed_veo).
-behaviour(gen_server).
-export([start_link/0,code_change/3,handle_call/3,handle_cast/2,handle_info/2,init/1,terminate/2,
	 read/1, trade/2, confirm/1, test/0]).
-include("records.hrl").
init(ok) -> {ok, dict:new()}.
start_link() -> gen_server:start_link({local, ?MODULE}, ?MODULE, ok, []).
code_change(_OldVsn, State, _Extra) -> {ok, State}.
terminate(_, _) -> io:format("died!"), ok.
handle_info(_, X) -> {noreply, X}.
handle_cast({trade, Trade, TID}, X) -> 
    X2 = dict:store(TID, Trade, X),
    id_lookup:add_veo(TID),
    {noreply, X2};
handle_cast(_, X) -> {noreply, X}.
handle_call({erase, TID}, _From, X) -> 
    Y = dict:erase(TID, X),
    {reply, Y, X};
handle_call({read, TID}, _From, X) -> 
    Y = dict:find(TID, X),
    {reply, Y, X};
handle_call(_, _From, X) -> {reply, X, X}.

read(TID) ->
    gen_server:call(?MODULE, {read, TID}).
trade(Trade, TID) ->%adds a new trade to the gen_server's memory.
    gen_server:cast(?MODULE, {trade, Trade, TID}).
remove(TID) ->
    Trade = read(TID),
    VA = Trade#trade.veo_address,
    accounts_history_veo:remove(TID, VA),
    gen_server:cast(?MODULE, {erase, TID}).

confirm(TID) ->
    Trade = read(TID),
    VA = Trade#trade.veo_address,
    B = account_history_veo:read(VA),
    Fee = config:fee(veo),
    TA = Trade#trade.veo_amount + Fee,
    if
	(B < TA) -> ok;
	true -> 
	    id_lookup:confirm(TID),
	    account_history_veo:remove(TA, VA),
	    remove(TID)
    end.

test() ->
    TID = crypto:strong_rand_bytes(32),
    Trade = #trade{},
    trade(Trade, TID),
    {ok, Trade} = read(TID),
    remove(TID),
    success.
    
