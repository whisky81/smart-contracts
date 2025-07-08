// SPDX-License-Identifier: MIT
pragma solidity ^0.8.27;

struct IndexValue {
    uint keyIndex;
    uint value;
}

struct KeyFlag {
    uint key;
    bool deleted;
}

struct itmap {
    mapping(uint key => IndexValue) data;
    KeyFlag[] keys;
    uint size;
}

library IteratorMap {
    function insert(itmap storage self, uint key, uint value) internal returns(bool replaced) {
        uint keyIndex = self.data[key].keyIndex;
        self.data[key].value = value;

        if (keyIndex > 0) {
            return true;
        }

        keyIndex = self.keys.length;
        self.data[key].keyIndex = keyIndex + 1;
        self.keys.push(KeyFlag(key, false));
        self.size++;
        return false;
    }

    function remove(itmap storage self, uint key) internal returns(bool) {
        uint keyIndex = self.data[key].keyIndex;
        if (keyIndex == 0) {
            return false;
        }

        delete self.data[key];
        self.keys[keyIndex - 1].deleted = true;
        self.size--;
        return true;
    }

    function contains(itmap storage self, uint key) internal view returns(bool) {
        return self.data[key].keyIndex > 0;
    }

    function keySet(itmap storage self) internal view returns(uint[] memory) {
        uint[] memory kset = new uint[](self.size);
        uint index = 0;
        for (uint i = 0; i < self.keys.length; i++) {
            if (self.keys[i].deleted == false) {
                kset[index] = self.keys[i].key;
                index++;
            }
        }
        return kset;
    }

    function valueSet(itmap storage self) internal view returns(uint[] memory) {
        uint[] memory vset = new uint[](self.size);
        uint index = 0;
        for (uint i = 0; i < self.keys.length; i++) {
            if (self.keys[i].deleted == false) {
               vset[index++] = self.data[self.keys[i].key].value;
            }
        }
        return vset;
    }

    function skipDeleted(itmap storage self, uint keyIndex) private view returns(uint) {
        while (keyIndex < self.keys.length && self.keys[keyIndex].deleted) {
            keyIndex++;
        }
        return keyIndex;
    }

    function iteratorStart(itmap storage self) internal view returns(uint) {
        return skipDeleted(self, 0);
    }

    function iteratorValid(itmap storage self, uint keyIndex) internal view returns(bool) {
        return keyIndex < self.keys.length;
    }

    function iteratorNext(itmap storage self, uint keyIndex) internal  view returns(uint) {
        return skipDeleted(self, keyIndex + 1);
    }

    function iteratorGet(itmap storage self, uint keyIndex) internal view returns(uint key, uint value) {
        key = self.keys[keyIndex].key;
        value = self.data[key].value;
    }

}
