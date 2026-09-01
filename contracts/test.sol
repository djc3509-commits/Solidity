// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

/**
 * @title Thư viện SafeMath
 * @dev Cung cấp các phép toán an toàn, tự động hoàn tác (throw/revert) khi xảy ra lỗi tràn số (overflow/underflow).
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
   * @dev Chia hai số nguyên không dấu (a / b), trả về phần nguyên. Bỏ qua (truncate) phần dư.
   * @param a Số bị chia
   * @param b Số chia
   * @return c Thương của phép chia
   */
  function div(uint256 a, uint256 b) internal pure returns (uint256) {
    // assert(b > 0); // Solidity đã tự động kiểm tra và báo lỗi hoàn tác khi chia cho 0
    uint256 c = a / b;
    // assert(a == b * c + a % b); // Quy tắc toán học cơ bản: Điều kiện này luôn luôn đúng nên không cần kiểm tra lại
    return c;
  }

  /**
   * @dev Trừ hai số nguyên không dấu (a - b). Tự động hoàn tác nếu số trừ lớn hơn số bị trừ (underflow).
   * @param a Số bị trừ
   * @param b Số trừ
   * @return Hiệu của phép trừ
   */
  function sub(uint256 a, uint256 b) internal pure returns (uint256) {
    // Đảm bảo kết quả không bị âm (vì uint không lưu được số âm)
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