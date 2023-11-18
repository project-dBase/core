// SPDX-License-Identifier: MIT
pragma solidity 0.8.19;

import {FunctionsClient} from "@chainlink/contracts/src/v0.8/functions/dev/v1_0_0/FunctionsClient.sol";
import {ConfirmedOwner} from "@chainlink/contracts/src/v0.8/shared/access/ConfirmedOwner.sol";
import {FunctionsRequest} from "@chainlink/contracts/src/v0.8/functions/dev/v1_0_0/libraries/FunctionsRequest.sol";

contract DataAgregation is FunctionsClient, ConfirmedOwner {
    using FunctionsRequest for FunctionsRequest.Request;

    //Cahinlink
    address router = 0xb83E47C2bC239B3bf370bc41e1459A34b41238D0;
    bytes32 donID =
        0x66756e2d657468657265756d2d7365706f6c69612d3100000000000000000000;

    // gas
    uint32 gasLimit = 300000;

    // functions code
    struct FunctionCode {
        address ownerAddres;
        string name;
        string code;
        bool isPublic;
    }
    FunctionCode[] functionsCode;

    //***********Trashy code************* */
    // Custom error type
    error UnexpectedRequestID(bytes32 requestId);

    // Event to log responses
    event Response(
        bytes32 indexed requestId,
        string character,
        bytes response,
        bytes err
    );

    // State variables to store the last request ID, response, and error
    bytes32 public s_lastRequestId;
    bytes public s_lastResponse;
    bytes public s_lastError;

    string character;

    function getCharacter() external view returns (string memory) {
        return character;
    }

    //*********************************** */

    constructor() FunctionsClient(router) ConfirmedOwner(msg.sender) {}

    function updateGAsLimit(uint32 newGasLimit) external onlyOwner {
        gasLimit = newGasLimit;
    }

    function getFunctionsDetails(
        uint functionID
    ) external view returns (FunctionCode memory) {
        return functionsCode[functionID];
    }

    function addNewFunctionCode(
        string memory name,
        string memory code,
        bool isPublic
    ) external {
        functionsCode.push(FunctionCode(msg.sender, name, code, isPublic));
    }

    function updateFunctionVisibility(bool isPublic, uint functionID) external {
        require(
            functionsCode[functionID].ownerAddres == msg.sender,
            "Niste vlanika ove funkcije"
        );
        functionsCode[functionID].isPublic = isPublic;
    }

    string source =
        "const characterId = args[0];"
        "const apiResponse = await Functions.makeHttpRequest({"
        "url: `https://swapi.dev/api/people/${characterId}/`"
        "});"
        "if (apiResponse.error) {"
        "throw Error('Request failed');"
        "}"
        "const { data } = apiResponse;"
        "return Functions.encodeString(data.name);";

    function sendRequest(
        uint64 subscriptionId,
        string[] calldata args
    ) external returns (bytes32 requestId) {
        FunctionsRequest.Request memory req;
        req.initializeRequestForInlineJavaScript(source);
        if (args.length > 0) req.setArgs(args);

        // require(
        //     functionsCode[functionCodeId].isPublic,
        //     "Ova funckija nije javno dostupna"
        // );
        // require(
        //     functionsCode[functionCodeId].ownerAddres == msg.sender,
        //     "Niste vlasnik privatne fun"
        // );

        s_lastRequestId = _sendRequest(
            req.encodeCBOR(),
            subscriptionId,
            gasLimit,
            donID
        );
        return s_lastRequestId;
    }

    function fulfillRequest(
        bytes32 requestId,
        bytes memory response,
        bytes memory err
    ) internal override {
        if (s_lastRequestId != requestId) {
            revert UnexpectedRequestID(requestId); // Check if request IDs match
        }
        // Update the contract's state variables with the response and any errors
        s_lastResponse = response;
        character = string(response);
        s_lastError = err;

        // Emit an event to log the response
        emit Response(requestId, character, s_lastResponse, s_lastError);
    }
}
