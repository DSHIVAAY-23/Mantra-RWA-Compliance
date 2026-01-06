
mantrachaind tx wasm execute \
    tp15vaux4uwcehrkh5t6rhjctkr8z05tmpm9hc5hrgzeu0xxy2gvtxqhdlhyz \
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
