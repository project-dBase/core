// SPDX-License-Identifier: MIT
pragma solidity 0.8.19;

interface IDataStorage {
    function setDataContract(address _address) external;

    function getDataContractAddress() external view returns (address);

    function addNewBlock(
        string memory blocName,
        string memory blocSHA,
        address ownewer
    ) external;

    function getBlockInfo(
        string memory blocName
    ) external view returns (string memory, address, uint256);

    function verifyBlock(
        string memory blocName,
        string memory blocSHA
    ) external view returns (bool);
}
