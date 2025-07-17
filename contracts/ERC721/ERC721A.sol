// SPDX-License-Identifier: MIT
// Compatible with OpenZeppelin Contracts ^5.0.0
pragma solidity ^0.8.27;

import {ERC721} from "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import {Ownable} from "@openzeppelin/contracts/access/Ownable.sol";

contract ERC721A is ERC721, Ownable {
    uint256 internal _nextTokenId;

    constructor(address initialOwner)
        ERC721("Whisky", "WK")
        Ownable(initialOwner)
    {}

    function _baseURI() internal pure override virtual returns (string memory) {
        return "ipfs://<cid>/";
    }

    function safeMint(address to) public onlyOwner returns (uint256) {
        uint256 tokenId = _nextTokenId++;
        _safeMint(to, tokenId);
        return tokenId;
    }
}
