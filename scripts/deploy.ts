import { network } from "hardhat";

async function main() {
  console.log("--- Bắt đầu Deploy & Kiểm tra CryptoZombies ---");

  // 1. Khởi tạo kết nối theo Hardhat 3 API
  const { viem } = await network.create();

  // 2. Deploy contract (CryptoZombies đã được nhận diện kiểu dữ liệu)
  const cryptoZombies = await viem.deployContract("CryptoZombies");
  console.log("Contract Address:", cryptoZombies.address);

  // 3. Gọi hàm ghi (Write): Tham số truyền vào dạng mảng [...]
  console.log("\n-> Đang gọi createRandomZombie('ZombiePro')...");
  const txHash = await cryptoZombies.write.createRandomZombie(["ZombiePro"]);
  console.log("TxHash:", txHash);

  // 4. Chờ xác thực giao dịch trên network
  const publicClient = await viem.getPublicClient();
  await publicClient.waitForTransactionReceipt({ hash: txHash });

  // 5. Gọi hàm đọc (Read)
  const zombie0 = await cryptoZombies.read.zombies([0n]);
  console.log("Thông tin Zombie 0:", zombie0);
}

main().catch((error) => {
  console.error(error);
  process.exitCode = 1;
});
