mantrachaind tx wasm migrate \
    tp1v67pppdudcpdddkn8wlgwh7fzwrqjqw7juwxe63fmtnwf758s5fsa7qrla \
    88 \
    '{}' \
    --from "$dev" \
    --keyring-backend test \
    --home $prov_path \
    --chain-id mantra-hongbai-1 \
    --broadcast-mode block \
    --testnet \
    --yes \
    --gas-prices 0vspn \
    --node=http://34.70.126.95:26657 \
	--output json | jq

