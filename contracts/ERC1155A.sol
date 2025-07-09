// SPDX-License-Identifier: MIT
// Compatible with OpenZeppelin Contracts ^5.0.0
pragma solidity ^0.8.27;

import {ERC1155} from "@openzeppelin/contracts/token/ERC1155/ERC1155.sol";
import {ERC1155Burnable} from "@openzeppelin/contracts/token/ERC1155/extensions/ERC1155Burnable.sol";
import {ERC1155Supply} from "@openzeppelin/contracts/token/ERC1155/extensions/ERC1155Supply.sol";
import {Ownable} from "@openzeppelin/contracts/access/Ownable.sol";
import {Strings} from "@openzeppelin/contracts/utils/Strings.sol";

contract MyToken is ERC1155, Ownable, ERC1155Burnable, ERC1155Supply {
    using Strings for uint256;
    constructor(address initialOwner)
        ERC1155("ipfs://<cid>/")
        Ownable(initialOwner)
    {}

    function setURI(string memory newuri) public onlyOwner {
        _setURI(newuri);
    }

    function mint(address account, uint256 id, uint256 amount, bytes memory data)
        public
        onlyOwner
    {
        _mint(account, id, amount, data);
    }

    function mintBatch(address to, uint256[] memory ids, uint256[] memory amounts, bytes memory data)
        public
        onlyOwner
    {
        _mintBatch(to, ids, amounts, data);
    }

    // The following functions are overrides required by Solidity.

    function _update(address from, address to, uint256[] memory ids, uint256[] memory values)
        internal
        override(ERC1155, ERC1155Supply)
    {
        super._update(from, to, ids, values);
    }

    // @Override
    function uri(uint256 id) public view override returns (string memory) {
        bytes memory hexVal = bytes(id.toHexString(32));
        bytes memory buffer = new bytes(hexVal.length - 2);

        for (uint256 i = 2; i < hexVal.length; i++) {
            buffer[i - 2] = hexVal[i];
        }
        
        string memory baseURI = super.uri(0);

        return string.concat(baseURI, string(buffer), ".json");
    }
}
