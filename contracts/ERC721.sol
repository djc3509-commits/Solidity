// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

interface ERC721 {
    // Sự kiện phát ra khi quyền sở hữu NFT thay đổi.
    // Từ khóa 'indexed' hỗ trợ ứng dụng client (Frontend) lọc dữ liệu lịch sử giao dịch.
    event Transfer(
        address indexed _from,
        address indexed _to,
        uint256 indexed _tokenId
    );

    // Sự kiện phát ra khi chủ sở hữu ủy quyền cho một địa chỉ khác quản lý NFT.
    event Approval(
        address indexed _owner,
        address indexed _approved,
        uint256 indexed _tokenId
    );

    // Trả về số lượng NFT đang được sở hữu bởi một địa chỉ cụ thể.
    function balanceOf(address _owner) external view returns (uint256);

    // Trả về địa chỉ chủ sở hữu của một NFT thông qua ID.
    function ownerOf(uint256 _tokenId) external view returns (address);

    // Thực thi việc chuyển quyền sở hữu NFT từ địa chỉ này sang địa chỉ khác.
    function transferFrom(
        address _from,
        address _to,
        uint256 _tokenId
    ) external payable;

    // Cấp quyền cho một địa chỉ khác được phép giao dịch NFT chỉ định.
    function approve(address _approved, uint256 _tokenId) external payable;
}