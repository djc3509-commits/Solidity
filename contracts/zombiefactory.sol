// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "./Ownable.sol";
import "./SafeMath.sol";

/**
 * @title Hợp đồng ZombieFactory
 * @dev Hợp đồng cơ sở (base contract) quản lý việc khởi tạo và lưu trữ trạng thái của hệ sinh thái Zombie.
 * Kế thừa Ownable để hỗ trợ phân quyền quản trị (Admin).
 */
contract ZombieFactory is Ownable {

    /// @dev Tích hợp thư viện SafeMath để phòng tránh lỗi tràn số (overflow/underflow) cho kiểu uint256.
    using SafeMath for uint256;

    /// @dev Tích hợp thư viện SafeMath32 để phòng tránh lỗi tràn số cho kiểu uint32.
    using SafeMath32 for uint32;

    /// @dev Tích hợp thư viện SafeMath16 để phòng tránh lỗi tràn số cho kiểu uint16.
    using SafeMath16 for uint16;

    /**
     * @dev Phát (emit) tín hiệu khi một cá thể Zombie mới được khởi tạo thành công.
     * @param zombieId ID định danh duy nhất của Zombie vừa tạo
     * @param name Tên của Zombie
     * @param dna Mã gen (DNA) của Zombie
     */
    event NewZombie(uint zombieId, string name, uint dna);

    /// @dev Số lượng chữ số tối đa cho cấu trúc DNA của Zombie.
    uint dnaDigits = 16;
    /// @dev Modulus dùng để đảm bảo DNA luôn nằm trong phạm vi 16 chữ số.
    uint dnaModulus = 10 ** dnaDigits;
    /// @dev Thời gian chờ (cooldown) mặc định giữa các lần tương tác của Zombie.
    uint cooldownTime = 1 days; 

    /**
     * @dev Cấu trúc dữ liệu cốt lõi định nghĩa các thuộc tính của một Zombie.
     * Thuật toán Struct Packing: Các biến kích thước nhỏ (uint32, uint16) được xếp cạnh nhau để tối ưu hóa không gian lưu trữ (Storage Slot), giúp giảm thiểu phí Gas.
     */
    struct Zombie {
        string name;
        uint dna;
        uint32 level;
        uint32 readyTime;
        uint16 winCount;
        uint16 lossCount;
    }

    /// @dev Mảng động lưu trữ toàn bộ cá thể Zombie. Chỉ số (index) của mảng đóng vai trò là ID định danh (Zombie ID).
    Zombie[] public zombies;

    /// @dev Ánh xạ (Mapping) từ ID của Zombie sang địa chỉ ví của chủ sở hữu hợp pháp.
    mapping(uint => address) public zombieToOwner;

    /// @dev Ánh xạ lưu trữ tổng số lượng Zombie mà một địa chỉ ví cụ thể đang kiểm soát.
    mapping(address => uint) ownerZombieCount;

    /**
     * @dev Hàm nội bộ (internal) xử lý logic khởi tạo và ghi dữ liệu Zombie mới vào chuỗi khối (Blockchain).
     * @param _name Tên được chỉ định cho Zombie
     * @param _dna Mã gen DNA đã được tính toán cho Zombie
     */
    function _createZombie(string memory _name, uint _dna) internal {
        // Khởi tạo đối tượng Zombie mới và đẩy vào mảng lưu trữ
        zombies.push(
            Zombie(_name, _dna, 1, uint32(block.timestamp + cooldownTime), 0, 0)
        );

        // Trích xuất ID của Zombie vừa tạo (độ dài mảng trừ 1)
        uint id = zombies.length - 1;

        // Cập nhật cơ sở dữ liệu về quyền sở hữu
        zombieToOwner[id] = msg.sender;
        ownerZombieCount[msg.sender] = ownerZombieCount[msg.sender].add(1);

        // Kích hoạt sự kiện thông báo cho Frontend
        emit NewZombie(id, _name, _dna);
    }

    /**
     * @dev Hàm nội bộ sinh ra mã DNA giả ngẫu nhiên (Pseudo-random) dựa trên chuỗi ký tự đầu vào.
     * @param _str Chuỗi ký tự hạt giống (seed string) để băm
     * @return Mã DNA số nguyên không dấu gồm đúng 16 chữ số
     */
    function _generateRandomDna(string memory _str) private view returns (uint) {
        // Sử dụng thuật toán băm keccak256 và nén dữ liệu qua abi.encodePacked
        uint rand = uint(keccak256(abi.encodePacked(_str)));
        return rand % dnaModulus; 
    }

    /**
     * @dev Cổng giao tiếp công khai (Public API) cho phép người dùng khởi tạo Zombie đầu tiên (miễn phí).
     * @param _name Tên do người dùng đặt cho Zombie
     */
    function createRandomZombie(string memory _name) public {
        // Xác thực bảo mật: Đảm bảo ví thực thi chưa từng nhận Zombie nào trước đó
        require(ownerZombieCount[msg.sender] == 0, "Ban da co Zombie roi!");

        // Khởi tạo DNA ngẫu nhiên
        uint randDna = _generateRandomDna(_name);
        
        // Cấu trúc lại DNA: Đưa 2 chữ số cuối cùng về '00' (Dành không gian cho các đột biến lai tạo sau này)
        randDna = randDna - (randDna % 100); 

        // Gọi hàm nội bộ để ghi vào Blockchain
        _createZombie(_name, randDna);
    }
}