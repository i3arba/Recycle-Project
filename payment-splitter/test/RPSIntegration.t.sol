//License SPX-Identifier: MIT
pragma solidity ^0.8.18;

import {Test, console} from "forge-std/Test.sol";
import {RecyclePaymentSplitter} from "../src/RecyclePaymentSplitter.sol";
import {DeployRecyclePaymentSplitter} from "../script/DeployRecyclePaymentSplitter.s.sol";
import {DeployMindsFarmerMock} from "../script/DeployMindsFarmersMock.s.sol";
import {MindsFarmerMock} from "../test/mocks/MindsFarmersMock.sol";

error RecyclePaymentSplitter__OnlyFarmersContractCanSendEth();
error RecyclePaymentSplitter__OnlyMindsFarmerCanWithdraw();
error RecyclePaymentSplitter__NoValueToWithdraw();

contract RecyclePaymentSplitterTest is Test {
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
        splitter = deployRecyclePaymentSplitter.run(address(farmers));

        vm.deal(BARBA, STARTING_BALANCE);
    }

    modifier distribuiNFTs() {
        uint256 totalUser = s_users.length;

        for (uint256 i = 0; i < totalUser; i++) {
            farmers.safeMint(s_users[i], 1, "");
        }
        farmers.addSplitter(address(splitter));
        vm.prank(BARBA);
        payable(address(farmers)).transfer(VALUE_TO_TRANSFER);
        _;
    }

    function testSeFarmersDepositaOValorNoSplitter() public distribuiNFTs {
        vm.startPrank(BARBA);
        uint256 farmersBalancoInicial = farmers.getBalance();
        uint256 batchBalancoInicial = splitter.getBalance();
        vm.stopPrank();

        assertEq(farmersBalancoInicial, VALUE_TO_TRANSFER);
        assertEq(batchBalancoInicial, 0);

        farmers.withdraw();

        vm.startPrank(BARBA);
        uint256 farmersBalancoFinal = farmers.getBalance();
        uint256 batchBalancoFinal = splitter.getBalance();
        vm.stopPrank();

        assertEq(farmersBalancoFinal, 0 ether);
        assertEq(batchBalancoFinal, 100 ether);
    }

    function testSeReceivefunctionRevertComEnderecoAleatorio() public distribuiNFTs {
        vm.prank(BARBA);
        console.logUint(splitter.getBalance());

        vm.prank(BARBA);
        vm.expectRevert(RecyclePaymentSplitter__OnlyFarmersContractCanSendEth.selector);
        payable(address(splitter)).transfer(VALUE_TO_TRANSFER);
        
        vm.prank(BARBA);
        console.logUint(splitter.getBalance());
    }

    function testSeDistributionFuncionaCorretamente() public distribuiNFTs {
        vm.startPrank(BARBA);
        uint256 farmersBalancoInicial = farmers.getBalance();
        uint256 splitterBalancoInicial = splitter.getBalance();
        vm.stopPrank();

        assertEq(farmersBalancoInicial, VALUE_TO_TRANSFER);
        assertEq(splitterBalancoInicial, 0);

        farmers.withdraw();

        vm.prank(BARBA);
        uint256 balanceAfterWithdraw = splitter.getBalance();
        assertEq(balanceAfterWithdraw, VALUE_TO_TRANSFER);

        uint256[] memory farmersId = new uint256[](1);
        farmersId[0] = 0;

        vm.prank(USER1);
        splitter.verifyContractBalanceToDistribution(farmersId);

        vm.startPrank(BARBA);
        uint256 farmersBalancoFinal = farmers.getBalance();
        uint256 splitterBalancoFinal = splitter.getBalance();
        vm.stopPrank();

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
        //Zero
        uint256 valueNFTZeroAlreadyWithdrawn = splitter.getValueWithdrawnPerFarmer(0);

        vm.prank(USER1);
        splitter.verifyContractBalanceToDistribution(farmersId1);

        //1
        uint256 valueNFTZeroCanWithdraw = splitter.getTotalValueDistributedPerFarmer();
        //1
        uint256 valueWithdrawnToNFTZero = splitter.getValueWithdrawnPerFarmer(0);

        console.logUint(valueNFTZeroAlreadyWithdrawn);//0
        console.logUint(valueNFTZeroCanWithdraw);//1
        console.logUint(valueWithdrawnToNFTZero);//1

        assertEq(valueNFTZeroAlreadyWithdrawn, 0);
        assertEq(valueWithdrawnToNFTZero, valueNFTZeroCanWithdraw);
        assertEq(valueWithdrawnToNFTZero, USER1.balance);

        //Second Withdraw
        uint256[] memory farmersId2 = new uint256[](1);
        farmersId2[0] = 1;

        uint256 valueNFTOneAlreadyWithdrawn = splitter.getValueWithdrawnPerFarmer(1);
        uint256 valueNFTOneCanWithdraw = splitter.getTotalValueDistributedPerFarmer();

        vm.prank(USER2);
        splitter.verifyContractBalanceToDistribution(farmersId2);

        uint256 valueWithdrawnToNFTOne = splitter.getValueWithdrawnPerFarmer(1);

        assertEq(valueNFTOneAlreadyWithdrawn, 0);
        assertEq(valueWithdrawnToNFTOne, valueNFTOneCanWithdraw);
        assertEq(valueNFTOneCanWithdraw, USER2.balance );

        vm.prank(BARBA);
        uint256 splitterBalance = splitter.getBalance();
        assertTrue(splitterBalance == 80 ether);
    }

    function testSeWithdrawReverteComCallerAleatorio() public distribuiNFTs{
        farmers.withdraw();

        uint256[] memory farmersId1 = new uint256[](1);
        farmersId1[0] = 0;

        vm.prank(BARBA);
        vm.expectRevert(RecyclePaymentSplitter__OnlyMindsFarmerCanWithdraw.selector);
        splitter.verifyContractBalanceToDistribution(farmersId1);
    }

    function testSeWithdrawRevertSeNaoHouverValorParaSacar() public distribuiNFTs{
        farmers.withdraw();

        uint256[] memory farmersId1 = new uint256[](1);
        farmersId1[0] = 0;

        vm.prank(USER1);
        splitter.verifyContractBalanceToDistribution(farmersId1);

        uint256 valueNFTZeroAlreadyWithdrawn = splitter.getValueWithdrawnPerFarmer(0);
        uint256 valueNFTZeroCanWithdraw = splitter.getTotalValueDistributedPerFarmer();

        assertEq(valueNFTZeroAlreadyWithdrawn, valueNFTZeroCanWithdraw);
        assertEq(valueNFTZeroCanWithdraw, USER1.balance);

        vm.prank(USER1);
        vm.expectRevert(RecyclePaymentSplitter__NoValueToWithdraw.selector);
        splitter.verifyContractBalanceToDistribution(farmersId1);
    }

    function testSeASomaDeRecebiveisEhContabilizadaCorretamente() public distribuiNFTs{
        farmers.withdraw();

        uint256[] memory farmersId1 = new uint256[](1);
        farmersId1[0] = 0;

        vm.prank(USER1);
        splitter.verifyContractBalanceToDistribution(farmersId1);

        uint256 valueNFTZeroAlreadyWithdrawn = splitter.getValueWithdrawnPerFarmer(0);
        uint256 valueNFTZeroCanWithdraw = splitter.getTotalValueDistributedPerFarmer();

        assertEq(valueNFTZeroAlreadyWithdrawn, valueNFTZeroCanWithdraw);
        assertEq(valueNFTZeroCanWithdraw, USER1.balance);

        uint256[] memory farmersId2 = new uint256[](1);
        farmersId2[0] = 1;

        vm.prank(USER2);
        splitter.verifyContractBalanceToDistribution(farmersId2);

        uint256 valueNFTOneAlreadyWithdrawn = splitter.getValueWithdrawnPerFarmer(1);
        uint256 valueNFTOneCanWithdraw = splitter.getTotalValueDistributedPerFarmer();

        assertEq(valueNFTOneAlreadyWithdrawn, valueNFTOneCanWithdraw);
        assertEq(valueNFTOneCanWithdraw, USER2.balance);

        vm.prank(BARBA);
        uint256 splitterBalance = splitter.getBalance();
        assertTrue(splitterBalance == 80 ether);

        farmers.addSplitter(address(splitter));
        vm.prank(BARBA);
        payable(address(farmers)).transfer(VALUE_TO_TRANSFER);

        farmers.withdraw();

        vm.prank(BARBA);
        uint256 splitterBalanceAfterSecondDeposit = splitter.getBalance();
        assertTrue(splitterBalanceAfterSecondDeposit == 180 ether);

        vm.prank(USER1);
        splitter.verifyContractBalanceToDistribution(farmersId1);

        uint256 valueNFTZeroAlreadyWithdrawnAfterSecondWithdraw = splitter.getValueWithdrawnPerFarmer(0);
        uint256 valueNFTZeroCanWithdrawAfterSecondWithdraw = splitter.getTotalValueDistributedPerFarmer();

        assertEq(valueNFTZeroAlreadyWithdrawnAfterSecondWithdraw, valueNFTZeroCanWithdrawAfterSecondWithdraw);
        assertEq(valueNFTZeroCanWithdrawAfterSecondWithdraw, USER1.balance);

        assertTrue(splitter.getValueWithdrawnPerFarmer(1) == 10 ether);
        assertTrue(splitter.getTotalValueDistributedPerFarmer() == 20 ether);
        vm.prank(BARBA);
        assertTrue(splitter.getBalance() == 170 ether);
    }

    // function testSeOValorSacadoEhRecebidoCorretamentePeloNFTOwner() public {
    //     uint256 totalUser = s_users.length;

    //     for (uint256 i = 0; i < totalUser; i++) {
    //         farmers.safeMint(s_users[i], 10, "");
    //     }

    //     farmers.addSplitter(address(splitter));
    //     vm.prank(BARBA);
    //     payable(address(farmers)).transfer(VALUE_TO_TRANSFER);

    //     farmers.withdraw();

    //     uint256[] memory farmersId1 = new uint256[](10);
    //     farmersId1[0] = 0;
    //     farmersId1[1] = 1;
    //     farmersId1[2] = 2;
    //     farmersId1[3] = 3;
    //     farmersId1[4] = 4;
    //     farmersId1[5] = 5;
    //     farmersId1[6] = 6;
    //     farmersId1[7] = 7;
    //     farmersId1[8] = 8;
    //     farmersId1[9] = 9;

    //     vm.prank(USER1);
    //     splitter.verifyContractBalanceToDistribution(farmersId1);

    //     uint256 userOneBalance = USER1.balance;
    //     console.logUint(userOneBalance);
    //     assertEq(USER1.balance, 10 ether);

    //     assertEq(splitter.getBalance(), 90 ether);
    // }
}
