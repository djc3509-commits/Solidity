import { network } from "hardhat";

console.log("--- Bắt đầu Deploy & Kiểm tra CryptoZombies ---");

// 1. Khởi tạo instance mạng cục bộ
const { viem } = await network.create({
  network: "hardhatMainnet",
  chainType: "l1",
});

// 2. Deploy contract
const cryptoZombies = await viem.deployContract("CryptoZombies");
console.log("Contract Address:", cryptoZombies.address);

// 3. Kiểm tra GHI dữ liệu: Gọi hàm tạo Zombie đầu tiên
console.log("\n-> Đang gọi createRandomZombie('ZombiePro')...");
const txHash = await cryptoZombies.write.createRandomZombie(["ZombiePro"]);
console.log("Giao dịch thành công, TxHash:", txHash);

// 4. Kiểm tra ĐỌC dữ liệu: Lấy thông tin Zombie index 0
const zombie0 = await cryptoZombies.read.zombies([0n]);

console.log("\n--- KẾT QUẢ DỮ LIỆU LƯU TRÊN ON-CHAIN ---");
console.log({
  Name: zombie0[0],
  DNA: zombie0[1].toString(),
  Level: Number(zombie0[2]),
  ReadyTime: Number(zombie0[3]),
  Wins: Number(zombie0[4]),
  Losses: Number(zombie0[5]),
});