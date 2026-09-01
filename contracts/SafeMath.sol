// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

/**
 * @title Thư viện SafeMath
 * @dev Cung cấp các phép toán an toàn cho kiểu uint256, tự động hoàn tác (revert) khi xảy ra lỗi tràn số (overflow/underflow).
 */
library SafeMath {

  /**
   * @dev Nhân hai số nguyên không dấu (a * b). Tự động hoàn tác nếu kết quả vượt giới hạn bộ nhớ (overflow).
   * @param a Số nhân thứ nhất
   * @param b Số nhân thứ hai
   * @return c Tích của hai số
   */
  function mul(uint256 a, uint256 b) internal pure returns (uint256) {
    if (a == 0) {
      return 0;
    }
    uint256 c = a * b;
    // Kiểm tra chéo: Tích chia cho số thứ nhất phải bằng đúng số thứ hai
    assert(c / a == b); 
    return c;
  }

  /**
   * @dev Chia hai số nguyên không dấu (a / b), trả về phần nguyên. Bỏ qua phần dư.
   * @param a Số bị chia
   * @param b Số chia
   * @return c Thương của phép chia
   */
  function div(uint256 a, uint256 b) internal pure returns (uint256) {
    // assert(b > 0); // Solidity đã tự động kiểm tra và báo lỗi hoàn tác khi chia cho 0
    uint256 c = a / b;
    return c;
  }

  /**
   * @dev Trừ hai số nguyên không dấu (a - b). Tự động hoàn tác nếu số trừ lớn hơn số bị trừ (underflow).
   * @param a Số bị trừ
   * @param b Số trừ
   * @return Hiệu của phép trừ
   */
  function sub(uint256 a, uint256 b) internal pure returns (uint256) {
    // Đảm bảo kết quả không bị âm
    assert(b <= a); 
    return a - b;
  }

  /**
   * @dev Cộng hai số nguyên không dấu (a + b). Tự động hoàn tác nếu kết quả vượt giới hạn bộ nhớ (overflow).
   * @param a Số hạng thứ nhất
   * @param b Số hạng thứ hai
   * @return c Tổng của hai số
   */
  function add(uint256 a, uint256 b) internal pure returns (uint256) {
    uint256 c = a + b;
    // Đảm bảo tổng sinh ra phải lớn hơn hoặc bằng các số hạng ban đầu
    assert(c >= a); 
    return c;
  }
}

/**
 * @title Thư viện SafeMath32
 * @dev Cung cấp các phép toán an toàn cho kiểu dữ liệu uint32, phòng chống lỗi tràn số trong phạm vi 32-bit.
 */
library SafeMath32 {

  /**
   * @dev Nhân hai số uint32 (a * b) với kiểm tra tràn số.
   * @param a Số nhân thứ nhất
   * @param b Số nhân thứ hai
   * @return c Tích của hai số
   */
  function mul(uint32 a, uint32 b) internal pure returns (uint32) {
    if (a == 0) {
      return 0;
    }
    uint32 c = a * b;
    assert(c / a == b);
    return c;
  }

  /**
   * @dev Chia hai số uint32 (a / b), trả về phần nguyên.
   * @param a Số bị chia
   * @param b Số chia
   * @return c Thương của phép chia
   */
  function div(uint32 a, uint32 b) internal pure returns (uint32) {
    // assert(b > 0); // Solidity tự động kiểm tra khi chia cho 0
    uint32 c = a / b;
    return c;
  }

  /**
   * @dev Trừ hai số uint32 (a - b) với kiểm tra underflow.
   * @param a Số bị trừ
   * @param b Số trừ
   * @return Hiệu của phép trừ
   */
  function sub(uint32 a, uint32 b) internal pure returns (uint32) {
    assert(b <= a);
    return a - b;
  }

  /**
   * @dev Cộng hai số uint32 (a + b) với kiểm tra overflow.
   * @param a Số hạng thứ nhất
   * @param b Số hạng thứ hai
   * @return c Tổng của hai số
   */
  function add(uint32 a, uint32 b) internal pure returns (uint32) {
    uint32 c = a + b;
    assert(c >= a);
    return c;
  }
}

/**
 * @title Thư viện SafeMath16
 * @dev Cung cấp các phép toán an toàn cho kiểu dữ liệu uint16, phòng chống lỗi tràn số trong phạm vi 16-bit.
 */
library SafeMath16 {

  /**
   * @dev Nhân hai số uint16 (a * b) với kiểm tra tràn số.
   * @param a Số nhân thứ nhất
   * @param b Số nhân thứ hai
   * @return c Tích của hai số
   */
  function mul(uint16 a, uint16 b) internal pure returns (uint16) {
    if (a == 0) {
      return 0;
    }
    uint16 c = a * b;
    assert(c / a == b);
    return c;
  }

  /**
   * @dev Chia hai số uint16 (a / b), trả về phần nguyên.
   * @param a Số bị chia
   * @param b Số chia
   * @return c Thương của phép chia
   */
  function div(uint16 a, uint16 b) internal pure returns (uint16) {
    // assert(b > 0); // Solidity tự động kiểm tra khi chia cho 0
    uint16 c = a / b;
    return c;
  }

  /**
   * @dev Trừ hai số uint16 (a - b) với kiểm tra underflow.
   * @param a Số bị trừ
   * @param b Số trừ
   * @return Hiệu của phép trừ
   */
  function sub(uint16 a, uint16 b) internal pure returns (uint16) {
    assert(b <= a);
    return a - b;
  }

  /**
   * @dev Cộng hai số uint16 (a + b) với kiểm tra overflow.
   * @param a Số hạng thứ nhất
   * @param b Số hạng thứ hai
   * @return c Tổng của hai số
   */
  function add(uint16 a, uint16 b) internal pure returns (uint16) {
    uint16 c = a + b;
    assert(c >= a);
    return c;
  }
}