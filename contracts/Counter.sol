// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

/**
 * @title Counter
 * @dev Contract mẫu để học và thực hành test với Hardhat 3 + viem.
 */
contract Counter {
    /// @dev Giá trị đếm hiện tại.
    uint256 public x;

    /**
     * @dev Phát khi giá trị counter tăng lên.
     * @param by Lượng tăng thêm
     */
    event Increment(uint256 by);

    /**
     * @dev Tăng counter lên 1.
     */
    function inc() external {
        x += 1;
        emit Increment(1);
    }

    /**
     * @dev Tăng counter lên một lượng tùy chỉnh.
     * @param amount Lượng cần tăng
     */
    function incBy(uint256 amount) external {
        x += amount;
        emit Increment(amount);
    }
}
