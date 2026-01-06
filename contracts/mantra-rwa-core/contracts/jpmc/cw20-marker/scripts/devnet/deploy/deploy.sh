wasm=artifacts/cw20_marker-aarch64.wasm

mantrachaind tx wasm store $wasm \
    --instantiate-anyof-addresses $dev,tp1v67pppdudcpdddkn8wlgwh7fzwrqjqw7juwxe63fmtnwf758s5fsa7qrla \
    --from $dev \
    --keyring-backend test \
    --home $prov_path \
    --chain-id mantra-hongbai-1 \
    --broadcast-mode block \
    --testnet \
    --gas auto \
    --yes \
    --gas-prices 0vspn \
    --node=http://34.70.126.95:26657 \
	--output json | jq 
