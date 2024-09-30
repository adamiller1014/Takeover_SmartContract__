// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/token/ERC20/extensions/ERC20Burnable.sol";
import "@openzeppelin/contracts/access/AccessControl.sol";

contract BurnToken is ERC20, ERC20Burnable, AccessControl {
    bytes32 public constant MINTER_ROLE = keccak256("MINTER_ROLE");
    event Bridge(address indexed src, uint256 amount, uint256 chainId);

    constructor() ERC20("Burn Token", "BURNT") {
        _grantRole(DEFAULT_ADMIN_ROLE, msg.sender);
        _grantRole(MINTER_ROLE, msg.sender);
    }

    function mint(address to, uint256 amount) public onlyRole(MINTER_ROLE) returns (bool) {
        _mint(to, amount);
        return true;
    }

    function bridge(uint256 amount, uint256 chainId) public returns (bool) {
        _burn(_msgSender(), amount);
        emit Bridge(_msgSender(), amount, chainId);
        return true;
    }
}