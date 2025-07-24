// SPDX-License-Identifier: MIT
pragma solidity ^0.8.27;

/// Example:
/// prompt: what is blockchain?
/// createAt: 1753168697601
/// signature: 0xb1ae2bccf535c2dc0adb98332b38527d9a22552183393f03eb9ef98e0bad0a923a19d1b5a1e693006e81b35d28221b9b8ebd1a53df5c743d6efbacaf9970ac2f1b
/// signer: 0xdaf6e75eaba1ed47648031fd0183c7baa87ac175



contract EIP712Verifying {
    struct EIP712Domain {
        string name;
        string version;
        uint256 chainId;
        address verifyingContract;
    }

    struct Question {
        string prompt;
        uint256 createAt;
    }

    bytes32 constant EIP712DOMAIN_TYPEHASH = keccak256(
        "EIP712Domain(string name,string version,uint256 chainId,address verifyingContract)"
    );

    bytes32 constant QUESTION_TYPEHASH = keccak256(
        "Question(string prompt,uint256 createAt)"
    );

    bytes32 DOMAIN_SEPARATOR;

    constructor () {
        DOMAIN_SEPARATOR = hash(EIP712Domain({
            name: "EIP712Verifying Contract",
            version: "1",
            chainId: 1,
            verifyingContract: address(this)
        }));
    }

    function verify(string memory prompt, uint256 createAt, bytes memory signature, address signer) public view returns(bool) {
        

        require(signature.length == 65, "Invalid Signature");
        Question memory question = Question(prompt, createAt);
        bytes32 _hash = digest(question);

        bytes32 r;
        bytes32 s;
        uint8 v;

        assembly ("memory-safe") {
            r := mload(add(signature, 0x20))
            s := mload(add(signature, 0x40))
            v := byte(0, mload(add(signature, 0x60)))
        }

        return ecrecover(_hash, v, r, s) == signer;
    }


    function digest(Question memory question) internal view returns(bytes32) {
        return keccak256(abi.encodePacked(bytes1(0x19), bytes1(0x01), DOMAIN_SEPARATOR, hash(question)));
    }


    function hash(Question memory question) internal pure returns(bytes32) {
        return keccak256(abi.encode(
            QUESTION_TYPEHASH,
            keccak256(bytes(question.prompt)),
            question.createAt
        ));
    }


    function hash(EIP712Domain memory eip721Domain) internal pure returns(bytes32) {
        return keccak256(abi.encode(
            EIP712DOMAIN_TYPEHASH,
            keccak256(bytes(eip721Domain.name)),
            keccak256(bytes(eip721Domain.version)),
            eip721Domain.chainId,
            eip721Domain.verifyingContract
        ));
    }
}