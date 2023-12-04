// SPDX-License-Identifier: MIT
pragma solidity 0.8.19;

import "./IDataStorage.sol";

contract DataStorage {
    // Mappings to store block SHA, creator address and timestamp
    mapping(string => string) public getBlocSHA;
    mapping(string => address) public getBlocCreatorAddres;
    mapping(string => uint256) public getTimestamp;

    // Event to log the addition of a new block
    event BlocAdded(string name, string sha, address creator, uint timestamp);

    // Custom error to handle the case when a block already exists
    error BlocAlreadyExists(string name, string sha);
    error BlocDoesNotExist(string name);

    address addDataContractAddress;

    function setDataContract(address _address) external {
        addDataContractAddress = _address;
    }

    function getDataContractAddress() external view returns (address) {
        return addDataContractAddress;
    }

    /**
     * @notice Adds a new SHA to storage
     * @notice This is used to verify the accuracy of the block
     * @param blocName The name of the block
     * @param blocSHA The SHA of the block
     */
    function addNewBlock(
        string memory blocName,
        string memory blocSHA,
        address ownewer
    ) external only_contract {
        if (bytes(getBlocSHA[blocName]).length != 0) {
            revert BlocAlreadyExists(blocName, blocSHA);
        }
        getBlocSHA[blocName] = blocSHA;
        getBlocCreatorAddres[blocName] = ownewer;
        getTimestamp[blocName] = block.timestamp;

        emit BlocAdded(blocName, blocSHA, msg.sender, block.timestamp);
    }

    /**
     * @notice Gets the information of a block
     * @param blocName The name of the block
     * @return The SHA of the block, the creator address, and the timestamp
     */
    function getBlockInfo(
        string memory blocName
    ) external view returns (string memory, address, uint256) {
        return (
            getBlocSHA[blocName],
            getBlocCreatorAddres[blocName],
            getTimestamp[blocName]
        );
    }

    /**
     * @notice This function will return is the block modified or not
     * @param blocName The name of the block
     * @param blocSHA The SHA of the block
     */
    function verifyBlock(
        string memory blocName,
        string memory blocSHA
    ) external view returns (bool) {
        if (bytes(getBlocSHA[blocName]).length == 0) {
            revert BlocDoesNotExist(blocName);
        }
        return
            keccak256(abi.encodePacked(getBlocSHA[blocName])) ==
            keccak256(abi.encodePacked(blocSHA));
    }

    modifier only_contract() {
        require(msg.sender == addDataContractAddress, "Auth error");
        _;
    }
}
