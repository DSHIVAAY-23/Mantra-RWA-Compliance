
echo Balance for $dev
mantrachaind query wasm contract-state smart tp1wkwy0xh89ksdgj9hr347dyd2dw7zesmtrue6kfzyml4vdtz6e5wsvaczas \
	'{
  "get_balance": {
    "address": "tp1dftv3wslxwzl99n7g4nqge47n07p9lczgeearp",
    "denom": "VeriVaultToken"
  }
}' \
    --testnet \
	--output json \
	--node=http://34.70.126.95:26657 | jq

echo Balance for $user
mantrachaind query wasm contract-state smart tp1wkwy0xh89ksdgj9hr347dyd2dw7zesmtrue6kfzyml4vdtz6e5wsvaczas \
	'{
  "get_balance": {
    "address": "tp1zu5rdmpk08epmlt4j6qejwgej203zz86thfns2",
    "denom": "VeriVaultToken"
  }
}' \
    --testnet \
	--output json \
	--node=http://34.70.126.95:26657 | jq
  