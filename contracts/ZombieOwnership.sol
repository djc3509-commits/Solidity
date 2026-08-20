// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "./ZombieAttack.sol";
import "./ERC721.sol";

contract ZombieOwnership is ZombieAttack, ERC721 {
    function balanceOf(address _owner) external view override returns (uint256) {

    }

    function ownerOf(uint256 _tokenId) external view override returns (address) {
        
    }

    function transferFrom(address _from, address _to, uint256 _tokenId) external payable override {
        
    }

    function approve(address _approved, uint256 _tokenId) external payable override {

    }
}