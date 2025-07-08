// SPDX-License-Identifier: MIT
pragma solidity ^0.8.27;
import {itmap, IteratorMap} from "contracts/Itmap.sol";


contract TestItmap {
    itmap data;
    using IteratorMap for itmap;

    function insert(uint key, uint value) external returns(uint) {
        data.insert(key, value);
        return data.size;
    }

    function sum() external view returns(uint s) {
        for (uint i = data.iteratorStart(); data.iteratorValid(i); i = data.iteratorNext(i)) {
            (, uint value) = data.iteratorGet(i);
            s += value;
        }
    }

    function keySet() external view returns(uint[] memory) {
        return data.keySet();
    }

    function valueSet() external view returns(uint[] memory) {
        return data.valueSet();
    }

    function contains(uint key) external view returns(bool) {
        return data.contains(key);
    }

    function remore(uint key) external returns(bool) {
        return data.remove(key);
    }

    function get(uint key) external view returns(uint) {
        return data.data[key].value;
    }
}