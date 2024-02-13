//SPDX-License-Identifier: MIT

pragma solidity ^0.8.18;

import {Script} from "forge-std/Script.sol";
import {MindsFarmerMock} from "../test/mocks/MindsFarmersMock.sol";

contract DeployMindsFarmerMock is Script {
	MindsFarmerMock farmers;

	function run() external returns(MindsFarmerMock){
		
		vm.startBroadcast();
		
		farmers = new MindsFarmerMock();

		vm.stopBroadcast();

		return farmers;
	}
}