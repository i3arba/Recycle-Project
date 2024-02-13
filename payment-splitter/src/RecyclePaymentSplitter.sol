// SPDX-License-Identifier: MIT
pragma solidity 0.8.20;

import {Ownable} from "@openzeppelin/contracts/access/Ownable.sol";
import {IERC721} from "@openzeppelin/contracts/token/ERC721/IERC721.sol";
import {Address} from "@openzeppelin/contracts/utils/Address.sol";
import{ReentrancyGuard} from "@openzeppelin/contracts/utils/ReentrancyGuard.sol";

error RecyclePaymentSplitter__OnlyFarmersContractCanSendEth();
error RecyclePaymentSplitter__NoValueToWithdraw();
error RecyclePaymentSplitter__OnlyMindsFarmerCanWithdraw();
error RecyclePaymentSplitter__InformYourTokenIdToWithdraw();

contract RecyclePaymentSplitter is Ownable, ReentrancyGuard{
    
    uint256 private s_totalValueReceived;
    uint256 private s_totalValueWithdrawn;
    uint256 private s_totalValueDistributedPerFarmerNFT;
    uint256 constant private FARMERS_SUPPLY = 100;
    
    //IERC721 constant private MINDS_FARMER = IERC721(0x2D91875FA696bDf3543ca0634258F6074Cc5df20);
    IERC721 immutable private MINDS_FARMER;
    
    mapping(uint256 tokenId => uint256 valueAlreadyPaid) private s_valueAlreadyPaidPerNFT;

    event RecyclePaymentSplitter__Withdrawal(address indexed account, uint256 indexed value);
    event RecyclePaymentSplitter__ValueReceived(uint256 indexed receivedValue, uint256 indexed valuePerNFT);
    
    constructor(address _owner, address _farmer) Ownable(_owner){
        MINDS_FARMER = IERC721(_farmer);
    }

    receive() external payable {
        if(msg.sender != address(MINDS_FARMER)){
            revert RecyclePaymentSplitter__OnlyFarmersContractCanSendEth();
        }
    }

    function verifyContractBalanceToDistribution(uint256[] memory _farmersId) external /*nonReentrant*/{
        if(_farmersId.length < 1){
            revert RecyclePaymentSplitter__InformYourTokenIdToWithdraw();
        }

        if((address(this).balance + s_totalValueWithdrawn) == s_totalValueReceived){
            _withdraw(_farmersId);
        } else {
            //Adiciona o novo valor recebido ao total já registrado
            s_totalValueReceived += ((address(this).balance + s_totalValueWithdrawn) - s_totalValueReceived);
            //Refaz o calculo de distribuição por NFT
            s_totalValueDistributedPerFarmerNFT = s_totalValueReceived / FARMERS_SUPPLY;

            _withdraw(_farmersId);
        }
    }

    /**
     * @notice This function is used to pull royalties from the contract
     * @dev Only MINDS Farmer with avaiable funds can withdraw
     */
    function _withdraw(uint256[] memory _farmersId) private nonReentrant {

        for(uint256 i = 0; i < _farmersId.length; i++){
            //Checks
            if(MINDS_FARMER.ownerOf(_farmersId[i]) != msg.sender){
                revert RecyclePaymentSplitter__OnlyMindsFarmerCanWithdraw();
            }
            
            if(s_valueAlreadyPaidPerNFT[_farmersId[i]] >= s_totalValueDistributedPerFarmerNFT){
                revert RecyclePaymentSplitter__NoValueToWithdraw();
            }

            //Effects
            uint256 valueToWithdraw = s_totalValueDistributedPerFarmerNFT - s_valueAlreadyPaidPerNFT[_farmersId[i]];

            //Armazena o valor recebido por NFT's
            s_valueAlreadyPaidPerNFT[_farmersId[i]] += valueToWithdraw;
            s_totalValueWithdrawn += valueToWithdraw;
        
            emit RecyclePaymentSplitter__Withdrawal(msg.sender, valueToWithdraw);
            
            //Interactions
            Address.sendValue(payable(msg.sender), valueToWithdraw);            
        }
    }

    function getTotalValueDistributedPerFarmer() external view returns(uint256){
        return s_totalValueDistributedPerFarmerNFT;
    }

    function getValueWithdrawnPerFarmer(uint256 _tokenId) external view returns(uint256){
        return s_valueAlreadyPaidPerNFT[_tokenId];
    }

    function getBalance() external view onlyOwner returns (uint256){
        return address(this).balance;
    }
}