// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract Ownable {
    // Biến trạng thái (State Variable) lưu trữ địa chỉ của chủ sở hữu contract.
    // Khai báo private để bảo vệ dữ liệu, không cho phép contract khác can thiệp trực tiếp.
    address private _owner;

    // Khai báo Event. Trong Web3, Event được dùng để ghi log vào Blockchain.
    // Từ khóa 'indexed' giúp các ứng dụng bên ngoài (DApps, The Graph) có thể filter/tìm kiếm log này.
    event OwnershipTransferred(
        address indexed previousOwner,
        address indexed newOwner
    );

    // Constructor chỉ thực thi ĐÚNG 1 LẦN khi transaction deploy contract được đào (mined).
    constructor() {
        _owner = msg.sender; // msg.sender ở đây chính là địa chỉ ví đã ký giao dịch deploy.
        emit OwnershipTransferred(address(0), _owner); // address(0) đại diện cho trạng thái ban đầu chưa có chủ.
    }

    // Hàm view (chỉ đọc dữ liệu từ State, không tốn Gas) để trả về địa chỉ owner hiện tại.
    function owner() public view returns (address) {
        return _owner;
    }

    // Modifier đóng vai trò là một điều kiện tiên quyết (Access Control) gắn vào các hàm khác.
    modifier onlyOwner() {
        require(isOwner(), "Ownable: caller is not the owner");
        _; // Nếu require pass, trình biên dịch sẽ nhúng nội dung của hàm được gắn modifier vào vị trí dấu _; này.
    }

    // Kiểm tra xem người gọi hàm (msg.sender) có khớp với địa chỉ _owner trong Storage hay không.
    function isOwner() public view returns (bool) {
        return msg.sender == _owner;
    }

    // Hủy bỏ hoàn toàn quyền kiểm soát contract.
    // Sau khi gọi, contract sẽ không còn owner, các hàm gắn onlyOwner sẽ vĩnh viễn bị khóa.
    function renounceOwnership() public onlyOwner {
        emit OwnershipTransferred(_owner, address(0));
        _owner = address(0);
    }

    // Chuyển giao quyền sở hữu cho một địa chỉ ví mới.
    function transferOwnership(address newOwner) public onlyOwner {
        _transferOwnership(newOwner);
    }

    // Hàm internal chứa logic lõi của việc chuyển quyền.
    // Chỉ có thể được gọi từ bên trong contract này hoặc các contract kế thừa nó.
    function _transferOwnership(address newOwner) internal {
        require(
            newOwner != address(0),
            "Ownable: new owner is the zero address"
        ); // Chặn rủi ro lỡ tay chuyển quyền vào ví chết.
        emit OwnershipTransferred(_owner, newOwner);
        _owner = newOwner;
    }
}
