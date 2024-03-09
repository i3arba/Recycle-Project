// SPDX-License-Identifier: AGPL-3.0

/// @title Minds BR

/*⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀
⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀
⠀⠀⠀⠀⠀⠀⠀⠀⠀⢀⣀⣀⡶⠶⠶⠶⠶⠶⣀⣀⡀⠀⠀⠀⠀⠀⠀⠀⠀⠀
⠀⠀⠀⠀⠀⠀⠀⢀⡰⠾⠿⣏⡷⣀⠀⠀⣀⠀⠉⠉⠱⢆⡀⠀⠀⠀⠀⠀⠀⠀
⠀⠀⠀⠀⠀⠀⢰⡎⠁⠀⠀⢹⠁⣿⠀⠶⣉⠶⠀⠀⠀⠈⢱⡆⠀⠀⠀⠀⠀⠀
⠀⠀⠀⠀⠀⠀⢸⡇⠀⠀⠀⠀⠀⣿⠀⠀⠉⠀⠀⠀⠀⠀⢸⡇⠀⠀⠀⠀⠀⠀
⠀⠀⠀⠀⠀⢸⣿⣥⣤⣤⣤⣤⣤⣿⣤⣤⣤⣤⣤⣤⣤⣤⣤⣼⡇⠀⠀⠀⠀⠀
⠀⠀⠀⠀⠀⠀⠀⢸⡇⢸⣿⠛⠀⠀⠀⠀⠛⣿⠛⠀⠘⢻⡇⠀⠀⠀⠀⠀⠀⠀
⠀⠀⠀⠀⠀⠀⠀⠈⢡⡄⠘⠀⠀⠀⣿⠀⠀⠀⠋⠠⡇⢸⡇⠀⠀⠀⠀⠀⠀⠀
⠀⠀⠀⠀⠀⠀⠀⠀⢈⣡⡀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠸⠇⠀⠀⠀⠀⠀⠀⠀
⠀⠀⠀⠀⠀⠀⠀⢀⣸⣿⣿⣿⣿⣿⣿⣿⣿⣉⣿⣿⣏⡁⠀⠀⠀⠀⠀⠀⠀⠀
⠀⠀⠀⠀⠀⠀⠀⢸⡿⠿⢿⣿⣏⣉⣿⣿⣿⢿⣿⣿⡹⢷⡆⠀⠀⠀⠀⠀⠀⠀
⠀⠀⠀⠀⠀⠀⠀⠈⠱⠶⢾⣿⣿⣿⣿⣿⣿⣾⣿⣿⡷⠎⠁⠀⠀⠀⠀⠀⠀⠀
⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⢸⠟⠉⠉⠉⠉⠉⠉⠉⡿⠃⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀

*/
pragma solidity 0.8.20;

import {ERC721} from "@solmate/tokens/ERC721.sol";
import {Owned} from "@solmate/auth/Owned.sol";
import {ReentrancyGuard} from "@solmate/utils/ReentrancyGuard.sol";

error MaxSupply();
error NonExistentTokenURI();
error NotOperator();

contract RecycleMindsPFP is ERC721, Owned, ReentrancyGuard {
    /*//////////////////////////////////////////////////////////////
                                 EVENTS
    //////////////////////////////////////////////////////////////*/

    event Mint(address indexed to, uint256 indexed id);

    /*//////////////////////////////////////////////////////////////
                         METADATA STORAGE/LOGIC
    //////////////////////////////////////////////////////////////*/
    uint256 private currentTokenId;
    uint256 public immutable totalSupplyPFP;
    mapping(uint256 => string) private _tokenURIs;
    address public operator;

    constructor(
        string memory nameNFT,
        string memory symbolNFT,
        address ownerContract,
        uint256 supply
    ) ERC721(nameNFT, symbolNFT) Owned(ownerContract) {
        operator = owner;
        totalSupplyPFP = supply;
    }

    function mint(
        uint256 tokenID,
        string memory tokenUri,
        address recipient
    ) external onlyOwner {
        _mint(tokenID, tokenUri, recipient);
    }

    function mintOperator(
        uint256 tokenID,
        string memory tokenUri,
        address recipient
    ) external {
        if (msg.sender == operator) {
            _mint(tokenID, tokenUri, recipient);
        } else {
            revert NotOperator();
        }
    }

    function transferOperator(address newOperator) public onlyOwner {
        require(address(newOperator) != address(0));
        operator = newOperator;
    }

    function tokenURI(
        uint256 tokenId
    ) public view virtual override returns (string memory) {
        require(_exists(tokenId), "RecycleMindsPFP: invalid token ID");

        string memory _tokenURI = _tokenURIs[tokenId];
        return _tokenURI;
    }

    function setTokenURI(
        uint256 tokenId,
        string memory tokenUri
    ) public onlyOwner {
        _setTokenURI(tokenId, tokenUri);
    }

    function burn(uint256 tokenId) public {
        require(_exists(tokenId), "RecycleMindsPFP: invalid token ID");
        require(
            ownerOf(tokenId) == msg.sender,
            "RecycleMindsPFP: only owner token can burn"
        );

        super._burn(tokenId);
        delete _tokenURIs[tokenId];
    }

    function getCurrentQtd() external view onlyOwner returns (uint256) {
        return currentTokenId;
    }

    function totalSupply() public view virtual returns (uint256) {
        return currentTokenId;
    }

    function maxSupply() public view returns (uint256) {
        return totalSupplyPFP;
    }

    function _mint(
        uint256 tokenID,
        string memory tokenUri,
        address recipient
    ) internal nonReentrant {
        ++currentTokenId;
        if (currentTokenId > totalSupplyPFP) {
            revert MaxSupply();
        }

        _safeMint(recipient, tokenID);
        _setTokenURI(tokenID, tokenUri);

        emit Mint(recipient, tokenID);
    }

    function _setTokenURI(
        uint256 tokenID,
        string memory tokenUri
    ) internal virtual {
        require(
            _exists(tokenID),
            "RecycleMindsPFP: URI set of nonexistent token"
        );
        _tokenURIs[tokenID] = tokenUri;
    }

    function _exists(uint256 tokenId) internal view virtual returns (bool) {
        return _ownerOf[tokenId] != address(0);
    }

    function withdrawPayments(
        address payable payTO,
        uint256 amount
    ) external onlyOwner {
        require(address(payTO) != address(0));
        payTO.transfer(amount);
    }
}