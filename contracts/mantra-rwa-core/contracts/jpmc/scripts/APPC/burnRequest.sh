
mantrachaind tx wasm execute \
    tp1jlefmscn0yfyg5fm2vwjxazwxxgtnp20dvx2fauvm7af2ucevvdqd3afls \
    '{
    "request": {
        "request_id": "0x5",
        "amount": "1800000000",
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
	--node=http://34.70.126.95:26657 |  jq '.txhash, .code'
