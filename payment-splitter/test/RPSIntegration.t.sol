//License SPX-Identifier: MIT
pragma solidity ^0.8.18;

import {Test, console} from "forge-std/Test.sol";
import {RecyclePaymentSplitter} from "../src/RecyclePaymentSplitter.sol";
import {DeployRecyclePaymentSplitter} from "../script/DeployRecyclePaymentSplitter.s.sol";
import {DeployMindsFarmerMock} from "../script/DeployMindsFarmersMock.s.sol";
import {MindsFarmerMock} from "../test/mocks/MindsFarmersMock.sol";

contract FundeMeTest is Test {
    RecyclePaymentSplitter splitter;
    DeployRecyclePaymentSplitter deployRecyclePaymentSplitter;
    
    MindsFarmerMock farmers;
    DeployMindsFarmerMock deployMindsFarmerMock;

    address BARBA = makeAddr("user");
    uint256 constant STARTING_BALANCE = 10 ether;

    //1° a ser executada. Deploy do contrato e define variáveis de estado.
    function setUp() external {
        deployMindsFarmerMock = new DeployMindsFarmerMock();
        farmers = deployMindsFarmerMock.run();

        deployRecyclePaymentSplitter = new DeployRecyclePaymentSplitter();
        splitter = deployRecyclePaymentSplitter.run(BARBA, address(farmers));
        vm.deal(BARBA, STARTING_BALANCE);
    }

    
}
