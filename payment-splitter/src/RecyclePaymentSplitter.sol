// SPDX-License-Identifier: MIT
pragma solidity 0.8.20;

import {Ownable} from "@openzeppelin/contracts/access/Ownable.sol";
import {IERC721} from "@openzeppelin/contracts/token/ERC721/IERC721.sol";
import {Address} from "@openzeppelin/contracts/utils/Address.sol";
import{ReentrancyGuard} from "@openzeppelin/contracts/utils/ReentrancyGuard.sol";


error RecyclePaymentSplitter__NoValueToWithdraw();
error RecyclePaymentSplitter__OnlyMindsFarmerCanWithdraw();
error RecyclePaymentSplitter__InformYourTokenIdToWithdraw();

contract RecyclePaymentSplitter is Ownable, ReentrancyGuard{
    
    uint256 private s_totalValueDistributedPerFarmerNFT;
    uint256 immutable private i_farmersSupply = 98;
    
    IERC721 constant MINDS_FARMER = IERC721(0x2D91875FA696bDf3543ca0634258F6074Cc5df20);
    
    mapping(uint256 tokenId => uint256 valueAlreadyPaid) private s_valueAlreadyPaidPerNFT;

    event RecyclePaymentSplitter__Withdrawal(address indexed account, uint256 indexed value);
    
    constructor() Ownable(msg.sender){}
    //1. receber o valor depositado
    //2. dividir o valor igualmente entre os NFTs
    //3. atualizar o saldo disponível para retirada

    receive() external payable nonReentrant {
        //Busca o total de holders e Add 1 para deixar uma quantia de ether para o contrato
        uint256 farmers = i_farmersSupply + 1;

        //Inicia uma variável com o valor a ser dividido
        uint256 valueToSplit = msg.value;

        //Divide o valor entre os holders
        uint256 valuePerNFT = valueToSplit / farmers;

        //Atualiza o saldo disponível para retirada/holder
        s_totalValueDistributedPerFarmerNFT += valuePerNFT;
    }
    
    /**
     * @notice This function is used to pull royalties from the contract
     * @dev Only MINDS Farmer with avaiable funds can withdraw
     */
    function withdraw(uint256[] memory _farmersId) external nonReentrant{
        if(_farmersId.length < 1){
            revert RecyclePaymentSplitter__InformYourTokenIdToWithdraw();
        }
        
        for(uint256 i = 0; i < _farmersId.length; i++){
            if(MINDS_FARMER.ownerOf(_farmersId[i]) != msg.sender){
                revert RecyclePaymentSplitter__OnlyMindsFarmerCanWithdraw();

            } else if(s_valueAlreadyPaidPerNFT[_farmersId[i]] == s_totalValueDistributedPerFarmerNFT){
                revert RecyclePaymentSplitter__NoValueToWithdraw();
                
            } else {
                uint256 valueToWithdraw = s_totalValueDistributedPerFarmerNFT - s_valueAlreadyPaidPerNFT[_farmersId[i]];

                //Armazena o valor recebido por NFT's
                s_valueAlreadyPaidPerNFT[_farmersId[i]] += valueToWithdraw;
        
                emit RecyclePaymentSplitter__Withdrawal(msg.sender, valueToWithdraw);

                //Paga o valor para o farmer
                Address.sendValue(payable(msg.sender), valueToWithdraw);
            }
        }
    }

    function getTotalValueDistributedPerFarmer() external view returns(uint256){
        return s_totalValueDistributedPerFarmerNFT;
    }
}