//SPDX-License-Identifier: MIT

pragma solidity 0.8.20;

import {Script} from "forge-std/Script.sol";
import {RecycleMindsPFPMock} from "../test/Mocks/RecycleMindsPFPMock.sol";

contract RecycleMindsMockDeploy is Script {
    RecycleMindsPFPMock minds;

	function run() external returns(RecycleMindsPFPMock minds){
		
		vm.startBroadcast();
		
		minds = new RecycleMindsPFPMock("RecycleMindsMock", "Minds", 0xdDBEA05dFfB7eB78924c20288BaF8C029781B13D, 98);

		vm.stopBroadcast();

        return minds;
	}
}