//License SPX-Identifier: MIT
pragma solidity 0.8.20;

import {Test, console2} from "forge-std/Test.sol";
import {RecycleMint} from "../../src/RecycleMint.sol";
import {RecycleMintDeploy} from "../../script/RecycleMintDeploy.s.sol";
import {Farmers} from "../Mocks/Farmers.sol";
import {RecycleMindsPFP} from "../Mocks/MindsPFP.sol";

contract RecycleMintTest is Test{
	RecycleMint recycle;
    Farmers farmer;
    RecycleMindsPFP minds;
	
	address BARBA = makeAddr("BARBA");
  	address ATHENA = makeAddr("ATHENA");
	address RAFFA = makeAddr("RAFFA");
	address PUKA = makeAddr("PUKA");


	function setUp() external{
        farmer = new Farmers(BARBA);
        minds = new RecycleMindsPFP("Minds", "RM", BARBA, 98);

		RecycleMintDeploy deploy = new RecycleMintDeploy();
		recycle = deploy.run(address(farmer), address(minds));

        vm.prank(BARBA);
        minds.transferOperator(address(recycle));
	}
	
	modifier mintAndDistribute() {
        vm.startPrank(BARBA);
            farmer.safeMint(BARBA);
            farmer.safeMint(ATHENA);
            farmer.safeMint(RAFFA);
            farmer.safeMint(PUKA);
        vm.stopPrank();
        _;
    }

    error RecycleMint_YouNeedToInformeTheAddresses(address farmers, address minds);
    function testIfConstructorRevertsFirst() public {
        vm.expectRevert(abi.encodeWithSelector(RecycleMint_YouNeedToInformeTheAddresses.selector, address(0), address(minds)));
        recycle = new RecycleMint(address(0), address(minds));
    }

    function testIfConstructorRevertsSecond() public {
        vm.expectRevert(abi.encodeWithSelector(RecycleMint_YouNeedToInformeTheAddresses.selector, address(farmer), address(0)));
        recycle = new RecycleMint(address(farmer), address(0));
    }

    error ERC721NonexistentToken(uint256 tokenId);
    function testIfRecycleAndMintRevertWithAllNftsMinted() public {
        vm.startPrank(BARBA);
        for(uint256 i = 0; i <= 97; ++i){
            farmer.safeMint(BARBA);
            farmer.approve(address(recycle), i);
            recycle.recycleAndMint(i);
        }

        
        vm.expectRevert(abi.encodeWithSelector(ERC721NonexistentToken.selector, 98));
        farmer.approve(address(recycle), 98);

        vm.stopPrank();
    }

    error RecycleMint_YouAreNotTheNFTOwner(address owner, address caller);
    function testIfRecycleAndMintRevert() public mintAndDistribute{
        uint256 tokensBeforeMint = minds.balanceOf(ATHENA);
        assertEq(tokensBeforeMint, 0);

        vm.prank(BARBA);
        farmer.approve(address(recycle), 0);
        
        address approvedAddress = farmer.getApproved(0);
        assertEq(approvedAddress, address(recycle));

        vm.startPrank(ATHENA);
        vm.expectRevert(abi.encodeWithSelector(RecycleMint_YouAreNotTheNFTOwner.selector, BARBA, ATHENA));
        recycle.recycleAndMint(0);
        vm.stopPrank();

        assertEq(farmer.ownerOf(0), BARBA);

        uint256 tokenAfterMint = minds.balanceOf(ATHENA);
        assertEq(tokenAfterMint, 0);
    }

    function testIfRecycleAndMintWorks() public mintAndDistribute{
        uint256 tokensBeforeMint = minds.balanceOf(ATHENA);
        assertEq(tokensBeforeMint, 0);

        vm.startPrank(ATHENA);
        farmer.approve(address(recycle), 1);
        uint256 nftId = recycle.recycleAndMint(1);
        vm.stopPrank();

        assertEq(nftId, 1839);

        uint256 tokenAfterMint = minds.balanceOf(ATHENA);
        assertEq(tokenAfterMint, 1);
    }
}