
mantrachaind tx wasm execute \
    tp16t96gk6telazd5f9uvxynxdtzf0503vqw6fsvrkq2lxzg9vmc98qdyavdg \
    '{
    "request": {
        "request_id": "0x2",
        "amount": "2000000",
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
