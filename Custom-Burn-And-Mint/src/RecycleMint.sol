//SPX-License-Identifier: MIT

pragma solidity 0.8.20;

import {Farmers} from "../test/Mocks/Farmers.sol";
import {RecycleMindsPFP} from "../test/Mocks/MindsPFP.sol";

/////////////////////
/// CUSTOM ERRORS ///
/////////////////////
error RecycleMint_YouNeedToInformeTheAddresses(address farmers, address minds);
error RecycleMint_YouAreNotTheNFTOwner(address nftOwner, address caller);

contract RecycleMint{
    
    ///////////////////////////
    /// IMMUTABLE VARIABLES ///
    ///////////////////////////

    /// @dev ERC721 MindsFarmers
    Farmers private immutable i_farmers;
    /// @dev ERC721 RecycleMindsPFP
    RecycleMindsPFP private immutable i_minds;
    
    ///////////////////////
    /// STATE VARIABLES ///
    ///////////////////////
    uint256 private nftToBeMinted = 1838;
    uint256 private nftAlreadyMinted = 1;

    //////////////
    /// EVENTS ///
    //////////////
    event RecycleMint_RecycledAndMinted(uint256 _nftId, uint256 nftId);

    ///////////////////
    /// CONSTRUCTOR ///
    ///////////////////

    constructor (address _farmers, address _minds){
        if(_farmers == address(0) || _minds == address(0)){
            revert RecycleMint_YouNeedToInformeTheAddresses(_farmers, _minds);
        }
        i_farmers = Farmers(_farmers);
        i_minds = RecycleMindsPFP(_minds);
    }

    //////////////////////////
    /// EXTERNAL FUNCTIONS ///
    //////////////////////////
    function recycleAndMint(uint256 _nftId) external returns(uint256){
        address caller = msg.sender;
        //checks
        if(i_farmers.ownerOf(_nftId) != caller){
            revert RecycleMint_YouAreNotTheNFTOwner(i_farmers.ownerOf(_nftId), caller);
        }

        //effects
        ++nftAlreadyMinted;

        emit RecycleMint_RecycledAndMinted(_nftId, nftToBeMinted);

        //interactions
        i_farmers.burn(_nftId);
        i_minds.mintOperator(++nftToBeMinted, "", caller);

        return nftToBeMinted;
    }
}