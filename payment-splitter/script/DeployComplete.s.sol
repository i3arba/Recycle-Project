//SPDX-License-Identifier: MIT

pragma solidity ^0.8.18;

import {Script} from "forge-std/Script.sol";
import {DeployMindsFarmerMock} from "./DeployMindsFarmersMock.s.sol";
import {MindsFarmerMock} from "../test/mocks/MindsFarmersMock.sol";
import {DeployPaymentSplitter} from "./DeployPaymentSplitter.s.sol";
import {RecyclePaymentSplitter} from "../src/RecyclePaymentSplitter.sol";

contract DeployComplete is Script {
	DeployMindsFarmerMock farmersDeploy;
    MindsFarmerMock farmers;
    DeployPaymentSplitter splitterDeployer;
    RecyclePaymentSplitter splitter;
    address owner = 0x5FA769922a6428758fb44453815e2c436c57C3c7;
    address farmersAddress = 0x89De5057ab007321cfC120718F36f05DeB532c22;

	function run() external returns(RecyclePaymentSplitter){
		
		vm.startBroadcast();
		
		farmers = farmersDeploy.run();
        splitter = splitterDeployer.run();

		vm.stopBroadcast();

		return splitter;
	}
}