// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "./ZombieAttack.sol";
import "./ERC721.sol";
import "./SafeMath.sol";

/**
 * @title Hợp đồng ZombieOwnership
 * @dev Triển khai tiêu chuẩn ERC721 cho phép quản lý quyền sở hữu, chuyển nhượng và ủy quyền NFT Zombie.
 * Kế thừa toàn bộ logic chiến đấu từ ZombieAttack và tuân thủ giao diện chuẩn ERC721.
 */
contract ZombieOwnership is ZombieAttack, ERC721 {

    /// @dev Tích hợp thư viện SafeMath cho kiểu uint để thực hiện các phép toán an toàn.
    using SafeMath for uint256;

    /// @dev Mapping lưu trữ thông tin ủy quyền (Approval): Tra cứu xem ID Zombie nào đang được cấp phép cho địa chỉ ví nào.
    mapping(uint256 => address) zombieApprovals;

    /**
     * @dev Truy vấn tổng số lượng Zombie mà một địa chỉ ví cụ thể đang sở hữu.
     * @param _owner Địa chỉ ví cần tra cứu
     * @return Số lượng token (NFT) thuộc quyền sở hữu của ví đó
     */
    function balanceOf(address _owner) external view override returns (uint256) {
        return ownerZombieCount[_owner];
    }

    /**
     * @dev Tra cứu địa chỉ chủ sở hữu hợp pháp của một con Zombie thông qua ID.
     * @param _tokenId ID định danh của Zombie
     * @return Địa chỉ ví của chủ sở hữu
     */
    function ownerOf(uint256 _tokenId) external view returns (address) {
        return zombieToOwner[_tokenId];
    }

    /**
     * @dev Hàm nội bộ (private) thực thi logic dịch chuyển tài sản, cập nhật số dư qua SafeMath và bắn sự kiện Transfer.
     * @param _from Địa chỉ của chủ sở hữu cũ
     * @param _to Địa chỉ của người nhận mới
     * @param _tokenId ID định danh của Zombie được chuyển nhượng
     */
    function _transfer(address _from, address _to, uint256 _tokenId) private {
        // Sử dụng SafeMath .add() và .sub() để tránh lỗi tràn số (overflow/underflow) khi thay đổi số dư
        ownerZombieCount[_to] = ownerZombieCount[_to].add(1);
        ownerZombieCount[_from] = ownerZombieCount[_from].sub(1);
        
        // Cập nhật lại chủ sở hữu mới cho Zombie
        zombieToOwner[_tokenId] = _to;
        
        // Phát sự kiện ghi nhận thay đổi quyền sở hữu lên blockchain
        emit Transfer(_from, _to, _tokenId);
    }

    /**
     * @dev Thực thi việc chuyển nhượng NFT từ người này sang người khác.
     * Yêu cầu: Người gọi hàm phải là chủ sở hữu thực sự HOẶC là người đã được cấp phép ủy quyền.
     * @param _from Địa chỉ chủ sở hữu hiện tại
     * @param _to Địa chỉ người nhận
     * @param _tokenId ID của Zombie cần chuyển
     */
    function transferFrom(address _from, address _to, uint256 _tokenId) external payable override {
        require(
            zombieApprovals[_tokenId] == msg.sender || zombieToOwner[_tokenId] == msg.sender,
            "Caller is not owner nor approved"
        );
        _transfer(_from, _to, _tokenId);
    }

    /**
     * @dev Cấp quyền quản lý tạm thời (ủy quyền) một con Zombie cho bên thứ ba.
     * Yêu cầu: Người gọi hàm phải chính là chủ sở hữu hợp pháp của con Zombie đó.
     * @param _approved Địa chỉ ví được cấp quyền quản lý
     * @param _tokenId ID của Zombie mang ra ủy quyền
     */
    function approve(address _approved, uint256 _tokenId) external payable override onlyOwnerOf(_tokenId) {
        zombieApprovals[_tokenId] = _approved;
        emit Approval(msg.sender, _approved, _tokenId);
    }
}