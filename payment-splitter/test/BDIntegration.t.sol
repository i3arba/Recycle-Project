//License SPX-Identifier: MIT
pragma solidity ^0.8.18;

import {Test, console} from "forge-std/Test.sol";
import {BatchDistribution} from "../src/BatchDistribution.sol";
import {DeployBatchDistribution} from "../script/DeployBatchDistribution.s.sol";
import {DeployMindsFarmerMock} from "../script/DeployMindsFarmersMock.s.sol";
import {MindsFarmerMock} from "../test/mocks/MindsFarmersMock.sol";

contract FundeMeTest is Test{
    DeployBatchDistribution deployBatchDistribution;
    BatchDistribution batch;
    DeployMindsFarmerMock deployMindsFarmerMock;
    MindsFarmerMock farmers;

    address BARBA = makeAddr("user");
    uint256 constant STARTING_BALANCE = 10 ether;

    function setUp() external {
        deployMindsFarmerMock = new DeployMindsFarmerMock();
        farmers = deployMindsFarmerMock.run();

        deployBatchDistribution = new DeployBatchDistribution();
        batch = deployBatchDistribution.run(BARBA, address(farmers));

        vm.deal(BARBA, STARTING_BALANCE);
    }
}
