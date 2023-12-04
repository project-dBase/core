// SPDX-License-Identifier: MIT
pragma solidity 0.8.19;

interface IAddNewData {
    function updateDataStorageAddress(address newAddress) external;

    function getDataStorageAddress() external view returns (address);

    function updateTokenContractAddress(address newAddress) external;

    function getTokenContractAddress() external view returns (address);

    function getGasLimit() external view returns (uint32);

    function updateGasLimit(uint32 newGasLimit) external;

    function getDonID() external view returns (bytes32);

    function getRouter() external view returns (address);

    function getCode() external view returns (string memory);

    function sendRequest(
        uint64 subscriptionId,
        string memory blockName
    ) external returns (bytes32 requestId);
}
