// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/access/AccessControl.sol";
import "@openzeppelin/contracts/token/ERC20/extensions/ERC20Burnable.sol";

contract TokenTakeOver is AccessControl {
     bytes32 public constant BURNER_ROLE = keccak256("BURNER_ROLE");

    // Mapping to keep track of remaining locked tokens for each ERC20 contract
    mapping(address => uint256) public remainingLockedTokens;

    // Events
    event TokensLocked(address indexed user, address indexed token, uint256 amount);
    event TokensBurned(address indexed burner, address indexed token, uint256 amount);

    // Constructor to set the admin role
    constructor() {
        _grantRole(
            DEFAULT_ADMIN_ROLE,
            msg.sender
        );
    }

    // Lock tokens of a specific ERC20 token contract
    function lockTokens(address token, uint256 amount) external {
        require(amount > 0, "Amount must be greater than zero");
        require(token != address(0), "Invalid token address");

        // Transfer tokens from the sender to the contract
        ERC20Burnable erc20Token = ERC20Burnable(token);
        require(erc20Token.transferFrom(msg.sender, address(this), amount), "Token transfer failed");

        // Update remaining locked tokens for the given token
        remainingLockedTokens[token] += amount;

        // Emit the event to log the lock action
        emit TokensLocked(msg.sender, token, amount);
    }

    // Burn the locked tokens from the contract - only accessible by BURNER_ROLE
    function burnLockedTokens(address token, uint256 amount) external onlyRole(BURNER_ROLE) {
        require(amount > 0, "Amount must be greater than zero");
        require(token != address(0), "Invalid token address");

        uint256 availableAmount = remainingLockedTokens[token];
        require(availableAmount >= amount, "Insufficient tokens to burn");

        // Reduce the remaining locked tokens
        remainingLockedTokens[token] -= amount;

        // Burn the tokens using the ERC20Burnable interface
        ERC20Burnable erc20Token = ERC20Burnable(token);
        erc20Token.burn(amount);

        // Emit the event to log the burn action
        emit TokensBurned(msg.sender, token, amount);
    }

    // Grant the BURNER_ROLE to an address
    function grantBurnerRole(address account) external onlyRole(DEFAULT_ADMIN_ROLE) {
        grantRole(BURNER_ROLE, account);
    }

    // Revoke the BURNER_ROLE from an address
    function revokeBurnerRole(address account) external onlyRole(DEFAULT_ADMIN_ROLE) {
        revokeRole(BURNER_ROLE, account);
    }
}
