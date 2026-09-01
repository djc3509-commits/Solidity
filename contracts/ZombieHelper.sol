// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "./ZombieFeeding.sol";

/**
 * @title Hợp đồng ZombieHelper
 * @dev Cung cấp các chức năng phụ trợ quản lý Zombie (tăng cấp, đổi tên, đổi DNA) và quản lý tài chính cho Admin.
 */
contract ZombieHelper is ZombieFeeding {

    /// @dev Tích hợp thư viện SafeMath32 để phòng tránh lỗi tràn số cho kiểu uint32.
    using SafeMath32 for uint32;
    
    /// @dev Phí mặc định để người chơi tăng 1 cấp cho Zombie (đơn vị: Wei)
    uint levelUpFee = 0.001 ether;

    /**
     * @dev Bộ lọc kiểm tra cấp độ tối thiểu của Zombie trước khi thực thi hàm.
     * @param _level Cấp độ tối thiểu yêu cầu
     * @param _zombieId ID định danh của Zombie cần kiểm tra
     */
    modifier aboveLevel(uint _level, uint _zombieId) {
        require(zombies[_zombieId].level >= _level, "The zombie has not yet reached the required level.");
        _;
    }

    /**
     * @dev Cho phép chủ sở hữu hợp đồng (Admin) rút toàn bộ ETH đang lưu trữ trong hợp đồng về ví.
     * Tự động hoàn tác (revert) nếu giao dịch chuyển tiền thất bại.
     */
    function withdraw() external onlyOwner {
        address payable _owner = payable(owner());
        (bool success, ) = _owner.call{value: address(this).balance}("");
        require(success, "Withdrawal transaction failed!");
    }

    /**
     * @dev Cập nhật lại mức phí tăng cấp cho Zombie. Chỉ Admin mới có quyền thực thi.
     * @param _fee Mức phí mới được áp dụng (đơn vị: Wei)
     */
    function setLevelUpFee(uint _fee) external onlyOwner {
        levelUpFee = _fee;
    }

    /**
     * @dev Tăng 1 cấp cho Zombie thông qua giao dịch thanh toán ETH.
     * @param _zombieId ID của Zombie cần tăng cấp
     */
    function levelUp(uint _zombieId) external payable {
        require(msg.value == levelUpFee, "So tien gui vao khong dung voi niem yet");
        zombies[_zombieId].level = zombies[_zombieId].level.add(1);
    }

    /**
     * @dev Thay đổi tên của Zombie. Yêu cầu: Zombie đạt tối thiểu cấp 2 và người gọi phải là chủ sở hữu.
     * @param _zombieId ID của Zombie cần đổi tên
     * @param _newName Tên mới muốn cập nhật
     */
    function changeName(uint _zombieId, string calldata _newName) external aboveLevel(2, _zombieId) onlyOwnerOf(_zombieId) {
        zombies[_zombieId].name = _newName;
    }

    /**
     * @dev Thay đổi DNA (ngoại hình) của Zombie. Yêu cầu: Zombie đạt tối thiểu cấp 20 và người gọi phải là chủ sở hữu.
     * @param _zombieId ID của Zombie cần đổi DNA
     * @param _newDna Mã DNA mới (số nguyên)
     */
    function changeDna(uint _zombieId, uint _newDna) external aboveLevel(20, _zombieId) onlyOwnerOf(_zombieId) {
        zombies[_zombieId].dna = _newDna;
    }

    /**
     * @dev Truy xuất danh sách toàn bộ ID Zombie thuộc sở hữu của một địa chỉ ví.
     * @param _owner Địa chỉ ví cần truy vấn
     * @return Mảng động chứa các ID Zombie thuộc sở hữu của địa chỉ ví đó
     */
    function getZombiesByOwner(address _owner) external view returns(uint[] memory) {
        // Khởi tạo mảng trong bộ nhớ tạm (memory) với độ dài bằng đúng số Zombie người đó sở hữu
        uint[] memory result = new uint[](ownerZombieCount[_owner]);
        uint counter = 0;

        for(uint i = 0; i < zombies.length; i++) {
            if(zombieToOwner[i] == _owner) {
                result[counter] = i;
                counter++;
            }
        }

        return result;
    }
}