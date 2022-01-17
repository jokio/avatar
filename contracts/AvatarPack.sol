//SPDX-License-Identifier: Unlicense
pragma solidity ^0.8.0;

// import "hardhat/console.sol";
import "@openzeppelin/contracts/token/ERC1155/ERC1155.sol";
// import "@openzeppelin/contracts/token/ERC721/ERC721.sol";

/**
TODO:
✅ Create default handler to receive tokens and increase tips
* Support upload images functionality and track uploader users
*/


contract AvatarPack is ERC1155 {
    // mapping(uint32 => string) public uploadedImages;
    // mapping(address => uint256) public userTotalPayedForUploadImages;

    mapping(address => uint256) public userTips;

    uint256 public boxPrice;
    uint256 public packPrice;
    uint8 public boxCountInPack;
    uint256[] public itemHashes;

    event BoxOpened(address to, uint256[] itemIds);

    constructor(
        uint256 _boxPrice,
        uint256 _packPrice,
        uint8 _boxCountInPack,
        uint32[] memory _itemBalances,
        uint256[] memory _itemHashes,
        string memory _metadataUrl
    ) ERC1155(_metadataUrl) {
        require(_itemBalances.length > 0, "INVALID_ITEM_BALANCES");
        require(_itemBalances.length == _itemHashes.length, "INVALID_ITEM_HASHES_LENGTH");
        require(_boxPrice < _packPrice, "INVALID_PACK_PRICE");
        require(_boxCountInPack > 1, "TOO_SMALL_PACK_SIZE");
        require(_boxCountInPack < _itemBalances.length, "TOO_LARGE_PACK_SIZE");

        boxPrice = _boxPrice;
        packPrice = _packPrice;
        boxCountInPack = _boxCountInPack;
        itemHashes = _itemHashes;

        // mint all items
        for (uint32 i = 0; i < _itemBalances.length; i++) {
            _mint(address(this), i, _itemBalances[i], "");
        }
    }

    function buyGiftBox() public payable {
        require(msg.value >= boxPrice, "VALUE_LESS_THAN_PRICE");

        uint256 tip = msg.value - boxPrice;

        if (tip > 0) {
            userTips[msg.sender] += tip;
        }

        _buyBoxes(msg.sender, 1);
    }

    function buyGiftPack() public payable {
        require(msg.value >= packPrice, "VALUE_LESS_THAN_PRICE");

        uint256 tip = msg.value - packPrice;

        if (tip > 0) {
            userTips[_msgSender()] += tip;
        }

        _buyBoxes(msg.sender, boxCountInPack);
    }

    function balanceOfAll(address to) public view returns (uint256[] memory) {
        uint256[] memory result = new uint256[](itemHashes.length);

        for (uint32 i = 0; i < itemHashes.length; i++) {
            result[i] = balanceOf(to, i);
        }

        return result;
    }


    // helper functions
    function _buyBoxes(address to, uint8 count) internal {
        uint32 validItemCount = 0;
        uint256 totalAvailableSupply = 0;
        bool[] memory validItems = new bool[](itemHashes.length);

        for (uint32 i = 0; i < itemHashes.length; i++){
            uint256 availableSupply = balanceOf(address(this), i);

            if (availableSupply > 0) {
                validItemCount++;
                totalAvailableSupply += availableSupply;
                validItems[i] = true;
            }
        }


        // console.log("totalAvailableSupply", totalAvailableSupply);
        // console.log("count", count);

        require(totalAvailableSupply >= count, "NOT_ENOUGH_ITEMS_FOR_PACK");

        uint256 randomNumber = _randomNumber();

        uint256[] memory selectedItemIds = new uint256[](count);
        uint256[] memory selectedItemAmounts = new uint256[](count);

        // prepare selected items and amounts
        for (uint8 current = 0; current < count; current++) {
            // pick the random index
            uint256 randomIndex = randomNumber % validItemCount;

            for (uint32 i = 0; i < itemHashes.length; i++){
                if (validItems[i]) {
                    if (randomIndex == 0) {
                        selectedItemIds[current] = i;
                        selectedItemAmounts[current] = 1;
                        break;
                    }
                    
                    randomIndex--;
                }
            }

            // shift to prepare for the next iteration.
            randomNumber = randomNumber >>= 1;
        }

        // batch transfer
        _safeBatchTransferFrom(address(this), to, selectedItemIds, selectedItemAmounts, "");

        emit BoxOpened(to, selectedItemIds);
    }

    function _randomNumber() internal view returns (uint256) {
        return uint256(keccak256(abi.encodePacked(msg.sender, block.timestamp)));
    }


    // process all requests and increase tips
    fallback () external payable {
        userTips[msg.sender] += msg.value;
    }

    receive () external payable {
        userTips[msg.sender] += msg.value;
    }
}
