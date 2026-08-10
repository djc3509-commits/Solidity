// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "./ZombieFactory.sol";

// 1. Interface: Định nghĩa "chữ ký" của hàm getKitty từ contract CryptoKitties.
// Chỉ cần khai báo kiểu trả về, không cần viết logic bên trong.
interface KittyInterface {
    function getKitty(
        uint256 _id
    )
        external
        view
        returns (
            bool isGestating,
            bool isReady,
            uint256 cooldownIndex,
            uint256 nextActionAt,
            uint256 siringWithId,
            uint256 birthTime,
            uint256 matronId,
            uint256 sireId,
            uint256 generation,
            uint256 genes // Ta chỉ quan tâm đến biến số 10 này (DNA của mèo)
        );
}

contract ZombieFeeding is ZombieFactory {
    // Biến lưu trữ địa chỉ của contract CryptoKitties trên mạng Ethereum
    KittyInterface kittyContract;

    // Modifier kiểm tra quyền sở hữu
    modifier ownerOf(uint _zombieId) {
        require(
            msg.sender == zombieToOwner[_zombieId],
            "Khong phai chu cua con zombie nay"
        );
        _;
    }

    // Cổng để Admin cập nhật địa chỉ CryptoKitties.
    // Tại sao không fix cứng? Vì nếu CryptoKitties bị hack hoặc đổi contract mới,
    // Admin vẫn có thể linh hoạt đổi địa chỉ mà không phải đập bỏ game của mình.
    function setKittyContractAddress(address _address) external onlyOwner {
        kittyContract = KittyInterface(_address);
    }

    // Cập nhật thời gian hồi chiêu. (block.timestamp thay cho now)
    // Dùng con trỏ 'storage' để ghi đè thẳng vào Database.
    function _triggerCooldown(Zombie storage _zombie) internal {
        _zombie.readyTime = uint32(block.timestamp + cooldownTime);
    }

    // Check xem đã hết thời gian hồi chiêu chưa.
    function _isReady(Zombie storage _zombie) internal view returns (bool) {
        return (_zombie.readyTime <= block.timestamp);
    }

    // Hàm nội bộ chứa logic lai tạo lõi
    function feedAndMultiply(
        uint _zombieId,
        uint _targetDna,
        string memory _species
    ) internal ownerOf(_zombieId) {
        // 2. Lôi con Zombie từ DB ra bằng con trỏ 'storage'
        Zombie storage myZombie = zombies[_zombieId];

        // 3. Rào cản logic: Check xem Zombie đã sẵn sàng chưa (hết cooldown)
        require(_isReady(myZombie), "Zombie dang trong thoi gian hoi chieu");

        _targetDna = _targetDna % dnaModulus; // Đảm bảo DNA mồi chỉ dài 16 số
        uint newDna = (myZombie.dna + _targetDna) / 2; // Thuật toán lai: Trung bình cộng 2 gen

        // 4. So sánh String thông qua mã Hash keccak256
        if (
            keccak256(abi.encodePacked(_species)) ==
            keccak256(abi.encodePacked("kitty"))
        ) {
            // 5. Nếu mồi là 'kitty', áp dụng trick toán học: Ép 2 số cuối thành 99 (Đánh dấu con lai)
            newDna = newDna - (newDna % 100) + 99;
        }

        // 6. Lưu xuống DB và kích hoạt Cooldown cho con Zombie vừa đi cắn mèo
        _createZombie("NoName", newDna);
        _triggerCooldown(myZombie);
    }

    // API Public: User gọi hàm này, truyền vào ID con Zombie của họ và ID con Mèo họ muốn cắn
    function feedOnKitty(uint _zombieId, uint _kittyId) public {
        uint kittyDna;

        // Gọi chéo (Cross-contract call) sang CryptoKitties.
        // Vì hàm getKitty trả về 10 biến, nhưng ta chỉ cần biến cuối cùng (genes),
        // nên ta để trống 9 dấu phẩy đầu tiên để tiết kiệm bộ nhớ.
        (, , , , , , , , , kittyDna) = kittyContract.getKitty(_kittyId);

        // Đưa DNA lấy được vào mồm Zombie
        feedAndMultiply(_zombieId, kittyDna, "kitty");
    }
}
