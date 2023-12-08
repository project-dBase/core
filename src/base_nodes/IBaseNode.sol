// SPDX-License-Identifier: MIT

interface IBaseNodes {
    //---------[Nodes]-----------//

    function registerAsNode(string memory _httpsEndpoint) external;

    function deactivateNode(uint _nodeID) external;

    function updateHttpsEndpoint(
        uint _nodeID,
        string memory _httpsEndpoint
    ) external;

    //---------[Revards and stake]-----------//
    function collectReward(uint _nodeID) external view;

    function collectRewardAndUnstake(uint _nodeID) external view;

    function setMinimumStake(uint _minimumStake) external view;

    function setrewardMultiplayer(uint _rewardMultiplayer) external view;

    //---------[Check Values]-----------//

    function chackReward(uint _nodeID) external returns (uint256);

    function checkStake(uint _nodeID) external returns (uint256);

    function checkHttpsEndpoint(uint _nodeID) external returns (string memory);

    function checkActivity(uint _nodeID) external returns (bool);

    function checkOwner(uint _nodeID) external returns (address);

    function checkNumberOfFufilledRequests(
        uint _nodeID
    ) external returns (uint);

    //---------[Node network]-----------//

    function updateFuffilledRequest(uint _nodeID) external;

    function updateTotalRequests(uint _nodeID) external;

    function deactivateNodeAutomaticly(uint _nodeID) external;

    //---------[Node selector]-----------//

     function getRandomNode() external view returns (uint) 
}
