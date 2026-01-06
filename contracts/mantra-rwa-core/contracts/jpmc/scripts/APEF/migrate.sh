mantrachaind tx wasm migrate \
    tp1emy7mkz3p3kcq3vmxjacud2m255gutwykplyns7z6yemp6mnqppsvlfnup \
    90 \
    '{}' \
    --from "$dev" \
    --keyring-backend test \
    --home $prov_path \
    --chain-id mantra-hongbai-1 \
    --broadcast-mode block \
    --testnet \
    --yes \
    --gas auto \
    --gas-prices 0vspn \
    --node=http://34.70.126.95:26657 \
	--output json | jq

