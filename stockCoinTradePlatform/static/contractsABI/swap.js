const swap_address = "0xf34F965ABEC43902750b24bdf277a828AcF5c86f"
const swap_ABI = [
	{
		"inputs": [
			{
				"internalType": "address",
				"name": "sender",
				"type": "address"
			},
			{
				"internalType": "address",
				"name": "token1",
				"type": "address"
			},
			{
				"internalType": "address",
				"name": "token2",
				"type": "address"
			},
			{
				"internalType": "uint256",
				"name": "amount1",
				"type": "uint256"
			},
			{
				"internalType": "uint256",
				"name": "amount2",
				"type": "uint256"
			}
		],
		"name": "addLiquidity",
		"outputs": [],
		"stateMutability": "nonpayable",
		"type": "function"
	},
	{
		"anonymous": false,
		"inputs": [
			{
				"indexed": true,
				"internalType": "address",
				"name": "provider",
				"type": "address"
			},
			{
				"indexed": true,
				"internalType": "address",
				"name": "token1",
				"type": "address"
			},
			{
				"indexed": true,
				"internalType": "address",
				"name": "token2",
				"type": "address"
			},
			{
				"indexed": false,
				"internalType": "uint256",
				"name": "amount1",
				"type": "uint256"
			},
			{
				"indexed": false,
				"internalType": "uint256",
				"name": "amount2",
				"type": "uint256"
			}
		],
		"name": "AddLiquidity",
		"type": "event"
	},
	{
		"inputs": [
			{
				"internalType": "address",
				"name": "inputToken",
				"type": "address"
			},
			{
				"internalType": "address",
				"name": "outputToken",
				"type": "address"
			},
			{
				"internalType": "uint256",
				"name": "inputAmount",
				"type": "uint256"
			}
		],
		"name": "swap",
		"outputs": [],
		"stateMutability": "nonpayable",
		"type": "function"
	},
	{
		"anonymous": false,
		"inputs": [
			{
				"indexed": true,
				"internalType": "address",
				"name": "user",
				"type": "address"
			},
			{
				"indexed": true,
				"internalType": "address",
				"name": "inputToken",
				"type": "address"
			},
			{
				"indexed": true,
				"internalType": "address",
				"name": "outputToken",
				"type": "address"
			},
			{
				"indexed": false,
				"internalType": "uint256",
				"name": "inputAmount",
				"type": "uint256"
			},
			{
				"indexed": false,
				"internalType": "uint256",
				"name": "outputAmount",
				"type": "uint256"
			}
		],
		"name": "Swap",
		"type": "event"
	},
	{
		"inputs": [
			{
				"internalType": "uint256",
				"name": "",
				"type": "uint256"
			},
			{
				"internalType": "uint256",
				"name": "",
				"type": "uint256"
			}
		],
		"name": "activePairs",
		"outputs": [
			{
				"internalType": "address",
				"name": "",
				"type": "address"
			}
		],
		"stateMutability": "view",
		"type": "function"
	},
	{
		"inputs": [
			{
				"internalType": "address",
				"name": "inputToken",
				"type": "address"
			},
			{
				"internalType": "address",
				"name": "outputToken",
				"type": "address"
			},
			{
				"internalType": "uint256",
				"name": "outputAmount",
				"type": "uint256"
			}
		],
		"name": "calculateInputAmount2",
		"outputs": [
			{
				"internalType": "uint256",
				"name": "",
				"type": "uint256"
			}
		],
		"stateMutability": "view",
		"type": "function"
	},
	{
		"inputs": [
			{
				"internalType": "address",
				"name": "inputToken",
				"type": "address"
			},
			{
				"internalType": "address",
				"name": "outputToken",
				"type": "address"
			},
			{
				"internalType": "uint256",
				"name": "inputAmount",
				"type": "uint256"
			}
		],
		"name": "calculateOutputAmount",
		"outputs": [
			{
				"internalType": "uint256",
				"name": "",
				"type": "uint256"
			}
		],
		"stateMutability": "view",
		"type": "function"
	},
	{
		"inputs": [],
		"name": "getActivePairs",
		"outputs": [
			{
				"internalType": "address[][]",
				"name": "",
				"type": "address[][]"
			}
		],
		"stateMutability": "view",
		"type": "function"
	},
	{
		"inputs": [
			{
				"internalType": "address",
				"name": "",
				"type": "address"
			},
			{
				"internalType": "address",
				"name": "",
				"type": "address"
			}
		],
		"name": "pairs",
		"outputs": [
			{
				"internalType": "contract IERC20",
				"name": "token1",
				"type": "address"
			},
			{
				"internalType": "contract IERC20",
				"name": "token2",
				"type": "address"
			},
			{
				"internalType": "uint256",
				"name": "reserve1",
				"type": "uint256"
			},
			{
				"internalType": "uint256",
				"name": "reserve2",
				"type": "uint256"
			},
			{
				"internalType": "uint256",
				"name": "K",
				"type": "uint256"
			}
		],
		"stateMutability": "view",
		"type": "function"
	}
]