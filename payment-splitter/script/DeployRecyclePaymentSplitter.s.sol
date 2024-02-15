//SPDX-License-Identifier: MIT

pragma solidity ^0.8.18;

import {Script} from "forge-std/Script.sol";
import {RecyclePaymentSplitter} from "../src/RecyclePaymentSplitter.sol";
import {DeployMindsFarmerMock} from "./DeployMindsFarmersMock.s.sol"; 

contract DeployRecyclePaymentSplitter is Script {
	
	address farmers = 0x89De5057ab007321cfC120718F36f05DeB532c22;
    address owner = 0x5FA769922a6428758fb44453815e2c436c57C3c7;

	function run(address _farmers) public returns(RecyclePaymentSplitter){ 

		vm.startBroadcast();

		RecyclePaymentSplitter splitter = new RecyclePaymentSplitter(_farmers);

		vm.stopBroadcast();

		return splitter;
	}
}