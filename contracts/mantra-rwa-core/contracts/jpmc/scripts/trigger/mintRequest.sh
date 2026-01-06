
mantrachaind tx wasm execute \
    tp1lu8mr2ge4hz7kd5qky2ysayyrtrgst7yslqd5ekuuqp79m9g9k0qwdeq54 \
    '{
    "request": {
        "request_id": "0x3",
        "amount": "1000",
        "request_type": "mint"
    }
}' \
    --from $dev \
    --custom-denom VeriVaultToken \
    --keyring-backend test \
    --home $prov_path \
    --chain-id mantra-hongbai-1 \
    --gas auto \
    --gas-prices 0VeriVaultToken \
    --broadcast-mode block \
    --yes \
    --testnet \
	--output json \
	--node=http://34.70.126.95:26657 |  jq
