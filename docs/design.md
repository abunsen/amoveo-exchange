
The trade's status goes through these stages:
1) unconfirmed
2) unmatched
3) partially matched
4) matched


during step 1 the trade is owned by the unconfirmed gen_server.
- the trade is confirmed once it is fully funded. If it runs out of time before then, it can go stale. And a refund is sent to the trader.

during steps 2 and 3 the trade is owned by the order_book gen_server.
- from the order book a trade can either be matched, or if it runs out of time it can go stale.

During step 4 the trade is owned by the trade history gen_server.

Additionally, we have a gen_server for knowing which stage the trade is in so we know where to look it up.