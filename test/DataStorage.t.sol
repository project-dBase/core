// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

import "forge-std/Test.sol";
import "../src/data_storage/DataStorage.sol";

contract DataStorageTest is Test {
    DataStorage public dataStorage;

    function setUp() public {
        dataStorage = new DataStorage();
    }

    function testAddNewBlock() public {
        string memory blocName = "MyBlock";
        string memory blocSHA = "MyBlockSHA256";
        dataStorage.addNewBlock(blocName, blocSHA);
        (string memory returnedSHA, , ) = dataStorage.getBlockInfo(blocName);
        assertEq(
            returnedSHA,
            blocSHA,
            "The SHA of the block should match the added SHA"
        );
    }

    function testGetBlockInfo() public {
        string memory blocName = "MyBlock";
        string memory blocSHA = "MyBlockSHA256";
        dataStorage.addNewBlock(blocName, blocSHA);
        (
            string memory returnedSHA,
            address returnedCreator,
            uint256 returnedTimestamp
        ) = dataStorage.getBlockInfo(blocName);

        assertEq(
            returnedSHA,
            blocSHA,
            "The SHA of the block should match the added SHA"
        );
        assertEq(
            returnedCreator,
            address(this),
            "The creator of the block should be the address of the contract"
        );
        assertTrue(
            returnedTimestamp > 0,
            "The timestamp of the block should be greater than 0"
        );
    }

    function testVerifyBlock() public {
        string memory blocName = "MyBlock";
        string memory blocSHA = "MyBlockSHA256";
        dataStorage.addNewBlock(blocName, blocSHA);
        bool isValid = dataStorage.verifyBlock(blocName, blocSHA);
        assertTrue(isValid, "The block should be valid");
    }
}
