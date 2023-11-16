// SPDX-License-Identifier: MIT
pragma solidity 0.8.19;

contract dBaseDataProtector {
    mapping(string => string) private getBlocSHA;
    mapping(string => address) private getBlocCreatorAddres;

    address immutable i_owner;

    constructor() {
        i_owner = msg.sender;
    }

    // modifier only_owner() {
    //     require(msg.sender == i_owner, "You are not contract owner");
    //     _;
    // }

    function uploadNewBloc(
        string memory blocName,
        string memory blocSHA
    ) public {
        require(
            bytes(getBlocSHA[blocName]).length == 0,
            "Block with this name already exists"
        );
        getBlocSHA[blocName] = blocSHA;
        getBlocCreatorAddres[blocName] = msg.sender;
    }

    function getBlocInfo(
        string memory blocName
    ) external view returns (string memory, address) {
        return (getBlocSHA[blocName], getBlocCreatorAddres[blocName]);
    }
}
