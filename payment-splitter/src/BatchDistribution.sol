// SPDX-License-Identifier: MIT
pragma solidity 0.8.20;

import {Ownable} from "@openzeppelin/contracts/access/Ownable.sol";
import {IERC721} from "@openzeppelin/contracts/token/ERC721/IERC721.sol";
import {Address} from "@openzeppelin/contracts/utils/Address.sol";
import {ReentrancyGuard} from "@openzeppelin/contracts/utils/ReentrancyGuard.sol";

error RecyclePaymentSplitter__NoValueToWithdraw();
error RecyclePaymentSplitter__OnlyMindsFarmerCanWithdraw();
error RecyclePaymentSplitter__OnlyFarmersContractCanSendEth();

contract BatchDistribution is Ownable, ReentrancyGuard {

    uint256 immutable private i_farmersSupply = 98;

    mapping(uint256 nftId => uint256 valueReceived) private s_valueReceivedPerNFT;

    IERC721 constant MINDS_FARMER = IERC721(0x2D91875FA696bDf3543ca0634258F6074Cc5df20);

    constructor() Ownable(msg.sender) {}

    receive() external payable nonReentrant {
        if (msg.sender != address(MINDS_FARMER)) {
            revert RecyclePaymentSplitter__OnlyFarmersContractCanSendEth();
        }

        //Busca o total de holders e Add 1 para deixar uma quantia de ether para o contrato
        uint256 farmers = i_farmersSupply + 1;

        //Inicia uma variável com o valor a ser dividido
        uint256 valueToSplit = msg.value;

        //Divide o valor entre os holders
        uint256 valuePerNFT = valueToSplit / farmers;

        _distribution(valuePerNFT);
    }

    function _distribution(uint256 _value) private nonReentrant {
        //Realiza um loop pagando todos os farmers, por Id.
        for (uint256 i = 1; i < i_farmersSupply; i++) {
            //Armazena o valor recebido por NFT's
            s_valueReceivedPerNFT[i] += _value;

            //Paga o valor para o farmer
            payable(MINDS_FARMER.ownerOf(i)).transfer(_value);
        }
    }

    function getValueReceivedPerNFT(uint256 _nftId) external view returns (uint256) {
        return s_valueReceivedPerNFT[_nftId];
    }
}
