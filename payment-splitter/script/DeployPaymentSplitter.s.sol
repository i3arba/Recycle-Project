//SPDX-License-Identifier: MIT

pragma solidity ^0.8.18;

import {Script} from "forge-std/Script.sol";
import {RecyclePaymentSplitter} from "../src/RecyclePaymentSplitter.sol";
import {DeployMindsFarmerMock} from "./DeployMindsFarmersMock.s.sol"; 

contract DeployPaymentSplitter is Script {
	
	address farmers = 0xafc54198dfdBBc35C18B24F86Cff0C18c43af781;
    address owner = 0x5FA769922a6428758fb44453815e2c436c57C3c7;

	function run() public returns(RecyclePaymentSplitter){ 

		vm.startBroadcast();

		RecyclePaymentSplitter splitter = new RecyclePaymentSplitter(owner, farmers);

		vm.stopBroadcast();

		return splitter;
	}
}