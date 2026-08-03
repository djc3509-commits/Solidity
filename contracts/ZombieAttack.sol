// SPDX-License-Identifier: MIT
pragma solidity  ^0.8.0;

import "./ZombieHelper.sol";

contract ZombieAttack is ZombieHelper{
function test() public view returns (uint, uint) {
    uint randNonce = 0;

    uint random = uint(
        keccak256(
            abi.encodePacked(block.timestamp, msg.sender, randNonce)
        )
    ) % 100;

    randNonce++;

    uint random2 = uint(
        keccak256(
            abi.encodePacked(block.timestamp, msg.sender, randNonce)
        )
    ) % 100;

    return (random, random2);
}
}