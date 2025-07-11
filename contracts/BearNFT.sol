// SPDX-License-Identifier: MIT
// Compatible with OpenZeppelin Contracts ^5.0.0
pragma solidity ^0.8.27;

import {ERC721} from "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import {Ownable} from "@openzeppelin/contracts/access/Ownable.sol";
import {Strings} from "@openzeppelin/contracts/utils/Strings.sol";

/// https://sepolia.etherscan.io/address/0x68e43d2b99ab03747244a6e8b93a2651ee7f327d

contract BearNFT is ERC721, Ownable {
    using Strings for uint256;

    uint public constant COLLECTION_SIZE = 3;
    uint256 private _nextTokenId;

    constructor(address initialOwner)
        ERC721("Bear", "BR")
        Ownable(initialOwner)
    {}

    function _baseURI() internal pure override returns (string memory) {
        return "ipfs://bafybeifvmjebllj7qqy5n7kp7etaktlgxnepqcwhlmc5236qzfydhrnqxm/";
    }

    function tokenURI(uint256 tokenId) public view override returns (string memory) {
        _requireOwned(tokenId);

        string memory baseURI = _baseURI();
        return bytes(baseURI).length > 0 ? string.concat(baseURI, tokenId.toString(), ".json") : "";
    }

    function safeMint(address to) public onlyOwner returns (uint256) {
        require(_nextTokenId < COLLECTION_SIZE, "Out of range collection size");
        uint256 tokenId = _nextTokenId++;
        _safeMint(to, tokenId);
        return tokenId;
    }
}
