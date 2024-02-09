// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import {ERC721} from "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import {ERC721URIStorage} from "@openzeppelin/contracts/token/ERC721/extensions/ERC721URIStorage.sol";
import {ERC721Burnable} from "@openzeppelin/contracts/token/ERC721/extensions/ERC721Burnable.sol";
import {Ownable} from "@openzeppelin/contracts/access/Ownable.sol";

error RecyclePaymentSplitter__InsuficientBalanceToWithdraw();

contract MindsFarmerMock is ERC721, ERC721URIStorage, ERC721Burnable {
    uint256 private _nextTokenId;
    address private s_splitter;

    event RecyclePaymentSplitter__ValueWithdrawn(uint256 valueToWithdraw);

    constructor()
        ERC721("MindsFarmers", "MOCK")
    {}

    receive() external payable {}

    function safeMint(address to, string memory uri) public returns(uint256){
        uint256 tokenId = _nextTokenId++;
        _safeMint(to, tokenId);
        _setTokenURI(tokenId, uri);
        return tokenId;
    }

    // The following functions are overrides required by Solidity.

    function tokenURI(uint256 tokenId)
        public
        view
        override(ERC721, ERC721URIStorage)
        returns (string memory)
    {
        return super.tokenURI(tokenId);
    }

    function supportsInterface(bytes4 interfaceId)
        public
        view
        override(ERC721, ERC721URIStorage)
        returns (bool)
    {
        return super.supportsInterface(interfaceId);
    }

    function getBalance() external view returns (uint256) {
        return address(this).balance;
    }

    function addSplitter(address _splitter) external {
        s_splitter = _splitter;
    }

    function withdraw() external {
        if(address(this).balance < 2) {
            revert RecyclePaymentSplitter__InsuficientBalanceToWithdraw();
        }

        uint256 valueToWithdraw = address(this).balance;

        emit RecyclePaymentSplitter__ValueWithdrawn(valueToWithdraw);

        payable(s_splitter).transfer(valueToWithdraw);
    }
}