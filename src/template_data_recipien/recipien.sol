// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;

contract Recipien {
    string public data;

    function requestData(string memory _data) public {}

    function reciveData(string memory _data) external {
        data = _data;
    }
}
