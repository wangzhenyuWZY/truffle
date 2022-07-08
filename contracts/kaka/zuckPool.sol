// SPDX-License-Identifier: MIT
pragma solidity >=0.8.9;
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/token/ERC721/IERC721.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "./IZUCKMAX.sol";

contract ZuckPool is Ownable{
    struct Meta {
        IZUCKMAX MaxNft;
        IZUCKMAX SolNft;
        uint256 totalFee;
        mapping(uint256 => uint256) uintCrazyQua;
        mapping(uint256 => uint256) uintMadQua;
        mapping(uint256 => uint256) uintKingQua;
        mapping(uint256 => uint256) uintMarsQua;
        mapping(uint256 => uint256) uintSolQua;
    }
    Meta public meta;
    uint256[5] public prop;

    mapping(uint256 => uint256) public roundInfoList;
    
    uint256 public roundCount = 0;

    struct TokenInfo {
        uint tokenId;
        mapping(uint => bool) isClaimed;
        mapping(uint => address) lastClaimAddr;
    }
    mapping(uint => TokenInfo) public tokenInfo;
    uint256[5] private typeMaxSupply = [7000, 1900, 900, 100, 100];

    bool public isOpen;
    modifier openStage {
        require(isOpen, "not open yet");
        _;
    }

    constructor(){
        prop = [65,19,11,2,3];
        meta.MaxNft = IZUCKMAX(0x6Fe07eE22C0AC68295d40efCE0A1De05ACB419bf);
        meta.SolNft = IZUCKMAX(0x603Af6437479f2f3cDA6383dA30af46B2c4661b2);
    }


    function setMaxNft (address maxNft_) external onlyOwner  {
        meta.MaxNft = IZUCKMAX(maxNft_);
    }
    function setSolNft (address solNft_) external onlyOwner  {
        meta.SolNft = IZUCKMAX(solNft_);
    }
    function setPorp (uint256[5] memory porp_) external onlyOwner  {
        prop = porp_;
    }
    function setTotalFee (uint256 totalFee_) external onlyOwner {
        roundCount += 1;
        meta.totalFee = totalFee_;
        meta.uintCrazyQua[roundCount] = totalFee_ / 100 * prop[0] / typeMaxSupply[0];
        meta.uintMadQua[roundCount] = totalFee_ / 100 * prop[1] / typeMaxSupply[1];
        meta.uintKingQua[roundCount] = totalFee_ / 100 * prop[2] / typeMaxSupply[2];
        meta.uintMarsQua[roundCount] = totalFee_ / 100 * prop[3] / typeMaxSupply[3];
        meta.uintSolQua[roundCount] = totalFee_ / 100 * prop[4] / typeMaxSupply[4];
        roundInfoList[roundCount] = totalFee_;
    }
    function getUintFee (uint256 round, uint256 type_) public view returns (uint256) {
        uint256 uintFee = 999;
        if(type_ == 1){
            uintFee = meta.uintCrazyQua[round];
        }else if(type_ == 2){
            uintFee = meta.uintMadQua[round];
        }else if(type_ == 3){
            uintFee = meta.uintKingQua[round];
        }else if(type_ == 4){
            uintFee = meta.uintMarsQua[round];
        }else if(type_ == 5){
            uintFee = meta.uintSolQua[round];
        }
        return uintFee;
    }

    function rewardByOwner (address tokenOwner_) public view returns (uint256) {
        uint256[] memory ownerMaxTokens = meta.MaxNft.tokensOfOwner(tokenOwner_);
        uint256 rewardToken = 0;
        for(uint i=0; i<ownerMaxTokens.length; i++){
            rewardToken += calcUnClaimByToken(ownerMaxTokens[i]);
        }

        uint256[] memory ownerSolTokens = meta.SolNft.tokensOfOwner(tokenOwner_);
        for(uint i=0; i<ownerSolTokens.length; i++){
            rewardToken += calcSolUnClaimByToken(ownerSolTokens[i]);
        }
        return rewardToken;
    }
    
    function calcSolUnClaimByToken (uint256 tokenId_) public view returns (uint256) {
        uint256 unRewardToken = 0;
        for(uint i=1; i<=roundCount; i++){
            TokenInfo storage info = tokenInfo[tokenId_];
            if(!info.isClaimed[i]){
                unRewardToken += meta.uintSolQua[roundCount];
            }
        }
        return unRewardToken;
    }

    function calcUnClaimByToken (uint256 tokenId_) public view returns (uint256) {
        uint256 unRewardToken = 0;
        for(uint i=1; i<=roundCount; i++){
            TokenInfo storage info = tokenInfo[tokenId_];
            if(!info.isClaimed[i]){
                uint typeId = meta.MaxNft.getTypeIdByTokenId(tokenId_);
                if(typeId == 0){
                    unRewardToken += meta.uintCrazyQua[roundCount];
                }else if(typeId == 1){
                    unRewardToken += meta.uintMadQua[roundCount];
                }else if(typeId == 2){
                    unRewardToken += meta.uintKingQua[roundCount];
                }else if(typeId == 3){
                    unRewardToken += meta.uintMarsQua[roundCount];
                }
            }
        }
        return unRewardToken;
    }

    receive() external payable {}

    function claimReward () public openStage {
        require(msg.sender == tx.origin, "contract not allowed");
        uint tokenCount = meta.MaxNft.balanceOf(msg.sender);
        uint solCount = meta.SolNft.balanceOf(msg.sender);
        require(tokenCount != 0 && solCount != 0, "no nfts");
        uint lastBnb = address(this).balance;
        require(lastBnb != 0, "bnb insufficient");
        uint ownerRewardQuota = rewardByOwner(msg.sender);
        require(ownerRewardQuota != 0, "unavailable number");
        payable(msg.sender).transfer(ownerRewardQuota);
        uint256[] memory ownerTokens = meta.MaxNft.tokensOfOwner(msg.sender);
        for(uint i=0; i<ownerTokens.length; i++){
            TokenInfo storage info = tokenInfo[ownerTokens[i]];
            info.tokenId = ownerTokens[i];
            for(uint j=1; j<=roundCount; j++){
                info.isClaimed[j] = true;
                info.lastClaimAddr[j] = msg.sender;
            }
        }
        uint256[] memory ownerSolTokens = meta.SolNft.tokensOfOwner(msg.sender);
        for(uint i=0; i<ownerSolTokens.length; i++){
            TokenInfo storage info = tokenInfo[ownerSolTokens[i]];
            info.tokenId = ownerSolTokens[i];
            for(uint j=1; j<=roundCount; j++){
                info.isClaimed[j] = true;
                info.lastClaimAddr[j] = msg.sender;
            }
        }
    }

    function startOpen() external onlyOwner {
        require(!isOpen);
        isOpen = true;
    }
    
    function stopOpen() external onlyOwner openStage {
        isOpen = false;
    }

    function divest(address token_, address payee_, uint value_) external onlyOwner {
      if (token_ == address(0)) {
          payable(payee_).transfer(value_);
      } else {
          IERC20(token_).transfer(payee_, value_);
      }
    }
}