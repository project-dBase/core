// SPDX-License-Identifier: MIT
pragma solidity 0.8.19;

import {FunctionsClient} from "@chainlink/contracts/src/v0.8/functions/dev/v1_0_0/FunctionsClient.sol";
import {ConfirmedOwner} from "@chainlink/contracts/src/v0.8/shared/access/ConfirmedOwner.sol";
import {FunctionsRequest} from "@chainlink/contracts/src/v0.8/functions/dev/v1_0_0/libraries/FunctionsRequest.sol";

import "../template_data_recipien";
import "../base_operators/IBaseOperators.sol";

contract ReadData is ConfirmedOwner, FunctionsClient {
    using FunctionsRequest for FunctionsRequest.Request;

    address router = 0xb83E47C2bC239B3bf370bc41e1459A34b41238D0;
    bytes32 donID =
        0x66756e2d657468657265756d2d7365706f6c69612d3100000000000000000000;
    uint32 gasLimit = 300000;

    string code;
    address tokenContractAddress;
    address BaseOperatorsAddress;

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

    function updateBaseOperatorsAddress(address newAddress) external onlyOwner {
        BaseOperatorsAddress = newAddress;
    }

    function getBaseOperatorsAddress() external view returns (address) {
        return BaseOperatorsAddress;
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
        uint nodeID;
    }
    mapping(bytes32 => request) requests;

    function sendRequest(
        uint64 subscriptionId,
        string memory fieldToSearch,
        string memory blockName,
        string memory baseURL,
        address contractAddress,
        uint nodeId
    ) external returns (bytes32 requestId) {
        FunctionsRequest.Request memory req;
        req.initializeRequestForInlineJavaScript(code);

        string[] memory args = new string[](2);
        args[0] = baseURL;
        args[1] = fieldToSearch;
        args[2] = blockName;
        if (args.length > 0) req.setArgs(args);

        bytes32 RequestId = _sendRequest(
            req.encodeCBOR(),
            subscriptionId,
            gasLimit,
            donID
        );
        requests[RequestId] = request(blockName, contractAddress, nodeId);
        return RequestId;
    }

    //! ...............................
    function getDataSafeToContract(
        string memory fieldToSearch,
        string memory blockName,
        address contractAddress
    ) {
        uint64 subscriptionId = 1698;
        IBaseNodes baseOperators = IBaseNodes(BaseOperatorsAddress);
        string nodeID = baseOperators.getRandomHttpEndpoint();
        string memory baseURL = baseOperators.checkHttpsEndpoint(nodeID);
        baseOperators.updateTotalRequests(nodeID);
        sendRequest(
            subscriptionId,
            fieldToSearch,
            blockName,
            baseURL,
            contractAddress,
            nodeID
        );
    }

    //!.....................................
    function fulfillRequest(
        bytes32 requestId,
        bytes memory response,
        bytes memory err
    ) internal override {
        emit newBlockReaded(requestId, response, err);
        if (err.length > 0) {
            address contractAddress = requests[requestId].contractAddress;
            uint nodeID = requests[requestId].nodeID;
            IBaseNodes baseOperators = IBaseNodes(BaseOperatorsAddress);
            baseOperators.updateFuffilledRequest(nodeID);

            IRecipien dataRecipientContract = IRecipien(contractAddress);
            dataRecipientContract.reciveData(string(response));
        }
    }
}
