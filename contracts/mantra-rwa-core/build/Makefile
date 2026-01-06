.PHONY: all compile optimize store instantiate

# MANTRA Configuration
CHAIN_ID ?= mantra-hongbai-1
RPC_URL ?= https://rpc.hongbai.mantrachain.io:443
DENOM ?= uom
NODE_IMAGE ?= cosmwasm/rust-optimizer:0.15.0
CONTRACT_DIR ?= ../contracts
ARTIFACTS_DIR ?= ../artifacts

# Build & Optimize Contracts
optimize:
	@echo "🐳 Optimizing contracts via Docker..."
	docker run --rm -v "$(PWD)/..:/code" \
		--mount type=volume,source="$(basename $(PWD))_cache",target=/target \
		--mount type=volume,source=registry_cache,target=/usr/local/cargo/registry \
		$(NODE_IMAGE)

# Development / Native Compile (Fast)
compile:
	@echo "🦀 Compiling locally..."
	cd .. && cargo wasm

# Deployment Helper (Assumes mantrachaind is installed)
store:
	@echo "📦 Uploading contract to $(CHAIN_ID)..."
	mantrachaind tx wasm store $(ARTIFACTS_DIR)/custom_marker.wasm \
		--from deployer \
		--chain-id $(CHAIN_ID) \
		--node $(RPC_URL) \
		--gas auto --gas-adjustment 1.5 \
		-y

# Cleanup
clean:
	rm -rf $(ARTIFACTS_DIR)
	rm -rf ../target
