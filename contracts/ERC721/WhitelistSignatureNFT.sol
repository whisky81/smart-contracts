// SPDX-License-Identifier: MIT
pragma solidity ^0.8.27;

import {ERC721} from "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import {Ownable} from "@openzeppelin/contracts/access/Ownable.sol";

/// initialOwner(signer): 0xdaf6e75eaba1ed47648031fd0183c7baa87ac175
/// account: 0x5B38Da6a701c568545dCfcB03FcB875f56beddC4
/// tokenId: 0
/// signature: 0xb11184c3dede1154b9496ecf56ddfbdafabdea6d5ca61a7c6c6f9abe74c65b5501bb2f68fddb5ee9500d40f11b59daf65f61a409ebcad701f90491c51e3de36e1b

library ECDSA {
    /// https://eips.ethereum.org/EIPS/eip-191
    function toEthSignedMessage(bytes32 hash) internal pure returns(bytes32) {
        return keccak256(abi.encodePacked("\x19Ethereum Signed Message:\n32", hash));
    }

    function toEthSignedMessageV2(bytes32 dataToSign) internal pure returns(bytes32) {
        return keccak256(abi.encodePacked(bytes1(0x19), bytes1(0x45), "thereum Signed Message:\n32", dataToSign));
    }

    function recoverSigner(bytes32 hash, bytes memory signature) internal pure returns(address) {
        require(signature.length == 65, "Invalid Signature");
        bytes32 r;
        bytes32 s;
        uint8 v;

        assembly ("memory-safe") {
            r := mload(add(signature, 0x20))
            s := mload(add(signature, 0x40))
            v := byte(0, mload(add(signature, 0x60)))
        }

        return ecrecover(hash, v, r, s);
    }

    function verify(bytes32 hash, bytes memory signature, address signer) internal pure returns(bool) {
        return recoverSigner(hash, signature) == signer;
    }
}


contract WhitelistSignatureNFT is ERC721, Ownable {
    mapping(address => bool) private _mintedAddr;
    uint public constant COLLECTION_SIZE = 10000;

    constructor(address initialOwner) ERC721("Whisky", "W") Ownable(initialOwner) {} 

    function _baseURI() internal pure override returns(string memory) {
        return "ipfs://<cid>/";
    }

    function safeMint(address to, uint tokenId, bytes memory signature) external returns (uint256) {
        require(tokenId < COLLECTION_SIZE, "Out of range collection size");
        bytes32 msgHash = getMessageHash(to, tokenId);
        // bytes32 hash = ECDSA.toEthSignedMessage(msgHash);
        bytes32 hash = ECDSA.toEthSignedMessageV2(msgHash);

        require(ECDSA.verify(hash, signature, owner()), "Invalid Signature");
        require(!_mintedAddr[to], "Already Mint");

        require(_ownerOf(tokenId) == address(0), "Minted NFT");
        
        _mintedAddr[to] = true;
        _safeMint(to, tokenId);
        return tokenId;
    }


    function getMessageHash(address addr, uint tokenId) public pure returns(bytes32) {
        return keccak256(abi.encodePacked(addr, tokenId));
    }


}