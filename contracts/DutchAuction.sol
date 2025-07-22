// SPDX-License-Identifier: MIT
pragma solidity ^0.8.27;

import {ERC721A} from "./ERC721/ERC721A.sol";

contract DutchAuction is ERC721A {

    // AUCTION State Variables
    uint256 public constant COLLECTION_SIZE = 10000;
    uint256 public constant AUCTION_START_PRICE = 1 ether;
    uint256 public constant AUCTION_END_PRICE = 0.1 ether;
    uint256 public constant AUCTION_DROP_INTERNAL = 1 minutes;
    uint256 public constant AUCTION_TIME = 10 minutes;
    uint256 public constant AUCTION_DROP_PER_STEP = 
        (AUCTION_START_PRICE - AUCTION_END_PRICE) /
        (AUCTION_TIME / AUCTION_DROP_INTERNAL);
    uint256 public auctionStartTime;

    error ExceedsCollectionSize(uint256 size);

    constructor(address initialOwner) ERC721A(initialOwner) {}

    function _baseURI() internal pure override returns (string memory) {
        return "ipfs://<cid>/";
    }

    // Auction Functions

    function setAuctionStartTime() public onlyOwner {
        if (_nextTokenId >= COLLECTION_SIZE) {
            revert ExceedsCollectionSize(_nextTokenId);
        }
        auctionStartTime = block.timestamp;
    }

    function getAuctionPrice() public view returns(uint256){
        if (auctionStartTime == 0) {
            return AUCTION_START_PRICE;
        } else if (auctionStartTime + AUCTION_TIME < block.timestamp) {
            return AUCTION_END_PRICE;
        } else {
            uint256 steps = (block.timestamp - auctionStartTime) / AUCTION_DROP_INTERNAL;
            return AUCTION_START_PRICE - AUCTION_DROP_PER_STEP * steps;
        }
    }

    function auctionMint(uint256 quantity) external payable {
        if (_nextTokenId + quantity > COLLECTION_SIZE) {
            revert ExceedsCollectionSize(_nextTokenId + quantity);
        }
        require(auctionStartTime != 0, "Auction Not Started");
        uint256 totalCost = quantity * getAuctionPrice();
        
        require(msg.value >= totalCost, "Need to send more ETH!");

        uint256 limit = _nextTokenId + quantity;
        while (_nextTokenId < limit) {
            uint256 tokenId = _nextTokenId++;
            _safeMint(_msgSender(), tokenId);
        }

        if (msg.value > totalCost) {
            payable(_msgSender()).transfer(msg.value - totalCost);
        }


    }

    function withdraw() public onlyOwner {
        (bool success, ) = _msgSender().call{value: address(this).balance}("");
        require(success, "Withdraw Failed");
    }
}
