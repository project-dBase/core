// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "@openzeppelin/contracts@5.0.0/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts@5.0.0/access/Ownable.sol";
import "@openzeppelin/contracts@5.0.0/token/ERC20/extensions/ERC20Permit.sol";

contract DBase is ERC20, Ownable, ERC20Permit {
    constructor()
        ERC20("dBase", "dBase")
        Ownable(msg.sender)
        ERC20Permit("dBase")
    {}

    function mint(uint256 amount) public onlyOwner {
        _mint(msg.sender, amount * 10 ** 18);
    }
}
