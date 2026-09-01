// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

/**
 * @title Giao diện (Interface) ERC721
 * @dev Tiêu chuẩn cốt lõi cho các Non-Fungible Token (NFT) trên mạng lưới Ethereum.
 * Giao diện này định nghĩa các hàm cơ bản để truy vấn số dư, xác thực quyền sở hữu và thực thi chuyển nhượng.
 */
interface ERC721 {
    
    /**
     * @dev Sự kiện được kích hoạt khi quyền sở hữu của một token được chuyển giao.
     * @param _from Địa chỉ của chủ sở hữu hiện tại (người gửi)
     * @param _to Địa chỉ của người nhận token mới
     * @param _tokenId ID định danh duy nhất của token được chuyển giao
     */
    event Transfer(
        address indexed _from,
        address indexed _to,
        uint256 indexed _tokenId
    );

    /**
     * @dev Sự kiện được kích hoạt khi chủ sở hữu cấp quyền (ủy quyền) cho một địa chỉ khác quản lý token của mình.
     * @param _owner Địa chỉ của chủ sở hữu token thực sự
     * @param _approved Địa chỉ được ủy quyền để quản lý/chuyển nhượng token
     * @param _tokenId ID định danh duy nhất của token được ủy quyền
     */
    event Approval(
        address indexed _owner,
        address indexed _approved,
        uint256 indexed _tokenId
    );

    /**
     * @dev Truy vấn tổng số lượng token (NFT) thuộc quyền sở hữu của một địa chỉ cụ thể.
     * @param _owner Địa chỉ ví cần truy vấn
     * @return Số nguyên đại diện cho tổng số lượng token mà ví đó đang sở hữu
     */
    function balanceOf(address _owner) external view returns (uint256);

    /**
     * @dev Truy xuất địa chỉ của chủ sở hữu hiện tại của một token cụ thể.
     * @param _tokenId ID định danh của token cần tra cứu
     * @return Địa chỉ ví của chủ sở hữu token đó
     */
    function ownerOf(uint256 _tokenId) external view returns (address);

    /**
     * @dev Thực thi việc chuyển giao quyền sở hữu token từ địa chỉ này sang địa chỉ khác.
     * Lưu ý: Hàm này có thể được gọi bởi chủ sở hữu hoặc người đã được ủy quyền (thông qua hàm approve).
     * @param _from Địa chỉ của chủ sở hữu hiện tại
     * @param _to Địa chỉ của người nhận
     * @param _tokenId ID định danh của token cần chuyển
     */
    function transferFrom(
        address _from,
        address _to,
        uint256 _tokenId
    ) external payable;

    /**
     * @dev Cấp quyền kiểm soát (ủy quyền) một token cụ thể cho một địa chỉ bên thứ ba.
     * Yêu cầu: Người gọi (msg.sender) phải là chủ sở hữu hợp pháp của token đó.
     * @param _approved Địa chỉ của người được ủy quyền (broker/marketplace)
     * @param _tokenId ID định danh của token muốn mang ra ủy quyền
     */
    function approve(address _approved, uint256 _tokenId) external payable;
}