// SPDX-License-Identifier: MIT

interface IDataStorageContract {
    struct FunctionCode {
        address ownerAddress;
        string name;
        string code;
        bool isPublic;
    }

    function addNewBloc(string memory blocName, string memory blocSHA) external;

    function updateDataStorageAddress(address newAddress) external;

    function updateTokenContractAddress(address newAddress) external;

    function getGasLimit() external view returns (uint32);

    function updateGasLimit(uint32 newGasLimit) external;

    function getFunctionsDetails(
        uint functionID
    ) external view returns (FunctionCode memory);

    function addNewFunctionCode(
        string memory name,
        string memory code,
        bool isPublic
    ) external;

    function updateFunctionVisibility(bool isPublic, uint functionID) external;

    function sendRequest(
        uint64 subscriptionId,
        string[] calldata args,
        uint functionsCodeId
    ) external returns (bytes32 requestId);
}
