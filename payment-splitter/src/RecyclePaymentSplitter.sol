// SPDX-License-Identifier: MIT
pragma solidity 0.8.20;

import {IERC721} from "@openzeppelin/contracts/token/ERC721/IERC721.sol";
import {Address} from "@openzeppelin/contracts/utils/Address.sol";
import {ReentrancyGuard} from "@openzeppelin/contracts/utils/ReentrancyGuard.sol";

error RecyclePaymentSplitter__OnlyFarmersContractCanSendEth();
error RecyclePaymentSplitter__NoValueToWithdraw();
error RecyclePaymentSplitter__OnlyMindsFarmerCanWithdraw();
error RecyclePaymentSplitter__InformYourTokenIdToWithdraw();

/// @title RecyclePaymentSplitter
/// @author @i3arba
/// @notice This is a custom contract created to distribute royalties to the MINDS Farmer NFT holders and shouldn't be used for other purposes
/// @notice This custom contract is not audited
/// @dev This contract follow CEI patterns and relies on the OpenZeppelin ReentrancyGuard library to prevent reentrancy attacks
contract RecyclePaymentSplitter is ReentrancyGuard{
    
    /////////////////////
    ///STATE VARIABLES///
    /////////////////////

    /// @dev Total value received by the contract
    uint256 private s_totalValueReceived;
    /// @dev Total value withdrawn from the contract
    uint256 private s_totalValueWithdrawn;
    /// @dev Total value available to withdraw per farmer NFT
    uint256 private s_totalValueDistributedPerFarmerNFT;
    
    ///////////////
    ///CONSTANTS///
    ///////////////
    /// @dev Total supply of farmers NFT
    uint256 constant private FARMERS_SUPPLY = 100;
    
    ////////////////
    ///IMMUTABLES///
    ////////////////
    /// @dev MINDS Farmer contract
    IERC721 immutable private MINDS_FARMER;
    
    ////////////
    ///EVENTS///
    ////////////
    /// @param account Farmer NFT Holder
    /// @param value Value withdrawn
    event RecyclePaymentSplitter__Withdrawal(address indexed account, uint256 indexed value);
    /// @param valuePerNFT Total value that an NFT can withdraw
    event RecyclePaymentSplitter__ValuePerNftUpdated(uint256 indexed valuePerNFT);

    /////////////
    ///STORAGE///
    /////////////
    /// @dev Mapping to store the value already paid per NFT
    mapping(uint256 tokenId => uint256 valueAlreadyPaid) private s_valueAlreadyPaidPerNFT;

    /// @param _farmer MINDS Farmer contract address
    constructor(address _farmer){
        MINDS_FARMER = IERC721(_farmer);
    }

    /// @notice This function is used to receive ETH from the MINDS Farmer contract
    receive() external payable {
        if(msg.sender != address(MINDS_FARMER)){
            revert RecyclePaymentSplitter__OnlyFarmersContractCanSendEth();
        }
    }

    //////////////
    ///EXTERNAL///
    //////////////

    /// @param _farmersId Array of farmers NFT to withdraw
    /// @notice This function will verify the contract balance and take actions accordingly
    function verifyAndWithdraw(uint256[] memory _farmersId) external {
        if(_farmersId.length < 1){
            revert RecyclePaymentSplitter__InformYourTokenIdToWithdraw();
        }

        if((address(this).balance + s_totalValueWithdrawn) == s_totalValueReceived){
            _withdraw(_farmersId);
        } else {
            s_totalValueReceived += ((address(this).balance + s_totalValueWithdrawn) - s_totalValueReceived);
            s_totalValueDistributedPerFarmerNFT = s_totalValueReceived / FARMERS_SUPPLY;

            emit RecyclePaymentSplitter__ValuePerNftUpdated(s_totalValueDistributedPerFarmerNFT);

            _withdraw(_farmersId);
        }
    }

    /////////////
    ///PRIVATE///
    /////////////

    /**
     * @notice This function is used to pull royalties from the contract
     * @notice Caller must have the NFT in his wallet
     * @dev A Farmers onwer can withdraw only his royalties
     * @param _farmersId Array of farmers NFT to withdraw
     */
    function _withdraw(uint256[] memory _farmersId) private nonReentrant {
        uint256 valueToWithdraw;

        for(uint256 i = 0; i < _farmersId.length; i++){
            if(MINDS_FARMER.ownerOf(_farmersId[i]) != msg.sender){
                revert RecyclePaymentSplitter__OnlyMindsFarmerCanWithdraw();
            }
            
            if(s_valueAlreadyPaidPerNFT[_farmersId[i]] >= s_totalValueDistributedPerFarmerNFT){
                revert RecyclePaymentSplitter__NoValueToWithdraw();
            }

            valueToWithdraw += s_totalValueDistributedPerFarmerNFT - s_valueAlreadyPaidPerNFT[_farmersId[i]];

            s_valueAlreadyPaidPerNFT[_farmersId[i]] += s_totalValueDistributedPerFarmerNFT - s_valueAlreadyPaidPerNFT[_farmersId[i]];
        }

        s_totalValueWithdrawn += valueToWithdraw;
        emit RecyclePaymentSplitter__Withdrawal(msg.sender, valueToWithdraw);

        Address.sendValue(payable(msg.sender), valueToWithdraw);            
    }

    ///////////////////////////
    ///VIEW & PURE FUNCTIONS///
    ///////////////////////////

    /// @notice This function is used to get the total value received by the contract
    function getTotalValueDistributedPerFarmer() external view returns(uint256){
        return s_totalValueDistributedPerFarmerNFT;
    }

    /// @notice This function returns the value withdrawn by a specific farmer
    /// @param _tokenId Farmer NFT
    function getValueWithdrawnPerFarmer(uint256 _tokenId) external view returns(uint256){
        return s_valueAlreadyPaidPerNFT[_tokenId];
    }

    function getBalance() external view returns(uint256){
        return address(this).balance;
    }
}