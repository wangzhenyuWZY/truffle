// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

interface IZUCKMAX {
   function tokensOfOwner(address _owner) external view returns (uint[] memory);
   function balanceOf(address owner) external view returns(uint256);
   function getTypeIdByTokenId(uint256 tokenId) external view returns (uint256);
}