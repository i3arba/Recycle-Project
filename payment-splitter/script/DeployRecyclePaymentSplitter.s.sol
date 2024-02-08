//SPDX-License-Identifier: MIT

pragma solidity ^0.8.18;

import {Script} from "forge-std/Script.sol";
import {RecyclePaymentSplitter} from "../src/RecyclePaymentSplitter.sol";
import {DeployMindsFarmerMock} from "./DeployMindsFarmersMock.s.sol"; 

contract DeployRecyclePaymentSplitter is Script {
	RecyclePaymentSplitter splitter;

	function run(address _owner, address _farmers) external returns(RecyclePaymentSplitter){ 
		vm.startBroadcast();
		
		splitter = new RecyclePaymentSplitter(_owner, address(_farmers));

		vm.stopBroadcast();
		return splitter;
	}
}