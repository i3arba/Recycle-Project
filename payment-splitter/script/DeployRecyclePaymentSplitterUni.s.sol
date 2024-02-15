//SPDX-License-Identifier: MIT

pragma solidity ^0.8.18;

import {Script} from "forge-std/Script.sol";
import {RecyclePaymentSplitterUni} from "../src/RecyclePaymentSplitterUni.sol";
import {DeployMindsFarmerMock} from "./DeployMindsFarmersMock.s.sol"; 

contract DeployRecyclePaymentSplitterUni is Script {
	RecyclePaymentSplitterUni splitter;

	function run(address _farmers) external returns(RecyclePaymentSplitterUni){ 
		vm.startBroadcast();
		
		splitter = new RecyclePaymentSplitterUni(address(_farmers));

		vm.stopBroadcast();
		return splitter;
	}
}