// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "./ZombieFactory.sol";

/**
 * @title Giao diện (Interface) CryptoKitties
 * @dev Định nghĩa chữ ký hàm để tương tác chéo (cross-contract call) với hợp đồng CryptoKitties.
 */
interface KittyInterface {
    /**
     * @dev Truy xuất thông tin chi tiết của một con CryptoKitty.
     * Chỉ khai báo kiểu trả về, không chứa logic thực thi.
     */
    function getKitty(
        uint256 _id
    ) external view returns (
        bool isGestating,
        bool isReady,
        uint256 cooldownIndex,
        uint256 nextActionAt,
        uint256 siringWithId,
        uint256 birthTime,
        uint256 matronId,
        uint256 sireId,
        uint256 generation,
        uint256 genes // Chỉ số DNA của mèo cần trích xuất
    );
}

/**
 * @title Hợp đồng ZombieFeeding
 * @dev Quản lý logic cho ăn, lai tạo Zombie và tích hợp tương tác với các hợp đồng ngoại vi.
 */
contract ZombieFeeding is ZombieFactory {
    
    /// @dev Biến lưu trữ tham chiếu đến hợp đồng CryptoKitties hiện tại.
    KittyInterface kittyContract;

    /**
     * @dev Bộ lọc kiểm tra quyền kiểm soát của người gọi đối với một Zombie cụ thể.
     * @param _zombieId ID định danh của Zombie cần xác thực
     */
    modifier onlyOwnerOf(uint _zombieId) {
        require(msg.sender == zombieToOwner[_zombieId], "Khong phai chu cua con zombie nay");
        _;
    }

    /**
     * @dev Thiết lập hoặc cập nhật địa chỉ hợp đồng CryptoKitties. 
     * Ngăn chặn rủi ro hợp đồng ngoại vi bị lỗi hoặc thay đổi địa chỉ (Hard fork/Migration).
     * @param _address Địa chỉ mới của hợp đồng CryptoKitties
     */
    function setKittyContractAddress(address _address) external onlyOwner {
        kittyContract = KittyInterface(_address);
    }

    /**
     * @dev Cập nhật lại mốc thời gian hoàn thành hồi chiêu của Zombie vào cơ sở dữ liệu.
     * @param _zombie Con trỏ lưu trữ (storage) tham chiếu trực tiếp đến dữ liệu gốc của Zombie
     */
    function _triggerCooldown(Zombie storage _zombie) internal {
        _zombie.readyTime = uint32(block.timestamp + cooldownTime);
    }

    /**
     * @dev Xác thực trạng thái hồi chiêu của Zombie.
     * @param _zombie Con trỏ lưu trữ (storage) tham chiếu đến Zombie
     * @return Trạng thái boolean: true nếu đã hết hồi chiêu, false nếu đang chờ
     */
    function _isReady(Zombie storage _zombie) internal view returns (bool) {
        return (_zombie.readyTime <= block.timestamp);
    }

    /**
     * @dev Thuật toán lai tạo DNA lõi giữa Zombie hiện tại và một mục tiêu ngoại lai.
     * @param _zombieId ID của Zombie thực hiện lai tạo
     * @param _targetDna Chuỗi DNA của mục tiêu
     * @param _species Định danh loài của mục tiêu để kích hoạt các đặc điểm đột biến
     */
    function feedAndMultiply(uint _zombieId, uint _targetDna, string memory _species) internal onlyOwnerOf(_zombieId) {
        // Khởi tạo con trỏ storage để tham chiếu và thay đổi trạng thái gốc
        Zombie storage myZombie = zombies[_zombieId];

        // Xác thực điều kiện tiên quyết: Zombie phải ở trạng thái sẵn sàng
        require(_isReady(myZombie), "Zombie dang trong thoi gian hoi chieu");

        // Đảm bảo chuỗi DNA mục tiêu tuân thủ quy tắc độ dài (16 chữ số)
        _targetDna = _targetDna % dnaModulus; 
        
        // Thuật toán kết hợp gen (Trung bình cộng)
        uint newDna = (myZombie.dna + _targetDna) / 2; 

        // Kích hoạt đột biến nếu mục tiêu mang định danh "kitty"
        if (keccak256(abi.encodePacked(_species)) == keccak256(abi.encodePacked("kitty"))) {
            // Thay thế 2 chữ số cuối cùng của DNA thành '99' để đánh dấu gen đặc thù
            newDna = newDna - (newDna % 100) + 99;
        }

        // Khởi tạo thế hệ Zombie mới và kích hoạt thời gian chờ cho Zombie gốc
        _createZombie("NoName", newDna);
        _triggerCooldown(myZombie);
    }

    /**
     * @dev Cổng giao tiếp cho phép Zombie tương tác trực tiếp với một CryptoKitty.
     * @param _zombieId ID của Zombie thực thi
     * @param _kittyId ID của CryptoKitty mục tiêu trên hợp đồng ngoại vi
     */
    function feedOnKitty(uint _zombieId, uint _kittyId) public {
        uint kittyDna;

        // Trích xuất DNA mục tiêu thông qua gọi chéo hợp đồng.
        // Bỏ qua 9 tham số không cần thiết để tối ưu hóa bộ nhớ tạm.
        (, , , , , , , , , kittyDna) = kittyContract.getKitty(_kittyId);

        // Kích hoạt quy trình lai tạo với DNA vừa trích xuất
        feedAndMultiply(_zombieId, kittyDna, "kitty");
    }
}