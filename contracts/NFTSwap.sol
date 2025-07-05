// SPDX-License-Identifier: MIT
pragma solidity ^0.8.27;

import "@openzeppelin/contracts/token/ERC721/IERC721.sol";
import "@openzeppelin/contracts/token/ERC721/IERC721Receiver.sol";
import {ERC721B} from "./ERC721B.sol";

// zero-fee decentralized NFT exchange
contract NFTSwap is IERC721Receiver {
    event List(address indexed seller, address indexed nftAddr, uint256 indexed tokenId, uint256 price);
    event Purchase(address indexed buyer, address indexed nftAddr, uint256 indexed tokenId, uint256 price);
    event Revoke(address indexed seller, address indexed nftAddr, uint256 indexed tokenId);
    event Update(address indexed seller, address indexed nftAddr, uint256 indexed tokenId, uint256 newPrice);

    struct Order {
        address owner;
        uint256 price;
    }

    mapping(address nftAddr => mapping(uint256 tokenId => Order)) public nftList;

    // fallback() external payable { }

    function list(address _nftAddr, uint256 _tokenId, uint256 _price) public {
        IERC721 nft = IERC721(_nftAddr);
        require(nft.getApproved(_tokenId) == address(this), "Need Approval");
        require(_price > 0, "Price Must be > 0");

        Order storage order = nftList[_nftAddr][_tokenId];
        order.owner = msg.sender;
        order.price = _price;

        nft.safeTransferFrom(msg.sender, address(this), _tokenId);

        emit List(msg.sender, _nftAddr, _tokenId, _price);
    }

    function revoke(address _nftAddr, uint256 _tokenId) public {
        IERC721 nft = _checkOwnerAndOrder(_nftAddr, _tokenId, msg.sender);

        nft.safeTransferFrom(address(this), msg.sender, _tokenId);
        delete nftList[_nftAddr][_tokenId];

        emit Revoke(msg.sender, _nftAddr, _tokenId);
    }

    function update(address _nftAddr, uint256 _tokenId, uint256 newPrice) public {
        _checkOwnerAndOrder(_nftAddr, _tokenId, msg.sender);
        require(newPrice > 0, "Price must be > 0");
        nftList[_nftAddr][_tokenId].price = newPrice;

        emit Update(msg.sender, _nftAddr, _tokenId, newPrice);
    }

    function purchase(address nftAddr, uint256 tokenId) public payable {
        Order storage order = nftList[nftAddr][tokenId];
        require(order.owner != msg.sender, "Owned this token");
        require(msg.value >= order.price, "Insufficient funds");

        IERC721 nft = IERC721(nftAddr);
        require(nft.ownerOf(tokenId) == address(this), "Invalid Order");

        nft.safeTransferFrom(address(this), msg.sender, tokenId);

        payable(order.owner).transfer(order.price);
        if (msg.value > order.price) {
            payable(msg.sender).transfer(msg.value - order.price);
        }
        
        emit Purchase(msg.sender, nftAddr, tokenId, order.price);

        delete nftList[nftAddr][tokenId];
    }

    function _checkOwnerAndOrder(address nftAddr, uint256 tokenId, address auth) internal view returns(IERC721 nft) {
        Order storage order = nftList[nftAddr][tokenId];

        require(order.owner == auth, "Not Owner");

        nft = IERC721(nftAddr);
        require(nft.ownerOf(tokenId) == address(this), "Invalid Order");
    }

    function onERC721Received(
        address operator,
        address from,
        uint256 tokenId,
        bytes calldata data
    ) external pure override returns (bytes4) {
        return IERC721Receiver.onERC721Received.selector;
    }
    
}