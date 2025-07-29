// SPDX-License-Identifier: MIT
pragma solidity ^0.8.27;

contract MultiCall {

    struct Call {
        address target;
        bool allowFailure;
        bytes data;
    }

    struct Result {
        bool success;
        bytes result;
    }

    function multicall(Call[] calldata calls) external returns(Result[] memory){
        uint len = calls.length;
        Result[] memory results = new Result[](len);
        
        for (uint i = 0; i < len; i++) {
            (results[i].success, results[i].result) = calls[i].target.call(calls[i].data);
            if (!(calls[i].allowFailure || results[i].success)) {
                revert("Multicall Failure");
            }
        }

        return results;
    }

    function signature(address wallet) external pure returns(bytes memory) {
        return abi.encodeWithSignature("balanceOf(address)", wallet);
    }
}