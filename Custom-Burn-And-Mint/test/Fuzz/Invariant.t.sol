//License SPX-Identifier: MIT
pragma solidity 0.8.20;

import {Test, console2} from "forge-std/Test.sol";
import {RecycleMint} from "../../src/RecycleMint.sol";
import {RecycleMintDeploy} from "../../script/RecycleMintDeploy.s.sol";
import {Farmers} from "../Mocks/Farmers.sol";
import {RecycleMindsPFP} from "../Mocks/MindsPFP.sol";

contract Invariant is Test{
	RecycleMint recycle;
    Farmers farmer;
    RecycleMindsPFP minds;
	
	address BARBA = makeAddr("BARBA");
  	address ATHENA = makeAddr("ATHENA");
	address RAFFA = makeAddr("RAFFA");
	address PUKA = makeAddr("PUKA");
    uint256 constant LAST_NFT_ID = 97;
    uint256 constant FIRST_NFT_TO_MINT = 1839;

	function setUp() external{
        farmer = new Farmers(BARBA);
        minds = new RecycleMindsPFP("Minds", "RM", BARBA, 98);

		RecycleMintDeploy deploy = new RecycleMintDeploy();
		recycle = deploy.run(address(farmer), address(minds));

        vm.startPrank(BARBA);
        for(uint256 i = 0; i <= 97; ++i){
            farmer.safeMint(BARBA);
        }

        minds.transferOperator(address(recycle));
        vm.stopPrank();
	}

    error ERC721NonexistentToken(uint256 tokenId);
    function testStatelessFuzzBreakTheInvariant(uint256 randomValue) public{
        if(randomValue > LAST_NFT_ID){
            return;
        }
        
        assertEq(farmer.ownerOf(randomValue), BARBA);

        vm.startPrank(BARBA);
        farmer.approve(address(recycle), randomValue);
        uint256 nftId = recycle.recycleAndMint(randomValue);
        vm.stopPrank();

        assertEq(farmer.ownerOf(randomValue), address(recycle));
        assertEq(minds.ownerOf(nftId), BARBA);

        assertEq(nftId, FIRST_NFT_TO_MINT);
    }
    
    error RecycleMint_YouAreNotTheNFTOwner(address nftOwner, address caller);
    function testIfANonHolderCanMint(uint256 randomValue) public {
        vm.startPrank(ATHENA);
        if(randomValue > LAST_NFT_ID){
            vm.expectRevert(abi.encodeWithSelector(ERC721NonexistentToken.selector, randomValue));
            uint256 nftId = recycle.recycleAndMint(randomValue);
        } else {
            vm.expectRevert(abi.encodeWithSelector(RecycleMint_YouAreNotTheNFTOwner.selector, BARBA, ATHENA));
            uint256 nftId = recycle.recycleAndMint(randomValue);
        }
        vm.stopPrank();
    }
}