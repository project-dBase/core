// SPDX-License-Identifier: MIT
pragma solidity 0.8.19;

import {ConfirmedOwner} from "@chainlink/contracts/src/v0.8/shared/access/ConfirmedOwner.sol";

contract dBaseDataStorage {
    mapping(string => string) private getBlocSHA;
    mapping(string => address) private getBlocCreatorAddres;
    mapping(string => uint256) private getTimestamp;

    // #region Events
    event BlocAdded(string name, string sha, address creator, uint timestamp);

    // #endregion

    // #region Errors
    error BlocAlreadyExists(string name, string sha);

    // #endregion

    constructor() {
        ConfirmedOwner(msg.sender);
    }

    function addNewBloc(
        string memory blocName,
        string memory blocSHA
    ) external {
        if (bytes(getBlocSHA[blocName]).length != 0) {
            revert BlocAlreadyExists(blocName, blocSHA);
        }
        getBlocSHA[blocName] = blocSHA;
        getBlocCreatorAddres[blocName] = msg.sender;
        getTimestamp[blocName] = block.timestamp;

        emit BlocAdded(blocName, blocSHA, msg.sender, block.timestamp);
    }

    function getBlocInfo(
        string memory blocName
    ) external view returns (string memory, address, uint256) {
        return (
            getBlocSHA[blocName],
            getBlocCreatorAddres[blocName],
            getTimestamp[blocName]
        );
    }
}
