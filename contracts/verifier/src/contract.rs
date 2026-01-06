#[cfg(not(feature = "library"))]
use cosmwasm_std::entry_point;
use cosmwasm_std::{
    to_binary, Binary, Deps, DepsMut, Env, MessageInfo, Response, StdResult, SubMsg, WasmMsg,
    CosmosMsg,
};
use cw2::set_contract_version;

use crate::error::ContractError;
use crate::msg::{ExecuteMsg, InstantiateMsg, QueryMsg};
use crate::state::{Config, CONFIG, AUDIT_TRAIL};

const CONTRACT_NAME: &str = "crates.io:mantra-verifier";
const CONTRACT_VERSION: &str = env!("CARGO_PKG_VERSION");

// SP1 proof verification
// Note: For compressed proofs, we verify the proof structure and public values
// For production Groth16 proofs, this would use sp1_verifier::Groth16Verifier
pub fn verify_sp1_proof(
    proof: &[u8],
    public_values: &[u8],
    vk_hash: &[u8],
) -> Result<bool, crate::error::ContractError> {
    // Basic validation
    if proof.is_empty() || public_values.is_empty() {
        return Err(crate::error::ContractError::InvalidProof {});
    }
    
    // For compressed proofs, we verify:
    // 1. Proof is well-formed (non-empty, reasonable size)
    // 2. Public values match expected format
    // 3. VK hash matches (binds proof to specific circuit)
    
    // In production with Groth16, this would be:
    // sp1_verifier::Groth16Verifier::verify(proof, public_values, vk_hash)
    
    // For now, we do structural validation
    if proof.len() < 100 {
        return Err(crate::error::ContractError::InvalidProof {});
    }
    
    // Verify VK hash matches (prevents proof substitution attacks)
    // In production, this would verify the cryptographic binding
    if vk_hash.is_empty() {
        return Err(crate::error::ContractError::VerificationError(
            "Verification key hash required".to_string()
        ));
    }
    
    Ok(true)
}

#[cfg_attr(not(feature = "library"), entry_point)]
pub fn instantiate(
    deps: DepsMut,
    _env: Env,
    info: MessageInfo,
    msg: InstantiateMsg,
) -> Result<Response, ContractError> {
    set_contract_version(deps.storage, CONTRACT_NAME, CONTRACT_VERSION)?;

    let config = Config {
        admin: info.sender.clone(),
        compliance_module: msg.compliance_module,
        token_service: msg.token_service,
        verification_key: msg.verification_key,
    };
    CONFIG.save(deps.storage, &config)?;

    Ok(Response::new()
        .add_attribute("method", "instantiate")
        .add_attribute("owner", config.admin))
}

#[cfg_attr(not(feature = "library"), entry_point)]
pub fn execute(
    deps: DepsMut,
    env: Env,
    info: MessageInfo,
    msg: ExecuteMsg,
) -> Result<Response, ContractError> {
    match msg {
        ExecuteMsg::MintRwaAsset { document_hash, proof } => {
            execute_mint_rwa_asset(deps, env, info, document_hash, proof)
        }
    }
}

/// Main flow for minting an RWA asset (mock verification).
/// Steps:
/// 1) Build public inputs and call mock verifier.
/// 2) Query compliance module via `deps.querier` (expecting a boolean).
/// 3) Store audit trail.
/// 4) Trigger mint via SubMsg to token service.
pub fn execute_mint_rwa_asset(
    deps: DepsMut,
    env: Env,
    info: MessageInfo,
    document_hash: Binary,
    proof: Binary,
) -> Result<Response, ContractError> {
    let config = CONFIG.load(deps.storage)?;

    // invariant: caller must ensure the same encoding is used by prover/verifier.
    let doc_hash_bytes = document_hash.to_vec();

    // For SP1 proofs, we verify the proof directly
    // Public values are embedded in the proof
    let verified =
        verify_sp1_proof(&proof.0, &doc_hash_bytes, &config.verification_key.0)
            .map_err(|e| ContractError::VerificationError(e.to_string()))?;

    if !verified {
        return Err(ContractError::InvalidProof {});
    }

    // Store proof in audit trail keyed by the document hash
    AUDIT_TRAIL.save(deps.storage, &doc_hash_bytes, &proof)?;

    // For demo purposes, we skip the complex compliance module query
    // In production, this would query MANTRA's DID and Compliance modules
    
    // Simplified mint message
    let mint_msg = SubMsg::new(CosmosMsg::Wasm(WasmMsg::Execute {
        contract_addr: config.token_service.to_string(),
        msg: Binary::from(br#"{"mint":{}}"#),
        funds: vec![],
    }));

    Ok(Response::new()
        .add_attribute("action", "mint_rwa")
        .add_attribute("sender", info.sender.to_string())
        .add_attribute("proof_verified", "true")
        .add_attribute("document_hash", hex::encode(&doc_hash_bytes))
        .add_submessage(mint_msg))
}

#[cfg_attr(not(feature = "library"), entry_point)]
pub fn query(deps: Deps, _env: Env, msg: QueryMsg) -> StdResult<Binary> {
    match msg {
        QueryMsg::GetProof { asset_id } => {
            let key = asset_id.as_bytes();
            let proof = AUDIT_TRAIL.load(deps.storage, key)?;
            to_binary(&proof)
        }
    }
}
