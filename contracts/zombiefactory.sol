// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "./owmable.sol";

// Kế thừa Ownable để sử dụng các tính năng phân quyền Admin sau này
contract ZombieFactory is Ownable {
    // Event bắn tín hiệu ra ngoài Blockchain mỗi khi một Zombie mới ra đời.
    // Frontend lắng nghe event này để cập nhật UI ngay lập tức mà không cần pull data.
    event NewZombie(uint zombieId, string name, uint dna);

    uint dnaDigits = 16;
    uint dnaModulus = 10 ** dnaDigits;
    uint cooldownTime = 1 days; // Đơn vị thời gian chuẩn của Solidity

    // Struct định nghĩa Schema của một Zombie.
    // Các biến uint32 được xếp cạnh nhau để tối ưu Slot Storage (Struct Packing).
    struct Zombie {
        string name;
        uint dna;
        uint32 level;
        uint32 readyTime;
    }

    // Mảng phẳng lưu trữ toàn bộ Zombie của game. Index của mảng chính là Zombie ID.
    Zombie[] public zombies;

    // Mapping lập chỉ mục: Truy vấn nhanh Zombie ID thuộc về Ví nào.
    mapping(uint => address) public zombieToOwner;
    // Mapping lập chỉ mục: Tra cứu nhanh một Ví đang sở hữu bao nhiêu con Zombie.
    mapping(address => uint) ownerZombieCount;

    // Hàm internal: Chỉ contract này và contract kế thừa nó mới gọi được.
    // Xử lý logic ghi vào Database.
    function _createZombie(string memory _name, uint _dna) internal {
        // block.timestamp (thay thế cho biến now ở bản cũ) trả về thời gian hiện tại của block.
        zombies.push(
            Zombie(_name, _dna, 1, uint32(block.timestamp + cooldownTime))
        );

        // Trong Solidity 0.8+, push không trả về độ dài mảng nữa.
        // ID của Zombie mới chính là độ dài mảng trừ đi 1.
        uint id = zombies.length - 1;

        zombieToOwner[id] = msg.sender;
        ownerZombieCount[msg.sender]++;

        emit NewZombie(id, _name, _dna);
    }

    // Hàm view nội bộ tạo DNA ngẫu nhiên (Pseudo-random) dựa trên chuỗi string.
    function _generateRandomDna(
        string memory _str
    ) private view returns (uint) {
        // keccak256 là thuật toán băm (hash) chuẩn của Ethereum.
        // abi.encodePacked dùng để nén chuỗi thành bytes trước khi băm.
        uint rand = uint(keccak256(abi.encodePacked(_str)));
        return rand % dnaModulus; // Đảm bảo DNA luôn có đúng 16 chữ số.
    }

    // Hàm Public: Cổng vào duy nhất cho người chơi mới.
    function createRandomZombie(string memory _name) public {
        // Rào chắn bảo mật: Đảm bảo ví này chưa từng nhận Zombie miễn phí nào.
        require(ownerZombieCount[msg.sender] == 0, "Ban da co Zombie roi!");

        uint randDna = _generateRandomDna(_name);
        randDna = randDna - (randDna % 100); // Mẹo toán học làm tròn DNA.

        _createZombie(_name, randDna);
    }
}
