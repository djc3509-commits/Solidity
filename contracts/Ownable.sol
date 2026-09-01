// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

/**
 * @title Hợp đồng Ownable
 * @dev Cung cấp module kiểm soát truy cập (Access Control) cơ bản, trong đó có một tài khoản (chủ sở hữu) 
 * được cấp quyền thực thi độc quyền đối với các hàm cụ thể.
 */
contract Ownable {
    
    /// @dev Biến trạng thái nội bộ lưu trữ địa chỉ của chủ sở hữu hợp đồng hiện tại.
    address private _owner;

    /**
     * @dev Sự kiện được kích hoạt khi quyền sở hữu hợp đồng được chuyển giao từ tài khoản này sang tài khoản khác.
     * @param previousOwner Địa chỉ của chủ sở hữu cũ
     * @param newOwner Địa chỉ của chủ sở hữu mới (có thể là address(0) nếu từ bỏ quyền)
     */
    event OwnershipTransferred(
        address indexed previousOwner,
        address indexed newOwner
    );

    /**
     * @dev Khởi tạo hợp đồng và thiết lập quyền sở hữu ban đầu cho tài khoản thực hiện triển khai (deployer).
     */
    constructor() {
        _owner = msg.sender;
        emit OwnershipTransferred(address(0), _owner);
    }

    /**
     * @dev Truy xuất địa chỉ của chủ sở hữu hợp đồng hiện tại.
     * @return Địa chỉ (address) của chủ sở hữu
     */
    function owner() public view returns (address) {
        return _owner;
    }

    /**
     * @dev Bộ lọc giới hạn quyền truy cập, ngăn chặn mọi tài khoản không phải là chủ sở hữu gọi hàm.
     * Tự động hoàn tác (revert) nếu người gọi (msg.sender) không khớp với trạng thái `_owner`.
     */
    modifier onlyOwner() {
        require(isOwner(), "Ownable: caller is not the owner");
        _;
    }

    /**
     * @dev Xác thực quyền kiểm soát của tài khoản đang thực thi giao dịch.
     * @return Trạng thái boolean: true nếu msg.sender là chủ sở hữu, ngược lại là false
     */
    function isOwner() public view returns (bool) {
        return msg.sender == _owner;
    }

    /**
     * @dev Từ bỏ quyền kiểm soát hợp đồng. 
     * Cảnh báo: Việc gọi hàm này sẽ gán quyền sở hữu về địa chỉ `address(0)`. Toàn bộ các hàm 
     * được bảo vệ bởi modifier `onlyOwner` sẽ vĩnh viễn không thể truy cập được nữa.
     */
    function renounceOwnership() public onlyOwner {
        emit OwnershipTransferred(_owner, address(0));
        _owner = address(0);
    }

    /**
     * @dev Chuyển giao quyền kiểm soát hợp đồng cho một tài khoản mới. Chỉ chủ sở hữu hiện tại mới được phép gọi.
     * @param newOwner Địa chỉ của chủ sở hữu mới
     */
    function transferOwnership(address newOwner) public onlyOwner {
        _transferOwnership(newOwner);
    }

    /**
     * @dev Hàm nội bộ (internal) xử lý logic lõi của tiến trình chuyển giao quyền sở hữu.
     * @param newOwner Địa chỉ của chủ sở hữu mới. Yêu cầu không được là địa chỉ trống (address 0) để tránh mất quyền kiểm soát do lỗi thao tác.
     */
    function _transferOwnership(address newOwner) internal {
        require(
            newOwner != address(0),
            "Ownable: new owner is the zero address"
        );
        emit OwnershipTransferred(_owner, newOwner);
        _owner = newOwner;
    }
}