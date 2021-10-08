//SPDX-License-Identifier: MIT
pragma solidity 0.8.4;

import "@openzeppelin/contracts/token/ERC20/presets/ERC20PresetMinterPauser.sol";


contract WDCT is ERC20PresetMinterPauser {

	constructor() ERC20PresetMinterPauser("Wrapped DCT","WDCT") {
		
	}
	
	function decimals() public pure override returns (uint8) {
		return 8;
	}

	
}
