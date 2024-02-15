//SPDX-License-Identifier: MIT

pragma solidity ^0.8.18;

import {Script} from "forge-std/Script.sol";
import {RecyclePaymentSplitter} from "../src/RecyclePaymentSplitter.sol";
import {DeployMindsFarmerMock} from "./DeployMindsFarmersMock.s.sol"; 

contract DeployPaymentSplitter is Script {
	
	address farmers = 0x2D91875FA696bDf3543ca0634258F6074Cc5df20;

	function run() public returns(RecyclePaymentSplitter){ 

		vm.startBroadcast();

		RecyclePaymentSplitter splitter = new RecyclePaymentSplitter(farmers);

		vm.stopBroadcast();

		return splitter;
	}
}