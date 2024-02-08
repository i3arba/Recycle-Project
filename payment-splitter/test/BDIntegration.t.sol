//License SPX-Identifier: MIT
pragma solidity ^0.8.18;

import {Test, console} from "forge-std/Test.sol";
import {BatchDistribution} from "../src/BatchDistribution.sol";
import {DeployBatchDistribution} from "../script/DeployBatchDistribution.s.sol";
import {DeployMindsFarmerMock} from "../script/DeployMindsFarmersMock.s.sol";
import {MindsFarmerMock} from "../test/mocks/MindsFarmersMock.sol";

error RecyclePaymentSplitter__OnlyFarmersContractCanSendEth();

contract BDIntegrationTest is Test{
    DeployBatchDistribution deployBatchDistribution;
    BatchDistribution batch;
    DeployMindsFarmerMock deployMindsFarmerMock;
    MindsFarmerMock farmers;

    address BARBA = makeAddr("user");
    address[] s_users = [
    0xf39Fd6e51aad88F6F4ce6aB8827279cffFb92266,
    0x70997970C51812dc3A010C7d01b50e0d17dc79C8,
    0x3C44CdDdB6a900fa2b585dd299e03d12FA4293BC,
    0x90F79bf6EB2c4f870365E785982E1f101E93b906,
    0x15d34AAf54267DB7D7c367839AAf71A00a2C6A65,
    0x9965507D1a55bcC2695C58ba16FB37d819B0A4dc,
    0x976EA74026E726554dB657fA54763abd0C3a0aa9,
    0x14dC79964da2C08b23698B3D3cc7Ca32193d9955,
    0x23618e81E3f5cdF7f54C3d65f7FBc0aBf5B21E8f,
    0xa0Ee7A142d267C1f36714E4a8F75612F20a79720
    ];

    uint256 constant STARTING_BALANCE = 1000 ether;
    uint256 constant TOTAL_NFTS = 100;
    uint256 constant VALUE_TO_TRANSFER = 100 ether;

    function setUp() external {
        deployMindsFarmerMock = new DeployMindsFarmerMock();
        farmers = deployMindsFarmerMock.run();

        deployBatchDistribution = new DeployBatchDistribution();
        batch = deployBatchDistribution.run(BARBA, address(farmers));

        vm.deal(BARBA, STARTING_BALANCE);
    }

    modifier distribuiNFTs() {
        uint256 totalUser = s_users.length;

        for(uint256 i = 0; i < totalUser; i++){
            for(uint256 j = 1; j < 10; j++) {
                farmers.safeMint(s_users[i], "");
            }
        }
        farmers.addSplitter(address(batch));
        vm.prank(BARBA);
        payable(address(farmers)).transfer(VALUE_TO_TRANSFER);
        _;
    }

    function testSeReceiveFunctionChamaDistribution() public distribuiNFTs {
        uint256 farmersBalancoInicial = farmers.getBalance();
        uint256 batchBalancoInicial = batch.getBalance();

        assertEq(farmersBalancoInicial, VALUE_TO_TRANSFER);
        assertEq(batchBalancoInicial, 0);

        farmers.withdraw();

        uint256 farmersBalancoFinal = farmers.getBalance();
        uint256 batchBalancoFinal = batch.getBalance();
        assertEq(farmersBalancoFinal, 1 ether);
        assertEq(batchBalancoFinal, 99 ether);
    }

    function testSeReceivefunctionExecutaCorretamente() public distribuiNFTs{
        console.logUint(batch.getBalance());

        vm.prank(BARBA);
        vm.expectRevert(RecyclePaymentSplitter__OnlyFarmersContractCanSendEth.selector);
        payable(address(batch)).transfer(VALUE_TO_TRANSFER);

        console.logUint(batch.getBalance());

    }

}
