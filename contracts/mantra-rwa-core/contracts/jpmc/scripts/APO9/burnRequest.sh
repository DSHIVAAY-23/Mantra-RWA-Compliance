
mantrachaind tx wasm execute \
    tp1qfqq9tz0s7f57dwmd7zmxwhwvjcqvcwv5y7uvrr7xvkwc9uy68wqch75zx \
    '{
    "request": {
        "request_id": "0x1",
        "amount": "22750000000",
        "request_type": "burn"
    }
}' \
    --from $user \
    --custom-denom VeriVaultToken \
    --keyring-backend test \
    --home $prov_path \
    --chain-id mantra-hongbai-1 \
    --gas-prices 0VeriVaultToken \
    --broadcast-mode block \
    --yes \
    --testnet \
	--output json \
	--node=http://34.70.126.95:26657 |  jq
