//License SPX-Identifier: MIT
pragma solidity ^0.8.18;

import {Test, console} from "forge-std/Test.sol";
import {RecyclePaymentSplitter} from "../src/RecyclePaymentSplitter.sol";
import {DeployRecyclePaymentSplitter} from "../script/DeployRecyclePaymentSplitter.s.sol";
import {DeployMindsFarmerMock} from "../script/DeployMindsFarmersMock.s.sol";
import {MindsFarmerMock} from "../test/mocks/MindsFarmersMock.sol";

error RecyclePaymentSplitter__OnlyFarmersContractCanSendEth();

contract FundeMeTest is Test {
    RecyclePaymentSplitter splitter;
    DeployRecyclePaymentSplitter deployRecyclePaymentSplitter;
    
    MindsFarmerMock farmers;
    DeployMindsFarmerMock deployMindsFarmerMock;

    address BARBA = makeAddr("user");
    uint256 constant STARTING_BALANCE = 1000 ether;
    uint256 constant TOTAL_NFTS = 10;
    uint256 constant VALUE_TO_TRANSFER = 100 ether;
    address USER1 = 0xf39Fd6e51aad88F6F4ce6aB8827279cffFb92266;
    address USER2 = 0x70997970C51812dc3A010C7d01b50e0d17dc79C8;
    address USER3 = 0x3C44CdDdB6a900fa2b585dd299e03d12FA4293BC;

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

    //1° a ser executada. Deploy do contrato e define variáveis de estado.
    function setUp() external {
        deployMindsFarmerMock = new DeployMindsFarmerMock();
        farmers = deployMindsFarmerMock.run();

        deployRecyclePaymentSplitter = new DeployRecyclePaymentSplitter();
        splitter = deployRecyclePaymentSplitter.run(BARBA, address(farmers));

        vm.deal(BARBA, STARTING_BALANCE);
    }

    modifier distribuiNFTs() {
        uint256 totalUser = s_users.length;

        for (uint256 i = 0; i < totalUser; i++) {
            farmers.safeMint(s_users[i], "");
        }
        farmers.addSplitter(address(splitter));
        vm.prank(BARBA);
        payable(address(farmers)).transfer(VALUE_TO_TRANSFER);
        _;
    }

    function testSeFarmersDepositaOValorNoSplitter() public distribuiNFTs {
        uint256 farmersBalancoInicial = farmers.getBalance();
        uint256 batchBalancoInicial = splitter.getBalance();

        assertEq(farmersBalancoInicial, VALUE_TO_TRANSFER);
        assertEq(batchBalancoInicial, 0);

        farmers.withdraw();

        uint256 farmersBalancoFinal = farmers.getBalance();
        uint256 batchBalancoFinal = splitter.getBalance();
        assertEq(farmersBalancoFinal, 0 ether);
        assertEq(batchBalancoFinal, 101 ether);
    }

    function testSeReceivefunctionRevertComEnderecoAleatorio() public distribuiNFTs {
        console.logUint(splitter.getBalance());

        vm.prank(BARBA);
        vm.expectRevert(RecyclePaymentSplitter__OnlyFarmersContractCanSendEth.selector);
        payable(address(splitter)).transfer(VALUE_TO_TRANSFER);

        console.logUint(splitter.getBalance());
    }

    function testSeDistributionFuncionaCorretamente() public distribuiNFTs {
        uint256 farmersBalancoInicial = farmers.getBalance();
        uint256 splitterBalancoInicial = splitter.getBalance();

        assertEq(farmersBalancoInicial, VALUE_TO_TRANSFER);
        assertEq(splitterBalancoInicial, 0);

        farmers.withdraw();

        uint256 balanceAfterWithdraw = splitter.getBalance();
        assertEq(balanceAfterWithdraw, VALUE_TO_TRANSFER);

        uint256[] memory farmersId = new uint256[](1);
        farmersId[0] = 0;

        vm.prank(USER1);
        splitter.verifyContractBalanceToDistribution(farmersId);

        uint256 farmersBalancoFinal = farmers.getBalance();
        uint256 splitterBalancoFinal = splitter.getBalance();
        //Sacamos todo o valor
        assertEq(farmersBalancoFinal, 0);
        assertEq(splitterBalancoFinal, (VALUE_TO_TRANSFER - (VALUE_TO_TRANSFER/TOTAL_NFTS)));
    }

    function testSeOValorSacadoEhContabilizadoCorretamenteNoNFTID() public distribuiNFTs{

        farmers.withdraw();

        uint256[] memory farmersId = new uint256[](1);
        farmersId[0] = 0;

        vm.prank(USER1);
        splitter.verifyContractBalanceToDistribution(farmersId);

        uint256 valueWithdrawnToNFTZero = splitter.getValueWithdrawnPerFarmer(0);
        uint256 valueNFTCanWithdraw = splitter.getTotalValueDistributedPerFarmer();
        //Sacamos todo o valor
        assertEq(valueWithdrawnToNFTZero, valueNFTCanWithdraw);
        
        assertEq(valueNFTCanWithdraw, USER1.balance );
    }

    function testSeMultiplosSaquesOcorremCorretamente() public distribuiNFTs{
        farmers.withdraw();

        uint256[] memory farmersId1 = new uint256[](1);
        farmersId1[0] = 0;

        vm.prank(USER1);
        splitter.verifyContractBalanceToDistribution(farmersId1);

        uint256[] memory farmersId2 = new uint256[](1);
        farmersId2[0] = 1;

        vm.prank(USER2);
        splitter.verifyContractBalanceToDistribution(farmersId2);

        uint256 valueWithdrawnToNFTZero = splitter.getValueWithdrawnPerFarmer(1);
        uint256 valueNFTCanWithdraw = splitter.getTotalValueDistributedPerFarmer();

        assertEq(valueWithdrawnToNFTZero, valueNFTCanWithdraw);
        
        assertEq(valueNFTCanWithdraw, USER2.balance );
    }
}
