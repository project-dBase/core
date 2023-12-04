// SPDX-License-Identifier: MIT
pragma solidity 0.8.19;

import {FunctionsClient} from "@chainlink/contracts/src/v0.8/functions/dev/v1_0_0/FunctionsClient.sol";
import {ConfirmedOwner} from "@chainlink/contracts/src/v0.8/shared/access/ConfirmedOwner.sol";
import {FunctionsRequest} from "@chainlink/contracts/src/v0.8/functions/dev/v1_0_0/libraries/FunctionsRequest.sol";
import "./IDataAgregation.sol";
import "../data_storage/IDataStorage.sol";

contract DataAgregation is FunctionsClient, ConfirmedOwner, IDataAgregation {
    using FunctionsRequest for FunctionsRequest.Request;

    // #region Chainlink

    address router = 0xb83E47C2bC239B3bf370bc41e1459A34b41238D0;
    bytes32 donID =
        0x66756e2d657468657265756d2d7365706f6c69612d3100000000000000000000;

    // #endregion

    // gas
    uint32 gasLimit = 300000;

    // #region Functions Code
    struct FunctionCode {
        address ownerAddress;
        string name;
        string code;
        bool isPublic;
        uint2 requestType; // 0 - read, 1 - write
    }
    FunctionCode[] functionsCode;
    // #endregion

    // #region Errors

    error PermissionDenied();
    error FunctionDoesNotExist();

    // #endregion

    // #region Events
    event NewFunctionCreated(
        address ownerAddress,
        string name,
        string code,
        bool isPublic,
        uint2 requestType
    );

    event FunctionUpdated(address owner, bool isPublic, uint functionID);

    event functionRequestSended(
        bytes32 requestId,
        uint functionID,
        address persion
    );

    event NewBlocSended(string blocName, string blocSHA);

    event functionRequestExecuted(bytes32 requestId, bytes response, bytes err);

    // #endregion

    // #region Contracts
    address dataStorageContractAddress;
    address tokenContractAddress;

    // #endregion

    constructor() FunctionsClient(router) ConfirmedOwner(msg.sender) {}

    // #region basic functions
    function updateDataStorageAddress(address newAddress) external onlyOwner {
        dataStorageContractAddress = newAddress;
    }

    function updateTokenContractAddress(address newAddress) external onlyOwner {
        tokenContractAddress = newAddress;
    }

    function getGasLimit() external view returns (uint32) {
        return gasLimit;
    }

    function updateGasLimit(uint32 newGasLimit) external onlyOwner {
        gasLimit = newGasLimit;
    }

    // #endregion

    function sendDataToStorage(string memory name, string memory sha) internal {
        IDataStorageContract dataStorageContract = IDataStorageContract(
            dataStorageContractAddress
        );
        dataStorageContract.addNewBloc(name, sha);
        emit NewBlocSended(name, sha);
    }

    // #region ChainlinkFunctions

    function getFunctionsDetails(
        uint functionID
    ) external view returns (FunctionCode memory) {
        return functionsCode[functionID];
    }

    function addNewFunctionCode(
        string memory name,
        string memory code,
        bool isPublic,
        uint2 requestType
    ) external {
        functionsCode.push(
            FunctionCode(msg.sender, name, code, isPublic, requestType)
        );
        emit NewFunctionCreated(msg.sender, name, code, isPublic, requestType);
    }

    function updateFunctionVisibility(bool isPublic, uint functionID) external {
        if (functionsCode[functionID].ownerAddress != msg.sender) {
            revert PermissionDenied();
        }
        functionsCode[functionID].isPublic = isPublic;
        emit FunctionUpdated(msg.sender, isPublic, functionID);
    }

    // #endregion

    // #region Request/Response
    function sendRequest(
        uint64 subscriptionId,
        string[] calldata args,
        uint functionsCodeId
    ) external returns (bytes32 requestId) {
        if (functionsCode.length <= functionsCodeId) {
            revert FunctionDoesNotExist();
        }
        FunctionsRequest.Request memory req;
        req.initializeRequestForInlineJavaScript(
            functionsCode[functionsCodeId].code
        );
        if (args.length > 0) req.setArgs(args);

        if (
            !functionsCode[functionsCodeId].isPublic &&
            functionsCode[functionsCodeId].ownerAddress != msg.sender
        ) {
            revert PermissionDenied();
        }

        bytes32 RequestId = _sendRequest(
            req.encodeCBOR(),
            subscriptionId,
            gasLimit,
            donID
        );
        emit functionRequestSended(RequestId, functionsCodeId, msg.sender);
        return RequestId;
    }

    //-----------dodavanje novih blokova
    // treba mi requestTYpe
    // treba mi adresa čovijeka koji je pozvao funkciju
    // treba mi ime bloka
    // SHA vraćam kao return kada dodajem novi blok
    //------------Čitanje podataka iz bloka
    // treba mi request type
    // treba mi ime bloka
    // kao return vraća se podatak spremljen
    function fulfillRequest(
        bytes32 requestId,
        bytes memory response,
        bytes memory err
    ) internal override {
        //TODO: Treba ovdje vratriti bloc name i bloc sha
        sendDataToStorage(string(response), string(response));

        emit functionRequestExecuted(requestId, response, err);
    }
    // #endregion
}
