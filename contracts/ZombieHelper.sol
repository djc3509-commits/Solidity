// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "./ZombieFeeding.sol";

contract ZombieHelper is ZombieFeeding {

  uint levelUpFee = 0.001 ether;

  // Modifier kiểm tra điều kiện level tối thiểu của Zombie
  modifier aboveLevel(uint _level, uint _zombieId) {
    require(zombies[_zombieId].level >= _level, "Zombie chua dat du level");
    _;
  }

  // 1. Hàm rút tiền: Rút toàn bộ doanh thu (ETH) về ví Admin bằng lệnh .call
  function withdraw() external onlyOwner {
    address payable _owner = payable(owner()); 
    (bool success, ) = _owner.call{value: address(this).balance}("");
    require(success, "Giao dich rut tien that bai!");
  }

  // 2. Hàm set giá: Cho phép Admin thay đổi giá niêm yết linh hoạt
  function setLevelUpFee(uint _fee) external onlyOwner {
    levelUpFee = _fee;
  }

  // Hàm thanh toán (payable): Mở cổng nhận tiền từ khách
  function levelUp(uint _zombieId) external payable {
    require(msg.value == levelUpFee, "So tien gui vao khong dung voi niem yet");
    zombies[_zombieId].level++;
  }

  // Đổi tên Zombie (Chỉ áp dụng khi đạt level 2 và phải là chủ sở hữu)
  function changeName(uint _zombieId, string calldata _newName) external aboveLevel(2, _zombieId) {
    require(msg.sender == zombieToOwner[_zombieId], "Khong phai chu so huu");
    zombies[_zombieId].name = _newName;
  }

  // Đổi DNA (Chỉ áp dụng khi đạt level 20 và phải là chủ sở hữu)
  function changeDna(uint _zombieId, uint _newDna) external aboveLevel(20, _zombieId) {
    require(msg.sender == zombieToOwner[_zombieId], "Khong phai chu so huu");
    zombies[_zombieId].dna = _newDna;
  }

  // Hàm Query trả Data: Miễn phí Gas hoàn toàn (view). 
  // Dùng mảng memory cấp phát cứng (Fixed size) và biến counter để hứng Data.
  function getZombiesByOwner(address _owner) external view returns(uint[] memory) {
    uint[] memory result = new uint[](ownerZombieCount[_owner]);
    uint counter = 0;
    
    // Quét toàn bộ Database để lọc ra ID Zombie của người này
    for (uint i = 0; i < zombies.length; i++) {
      if (zombieToOwner[i] == _owner) {
        result[counter] = i;
        counter++;
      }
    }
    return result; 
  }
}