//SPDX-License-Identifier: MIT

pragma solidity 0.8.20;

import {Script} from "forge-std/Script.sol";
import {RecycleMint} from "../src/RecycleMint.sol";
import {RecycleMindsMockDeploy} from "./RecycleMindsMockDeploy.s.sol";

contract RecycleMintDeploy is Script {

	function run() external returns(RecycleMint recycle){
		
		vm.startBroadcast();

			recycle = new RecycleMint(0xF673009b81EBd667b93Ac76a0766010c33Ce8fA9, 0x038169836b3a3C3df1421F0fF4f281f15B6ADeD3);

		vm.stopBroadcast();

        return recycle;
	}
}