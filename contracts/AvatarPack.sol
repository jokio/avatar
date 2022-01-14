//SPDX-License-Identifier: Unlicense
pragma solidity ^0.8.0;

import "hardhat/console.sol";
import "@openzeppelin/contracts/token/ERC1155/ERC1155.sol";
import "@openzeppelin/contracts/token/ERC721/ERC721.sol";

contract AvatarPack is ERC1155 {
    uint32[] public tokenBalances;

    // mapping(uint32 => string) public uploadedImages;
    // mapping(address => uint256) public userTotalPayedForUploadImages;
    mapping(address => uint256) public userTips;

    uint256 public boxPrice;
    uint256 public packPrice;
    uint8 public boxCountInPack;

    constructor(
        uint256 _boxPrice,
        uint256 _packPrice,
        uint8 _boxCountInPack,
        uint32[] memory _tokenBalances,
        string memory _metadataUrl
    ) ERC1155(_metadataUrl) {
        tokenBalances = _tokenBalances;
        boxPrice = _boxPrice;
        packPrice = _packPrice;
        boxCountInPack = _boxCountInPack;

        // mint all tokens
        for (uint32 i = 0; i < _tokenBalances.length; i++) {
            _mint(address(this), i, _tokenBalances[i], "");
        }
    }

    function buyGiftBox(address buyer) public payable {
        require(msg.value < boxPrice, "value should be more than `boxPrice`");

        uint256 tip = boxPrice - msg.value;

        if (tip > 0) {
            userTips[_msgSender()] += tip;
        }

        _buyBoxes(buyer, 1);
    }

    function buyGiftPack(address buyer) public payable {
        require(msg.value < packPrice, "value should be more than `packPrice`");

        uint256 tip = packPrice - msg.value;

        if (tip > 0) {
            userTips[_msgSender()] += tip;
        }

        _buyBoxes(buyer, boxCountInPack);
    }

    function _buyBoxes(address to, uint8 count) internal {
        uint32 validTokenCount = 0;

        for (uint32 i = 0; i < tokenBalances.length; i++){
            if (tokenBalances[i] > 0) {
                validTokenCount++;
            }
        }

        uint256 randomNumber = _randomNumber();

        for (uint8 current = 0; current < count; current++) {
            // Pick the random index
            uint256 randomIndex = randomNumber % validTokenCount;

            for (uint32 i = 0; i < tokenBalances.length; i++){
                if (tokenBalances[i] > 0) {
                    if (randomIndex == 0) {
                        _safeTransferFrom(address(this), to, i, 1, "");
                        break;
                    }
                    
                    randomIndex--;
                }
            }

            // Shift to prepare for the next iteration.
            randomNumber = randomNumber >>= 1;
        }
    }

    function _randomNumber() internal view returns (uint256) {
        return uint256(keccak256(abi.encodePacked(msg.sender, block.timestamp)));
    }
}
