// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "./ZombieHelper.sol";
import "./SafeMath.sol";

/**
 * @title Hợp đồng ZombieAttack
 * @dev Mở rộng hệ sinh thái Zombie bằng việc tích hợp hệ thống chiến đấu (combat system).
 * Quản lý logic tính toán tỷ lệ thắng thua và cập nhật chỉ số thống kê (stats) của các cá thể.
 */
contract ZombieAttack is ZombieHelper {

    /// @dev Tích hợp thư viện SafeMath cho các kiểu dữ liệu uint256, uint16 và uint32 để đảm bảo an toàn khi thực hiện các phép toán số học.
    using SafeMath for uint256;
    using SafeMath16 for uint16;
    using SafeMath32 for uint32;
    
    /// @dev Biến trạng thái (nonce) nội bộ dùng để tăng cường tính phân tán (entropy) cho thuật toán sinh số ngẫu nhiên.
    uint randNonce = 0;
    
    /// @dev Tỷ lệ phần trăm cơ sở để xác định chiến thắng khi chủ động tấn công (70%).
    uint attackVictoryProbability = 70;

    /**
     * @dev Thuật toán sinh số ngẫu nhiên giả (Pseudo-random number generator - PRNG) trên chuỗi.
     * Cảnh báo bảo mật: Trong các hệ thống tài chính thực tế (DeFi), việc sử dụng block.timestamp có thể bị thao túng bởi các thợ đào (Miners/Validators).
     * @param _modulus Giới hạn trên của dải số ngẫu nhiên cần sinh ra
     * @return Một số nguyên không dấu ngẫu nhiên trong khoảng từ 0 đến (_modulus - 1)
     */
    function randMod(uint _modulus) internal returns (uint) {
        // Tăng biến nonce để đảm bảo hash sinh ra ở mỗi giao dịch là duy nhất
        randNonce = randNonce.add(1);

        // Sử dụng thuật toán băm keccak256 kết hợp 3 tham số để tạo chuỗi ngẫu nhiên
        return uint(
            keccak256(
                abi.encodePacked(block.timestamp, msg.sender, randNonce)
            )
        ) % _modulus;
    }

    /**
     * @dev Giao diện thực thi lệnh tấn công giữa hai cá thể Zombie.
     * @param _zombieId ID của Zombie chủ động tấn công (thuộc sở hữu của người gọi hàm)
     * @param _targetId ID của Zombie mục tiêu (bị tấn công)
     */
    function attack(uint _zombieId, uint _targetId) external onlyOwnerOf(_zombieId) {
        // Khởi tạo các con trỏ storage để tham chiếu và thao tác trực tiếp trên cơ sở dữ liệu gốc
        Zombie storage myZombie = zombies[_zombieId];
        Zombie storage enemyZombie = zombies[_targetId];
        
        // Sinh số ngẫu nhiên từ 0 đến 99 để đánh giá kết quả trận chiến
        uint rand = randMod(100);

        if (rand <= attackVictoryProbability) {
            // Trường hợp chiến thắng: Cập nhật chỉ số và cấp độ cho cá thể tấn công
            myZombie.winCount = myZombie.winCount.add(1);
            myZombie.level = myZombie.level.add(1);
            enemyZombie.lossCount = enemyZombie.lossCount.add(1);
            
            // Kích hoạt cơ chế lai tạo với chuỗi DNA của cá thể bị đánh bại
            feedAndMultiply(_zombieId, enemyZombie.dna, "zombie");
        } else {
            // Trường hợp thất bại: Đảo ngược cập nhật chỉ số và áp dụng trạng thái chờ (cooldown)
            myZombie.lossCount = myZombie.lossCount.add(1);
            enemyZombie.winCount = enemyZombie.winCount.add(1);
            _triggerCooldown(myZombie);
        }
    }
}