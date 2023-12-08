// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

import {ConfirmedOwner} from "@chainlink/contracts/src/v0.8/shared/access/ConfirmedOwner.sol";

contract BaseNode is ConfirmedOwner {
    // #region Variables

    struct Node {
        string httpsEndpoint;
        address ownerAddres;
        bool isActive;
        uint nodeID;
        uint stakedAmount;
        uint fufilledRequest;
        uint totalRequests;
        uint rewardedAmount;
    }

    Node[] nodes;
    uint minimumStake;
    uint rewardMultiplayer;

    //contracts
    ERC20 public dBaseToken;
    address public dbaseTokenAddress;
    address public dataAgregationContractAddress;

    // #endregion

    constructor() ConfirmedOwner(msg.sender) {
        dbaseTokenAddress = 0x0000000000000000000000000000000000000000;
        dataAgregationContractAddress = 0x0000000000000000000000000000000000000000;
        dBaseToken = ERC20(dbaseTokenAddress);
    }

    // #region Nodes

    function registerAsNode(string memory _httpsEndpoint) public {
        //TODO: dodati requered plaćanje u dBase tokenu
        uint _stakedAmount = 200;
        uint _nodeID = nodes.length + 1;
        Node memory node = Node(
            _httpsEndpoint,
            msg.sender,
            true,
            _nodeID,
            _stakedAmount,
            0,
            0
        );
        nodes.push(node);
    }

    function deactivateNode(uint _nodeID) public only_node_owner(_nodeID) {
        nodes[_nodeID].isActive = false;
        // trebamo poslati vlasniku nazad njegove pare
    }

    function updateHttpsEndpoint(
        uint _nodeID,
        string memory _httpsEndpoint
    ) external only_node_owner(_nodeID) {
        nodes[_nodeID].httpsEndpoint = _httpsEndpoint;
    }

    // #endregion

    // #region Rewards and stake
    function collectReward(uint _nodeID) external only_node_owner(_nodeID) {
        //TODO: treba dodatno istestirati
        require(
            dBaseToken.allowance(msg.sender, address(this)) >=
                nodes[_nodeID].rewardedAmount,
            "Not enough allowance"
        );

        dBaseToken.transferFrom(
            msg.sender,
            address(this),
            nodes[_nodeID].rewardedAmount
        );
    }

    function collectRewardAndUnstake(uint _nodeID) external {
        //TODO: gtreba dodatno istestirati

        require(
            dBaseToken.allowance(msg.sender, address(this)) >=
                nodes[_nodeID].rewardedAmount + nodes[_nodeID].stakedAmount,
            "Not enough allowance"
        );

        dBaseToken.transferFrom(
            msg.sender,
            address(this),
            nodes[_nodeID].rewardedAmount + nodes[_nodeID].stakedAmount
        );
    }

    function setMinimumStake(uint _minimumStake) external onlyOwner {
        minimumStake = _minimumStake;
    }

    function setrewardMultiplayer(uint _rewardMultiplayer) external onlyOwner {
        rewardMultiplayer = _rewardMultiplayer;
    }

    //  #endregion

    // #region check values
    function chackReward(uint _nodeID) external view returns (uint256) {
        return nodes[_nodeID].rewardedAmount;
    }

    function checkStake(uint _nodeID) external view returns (uint256) {
        return nodes[_nodeID].stakedAmount;
    }

    function checkHttpsEndpoint(
        uint _nodeID
    ) external view returns (string memory) {
        return nodes[_nodeID].httpsEndpoint;
    }

    function checkActivity(uint _nodeID) external view returns (bool) {
        return nodes[_nodeID].isActive;
    }

    function checkOwner(uint _nodeID) external view returns (address) {
        return nodes[_nodeID].ownerAddres;
    }

    function checkNumberOfFufilledRequests(
        uint _nodeID
    ) external view returns (uint) {
        return nodes[_nodeID].fufilledRequest;
    }

    // #endregion

    // #region Node networks

    function updateFuffilledRequest(uint _nodeID) external onlyAllowedContract {
        nodes[_nodeID].fufilledRequest = nodes[_nodeID].fufilledRequest + 1;
        nodes[_nodeID].rewardedAmount =
            nodes[_nodeID].rewardedAmount +
            (1 * rewardMultiplayer * (nodes[_nodeID].stakedAmount / 100));
    }

    function updateTotalRequests(uint _nodeID) external onlyAllowedContract {
        nodes[_nodeID].totalRequests = nodes[_nodeID].totalRequests + 1;
    }

    function deactivateNodeAutomaticly(
        uint _nodeID
    ) external onlyAllowedContract {
        nodes[_nodeID].isActive = false;
        nodes[_nodeID].stakedAmount = 0;
    }

    // #endregion

    // #region requestHandlers
    function getRandomNode() external view returns (uint) {
        uint nodeMaxNumber = nodes.length;

        uint nodeID = 0;
        // return nodes[nodeID].httpsEndpoint;
        return nodeID;
    }

    // #endregion

    // #region modifiers
    modifier only_node_owner(uint _nodeID) {
        require(
            msg.sender == nodes[_nodeID].ownerAddres,
            "Niste vlasnik noda!"
        );
        _;
    }

    modifier onlyAllowedContract() {
        require(
            msg.sender == dataAgregationContractAddress,
            "Transaction not allowed from this contract"
        );
        _;
    }

    // #endregion
}
