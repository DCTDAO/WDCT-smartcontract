//SPDX-License-Identifier: MIT
pragma solidity 0.8.4;

import "@openzeppelin/contracts/token/ERC20/presets/ERC20PresetMinterPauser.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/utils/cryptography/ECDSA.sol";
import "./libraries/UniswapV2Library.sol";

contract WDCThandler is Ownable {
	using ECDSA for bytes32;
	mapping(bytes20 => bool) public depositedTxId;

	event Deposit(address receiver, uint256 amount);

	bytes32 public DOMAIN_SEPARATOR;
    	bytes32 public constant PRESALE_TYPEHASH = keccak256("Deposit(address receiver,uint256 amount,bytes20 txId)");

	ERC20PresetMinterPauser public WDCT;
	ERC20PresetMinterPauser public DCTD;

	uint256 public usdFee = 0;

	address public factory;
	address[] public path = new address[](2); 

	
	constructor(address _USD, address _DCTD) {
		uint256 chainId;
		path[0] = _USD;
		path[1] = _DCTD;
		DCTD = ERC20PresetMinterPauser(_DCTD);
		assembly {
			chainId := chainid()
		}
		DOMAIN_SEPARATOR = keccak256(
			abi.encode(
				keccak256("EIP712Domain(string name,string version,uint256 chainId,address verifyingContract)"),
				keccak256(bytes("WDCThandler")),
				keccak256(bytes("1")),
				chainId,
				address(this)
			)
		);
	}

	function deposit(
		address receiver,
		uint256 amount,
		bytes20 txId,
		bytes calldata signature
	) external {
		require(!depositedTxId[txId],"WDCThandler: txId already used");
		//transfer DCTD fee
		uint256 dctdfee = calculateDCTDFee();
		DCTD.transferFrom(msg.sender, address(this), dctdfee);


		//Verify signature
		bytes32 digest = keccak256(
			abi.encodePacked("\x19\x01", DOMAIN_SEPARATOR, keccak256(abi.encode(PRESALE_TYPEHASH, 
			receiver, 
			amount, 
			txId)))
		);
		address recoveredAddress = digest.recover(signature);
		require(
			recoveredAddress != address(0) && recoveredAddress == this.owner(),
			"WDCThandler: invalid signature"
		);
		// id is used
		depositedTxId[txId] = true;
		//We mint tokens
		
		WDCT.mint(receiver, amount);
		emit Deposit(receiver, amount);	
	}


	function calculateDCTDFee() public view returns(uint256) {
		return UniswapV2Library.getAmountsOut(factory, usdFee, path)[0];
	}

	function setWDCT(address _wdct) public onlyOwner {
		WDCT = ERC20PresetMinterPauser(_wdct);
	}

	function setUsdFee(uint256 _usdFee) public onlyOwner {
		usdFee = _usdFee;
	}

	function setFactory(address _factory) public onlyOwner {
		factory = _factory;
	}

	function widrawDCTD(address receiver, uint256 amount) public onlyOwner {
		DCTD.transfer(receiver, amount);	
	}
}