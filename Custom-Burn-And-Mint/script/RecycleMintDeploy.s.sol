//SPDX-License-Identifier: MIT

pragma solidity 0.8.20;

import {Script} from "forge-std/Script.sol";
import {RecycleMint} from "../src/RecycleMint.sol";

contract RecycleMintDeploy is Script {
    RecycleMint recycle;

	function run(address _farmer, address _minds) external returns(RecycleMint){
		
		vm.startBroadcast();
		
		recycle = new RecycleMint(_farmer, _minds);

		vm.stopBroadcast();

        return recycle;
	}
}