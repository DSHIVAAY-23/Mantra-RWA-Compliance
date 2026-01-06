wasm=artifacts/marker_factory-aarch64.wasm

mantrachaind tx wasm store $wasm \
    --instantiate-only-address "$dev" \
    --from $dev \
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
