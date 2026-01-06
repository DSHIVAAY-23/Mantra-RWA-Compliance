use cosmwasm_std::Binary;
use serde::{Deserialize, Serialize};
use sp1_sdk::{ProverClient, SP1Stdin};

const ELF: &[u8] = include_bytes!("../../circuits/elf/riscv32im-succinct-zkvm-elf");

#[derive(Serialize, Deserialize)]
struct RwaMetadata {
    jurisdiction: String,
    accreditation_level: String,
    document_hash: String,
}

#[tokio::main]
async fn main() {
    println!("🚀 Z-RWA Proof Generation Starting...\n");

    // 1. Setup SP1 Prover
    let client = ProverClient::new();
    
    println!("✅ SP1 Client initialized");
    println!("📦 Guest program ELF loaded ({} bytes)\n", ELF.len());

    // 2. Prepare inputs for the circuit
    // The circuit expects: query_vec, chunk_vec, threshold, document_hash
    
    // Sample document embedding (384-dimensional vector - typical for MiniLM)
    let query_vec: Vec<f32> = vec![0.1; 384];
    let chunk_vec: Vec<f32> = vec![0.1; 384]; // High similarity for demo
    let threshold: f32 = 0.7;
    
    // Document hash (simulating SHA256 of compliance document)
    let document_hash: [u8; 32] = [
        0x12, 0x34, 0x56, 0x78, 0x9a, 0xbc, 0xde, 0xf0,
        0x12, 0x34, 0x56, 0x78, 0x9a, 0xbc, 0xde, 0xf0,
        0x12, 0x34, 0x56, 0x78, 0x9a, 0xbc, 0xde, 0xf0,
        0x12, 0x34, 0x56, 0x78, 0x9a, 0xbc, 0xde, 0xf0,
    ];

    println!("📝 Input Parameters:");
    println!("   - Query vector dimension: {}", query_vec.len());
    println!("   - Chunk vector dimension: {}", chunk_vec.len());
    println!("   - Similarity threshold: {}", threshold);
    println!("   - Document hash: 0x{}", hex::encode(&document_hash));
    println!();

    // 3. Write inputs to SP1Stdin
    let mut stdin = SP1Stdin::new();
    stdin.write(&query_vec);
    stdin.write(&chunk_vec);
    stdin.write(&threshold);
    stdin.write(&document_hash);

    println!("🔧 Generating Groth16 proof (this may take several minutes)...");
    
    // 4. Generate proof
    let (pk, vk) = client.setup(ELF);
    
    // Use Groth16 proof for on-chain verification
    let proof = client
        .prove(&pk, stdin)
        .groth16()
        .run()
        .expect("Proof generation failed");

    println!("✅ Proof generated successfully!\n");

    // 5. Extract public values
    let public_values = proof.public_values.as_slice();
    
    println!("📊 Proof Details:");
    println!("   - Proof size: {} bytes", proof.bytes().len());
    println!("   - Public values size: {} bytes", public_values.len());
    println!();

    // 6. Verify the proof locally first
    println!("🔍 Verifying proof locally...");
    client
        .verify(&proof, &vk)
        .expect("Proof verification failed");
    
    println!("✅ Local verification successful!\n");

    // 7. Prepare output for CosmWasm contract
    let proof_binary = Binary::from(proof.bytes());
    let public_values_hex = hex::encode(public_values);
    
    let output = serde_json::json!({
        "proof": proof_binary,
        "public_values": public_values_hex,
        "document_hash": hex::encode(&document_hash),
        "metadata": {
            "jurisdiction": "VARA_DUBAI",
            "accreditation": "QUALIFIED_INSTITUTIONAL",
            "proof_system": "SP1_GROTH16"
        }
    });

    println!("📄 Proof Output:");
    println!("{}\n", serde_json::to_string_pretty(&output).unwrap());

    // 8. Write to file for contract submission
    std::fs::write(
        "proof_output.json",
        serde_json::to_string_pretty(&output).unwrap(),
    )
    .expect("Failed to write proof output");

    println!("✅ Proof saved to: proof_output.json");
    println!("\n🎉 Proof generation complete!");
    println!("\n📋 Next steps:");
    println!("   1. Deploy the verifier contract to MANTRA testnet");
    println!("   2. Submit this proof via the MintRwaAsset execute message");
    println!("   3. The contract will verify the proof on-chain");
}
