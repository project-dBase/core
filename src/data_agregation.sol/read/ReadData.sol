// SPDX-License-Identifier: MIT
pragma solidity 0.8.19;

import {FunctionsClient} from "@chainlink/contracts/src/v0.8/functions/dev/v1_0_0/FunctionsClient.sol";
import {ConfirmedOwner} from "@chainlink/contracts/src/v0.8/shared/access/ConfirmedOwner.sol";
import {FunctionsRequest} from "@chainlink/contracts/src/v0.8/functions/dev/v1_0_0/libraries/FunctionsRequest.sol";

import "../template_data_recipien";

contract ReadData is ConfirmedOwner, FunctionsClient {
    using FunctionsRequest for FunctionsRequest.Request;

    address router = 0xb83E47C2bC239B3bf370bc41e1459A34b41238D0;
    bytes32 donID =
        0x66756e2d657468657265756d2d7365706f6c69612d3100000000000000000000;
    uint32 gasLimit = 300000;

    string code;
    address tokenContractAddress;

    event newBlockReaded(bytes32 requestId, bytes response, bytes err);

    constructor(
        string memory _code
    ) FunctionsClient(router) ConfirmedOwner(msg.sender) {
        code = _code;
    }

    function updateDataStorageAddress(address newAddress) external onlyOwner {
        dataStorageContractAddress = newAddress;
    }

    function getDataStorageAddress() external view returns (address) {
        return dataStorageContractAddress;
    }

    function updateTokenContractAddress(address newAddress) external onlyOwner {
        tokenContractAddress = newAddress;
    }

    function getTokenContractAddress() external view returns (address) {
        return tokenContractAddress;
    }

    function getGasLimit() external view returns (uint32) {
        return gasLimit;
    }

    function updateGasLimit(uint32 newGasLimit) external onlyOwner {
        gasLimit = newGasLimit;
    }

    function getDonID() external view returns (bytes32) {
        return donID;
    }

    function getRouter() external view returns (address) {
        return router;
    }

    function getCode() external view returns (string memory) {
        return code;
    }

    struct request {
        string blockName;
        address contractAddress;
    }
    mapping(bytes32 => request) requests;

    function sendRequest(
        uint64 subscriptionId,
        string memory blockName,
        string memory baseURL,
        address contractAddress
    ) external returns (bytes32 requestId) {
        FunctionsRequest.Request memory req;
        req.initializeRequestForInlineJavaScript(code);

        string[] memory args = new string[](2);
        args[0] = baseURL;
        args[1] = blockName;
        if (args.length > 0) req.setArgs(args);

        bytes32 RequestId = _sendRequest(
            req.encodeCBOR(),
            subscriptionId,
            gasLimit,
            donID
        );
        requests[RequestId] = request(blockName, contractAddress);
        return RequestId;
    }

    function fulfillRequest(
        bytes32 requestId,
        bytes memory response,
        bytes memory err
    ) internal override {
        emit newBlockReaded(requestId, response, err);
        address contractAddress = requests[requestId].contractAddress;
        IRecipien dataRecipientContract = IRecipien(contractAddress);
        dataRecipientContract.reciveData(string(response));
    }
}
