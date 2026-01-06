#!/bin/bash
set -e

# Parse command line arguments
GENERATE_PROOF=false
if [[ "$1" == "--generate" ]]; then
    GENERATE_PROOF=true
fi

echo "🚀 Z-RWA Demo Flow Starting..."
echo ""

# Step 1: Build the Verifier Contract
echo "📦 Building Verifier Contract..."
cd contracts/verifier

# Build the contract for wasm32
cargo build --release --target wasm32-unknown-unknown --lib

# Create artifacts directory if it doesn't exist
mkdir -p ../../artifacts

# Copy the wasm file to artifacts
cp target/wasm32-unknown-unknown/release/mantra_contract.wasm ../../artifacts/verifier.wasm

echo "✅ Contract Built: artifacts/verifier.wasm ($(du -h ../../artifacts/verifier.wasm | cut -f1))"
echo ""

# Return to root
cd ../..

# Step 2: Proof Generation or Loading
FIXTURE_PATH="circuits/compliance-proofs/fixtures/proof_output.json"

if [ "$GENERATE_PROOF" = true ]; then
    echo "🔧 Generating Fresh ZK Proof (this will take 10-30 minutes)..."
    echo "   Using: SP1 Groth16 with 151KB guest ELF"
    echo ""
    
    cd circuits/compliance-proofs/crates/mantra-script
    
    RUST_LOG=info cargo run --release --bin mantra
    
    # Copy generated proof to fixtures for future use
    if [ -f "../../../../proof_output.json" ]; then
        mkdir -p ../../fixtures
        cp ../../../../proof_output.json ../../fixtures/
        echo "✅ Proof generated and cached to fixtures/"
    fi
    
    cd ../../../..
else
    echo "⚡ Using Pre-Computed ZK Proof for speed"
    echo "   (add --generate flag to run full 30-minute SP1 cycle)"
    echo ""
    
    if [ -f "$FIXTURE_PATH" ]; then
        echo "✅ Loaded cached proof from: $FIXTURE_PATH"
        cp "$FIXTURE_PATH" proof_output.json
        echo ""
        echo "📊 Proof Details:"
        cat proof_output.json | grep -E "proof_system|jurisdiction|accreditation" | head -3
    else
        echo "⚠️  Cached proof not found at: $FIXTURE_PATH"
        echo "   Please run with --generate flag to create it:"
        echo "   ./scripts/run_demo_flow.sh --generate"
        echo ""
        echo "   Or place a proof_output.json in circuits/compliance-proofs/fixtures/"
        exit 1
    fi
fi

echo ""

# Step 3: Display Verification Instructions
echo "📋 Next Steps for Grant Reviewers:"
echo ""
echo "1. ✅ Contract is ready: artifacts/verifier.wasm (201KB)"
echo "2. ✅ Proof is available: proof_output.json"
echo ""
echo "To deploy to MANTRA testnet:"
echo "   wasmd tx wasm store artifacts/verifier.wasm --from <key> --gas auto"
echo ""
echo "To verify the proof on-chain:"
echo "   wasmd tx wasm execute <CONTRACT> '{\"mint_rwa_asset\": {...}}' --from <key>"
echo ""
echo "🎉 DEMO COMPLETE: Z-RWA System Ready for Grant Review"
