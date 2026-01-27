# Asset Lifecycle & Architecture Notes

## Overview
The `custom-marker` contract acts as a **Restricted Asset Controller**. It wraps native Provenance Markers (`provwasm_std`) but enforces strict, contract-layer compliance rules (Whitelisting, Freezing, Limits) *before* allowing any underlying marker action.

## Key Findings

1.  **No Direct Attribute Module Usage**:
    - Contrary to typical Provenance patterns, this contract does **not** check `x/attribute` for KYC.
    - Instead, it maintains its own **Local Whitelist State** (`WHITELIST` Map).
    - **Implication**: Compliance is "Contract-Sovereign", not "Chain-Sovereign".

2.  **ZK Verification is External**:
    - The `custom-marker` has **no ZK logic**.
    - ZK proofs are handled by the `verifier` contract (or off-chain agents).
    - The `verifier` presumably calls `Mint` on `custom-marker`.
    - **Security Criticality**: `custom-marker` must strictly limit `Mint` access to the `verifier` (or SubAdmin).

## Message Flow Analysis

### 1. Asset Creation (`Create`)
- **Handler**: `try_create`
- **Auth**: `is_subadmin`
- **Logic**:
    1.  Saves `DENOM_CONFIG` (configures rules).
    2.  Saves `HOLDING_PERIOD` (optional).
    3.  Grants `Issuer`, `TransferAgent`, `TokenizationAgent` roles.
    4.  Calls `provwasm_std::create_marker` + `finalize` + `activate`.
- **Outcome**: A native Restricted Marker is created on Provenance, but controlled by this contract.

### 2. Minting (`Mint` / `MintTo`)
- **Handler**: `try_mint`
- **Auth**: `is_subadmin` (Critical: Only trusted entities can mint).
- **Logic**:
    1.  Checks `is_subadmin`.
    2.  Calls `provwasm_std::mint_marker_supply`.
    3.  (For `MintTo`): Withdraws coins from Module Account to User immediately.
- **ZK Integration**: The `verifier` contract validates the proof, then sends a `Mint` message to this contract.

### 3. Transfer (`Send`)
- **Handler**: `try_send`
- **Auth**: User (sender).
- **Logic**:
    1.  **Compliance Check 1**: `ensure_authorized_country` (Checks `WHITELIST` for `to` address).
    2.  **Compliance Check 2**: `ensure_not_freezed` (Checks `FREEZE_LIST` for `from` and `to`?). *Code only checks `from` explicitly in `try_send` preamble?* -> Verified: `try_send` calls `ensure_not_freezed` for `from`. `to` usually checked for whitelist.
    3.  **Limit Check**: Checks `token_limit` for `to` address.
    4.  **Execution**: Calls `provwasm_std::transfer_marker_coins`.
- **Note**: This replaces the standard `Bank::Send`. Users interact with the Contract, not the Bank module directly, for compliant transfers (or the Marker is Restricted so Bank sends fail).

### 4. Compliance Administration
- **Freezing**: `Freeze` / `PartialFreeze`
    - Updates `FREEZE_LIST` or `PARTIAL_FREEZE` map.
    - Auth: `Issuer`, `TransferAgent`, `SubAdmin`, or `FreezeAccess`.
- **Whitelisting**: `Whitelist` / `UpdateCountryCode`
    - Updates `WHITELIST` map (Address -> CountryCode).
    - Auth: `SubAdmin` or `TokenizationAgent`.

## Architecture Diagram (Textual)
`User` -> `Verifier` (ZK Check) -> `CustomMarker` (Mint) -> `Provenance Marker` (Store)
`User` -> `CustomMarker` (Send) -> `Local Rules` (Whitelist/Freeze) -> `Provenance Marker` (Transfer)
