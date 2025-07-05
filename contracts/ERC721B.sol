// SPDX-License-Identifier: MIT
// Compatible with OpenZeppelin Contracts ^5.0.0
pragma solidity ^0.8.27;

import {ERC721} from "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import {Ownable} from "@openzeppelin/contracts/access/Ownable.sol";

contract ERC721B is ERC721, Ownable {
    uint256 public COLLECTION_SIZE = 10000;
    uint256 internal _nextTokenId;

    constructor(address initialOwner)
        ERC721("Whisky", "WK")
        Ownable(initialOwner)
    {}

    function _baseURI() internal pure override virtual returns (string memory) {
        return "ipfs://<cid>/";
    }

    function safeMint(address to) public payable returns (uint256) {
        require(_nextTokenId < COLLECTION_SIZE, "Maximum size reached");
        require(msg.value >= 0.001 ether, "Must send at least 0.001 ether");
        uint256 tokenId = _nextTokenId++;
        _safeMint(to, tokenId);
        return tokenId;
    }

    function withdraw() public onlyOwner {
        (bool success, ) = _msgSender().call{value: address(this).balance}("");
        require(success, "Withdraw Failed");
    }
}