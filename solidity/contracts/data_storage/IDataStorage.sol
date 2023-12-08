// SPDX-License-Identifier: MIT

interface IDataStorage {
    function addNewBloc(string memory blocName, string memory blocSHA) external;

    function getBlocInfo(
        string memory blocName
    ) external view returns (string memory, address, uint256);
}
