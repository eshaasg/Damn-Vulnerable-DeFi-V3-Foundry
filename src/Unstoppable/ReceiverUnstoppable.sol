// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "lib/openzeppelin-contracts/contracts/interfaces/IERC3156FlashBorrower.sol";
import "lib/solmate/src/auth/Owned.sol";
import { UnstoppableVault, ERC20 } from "../Unstoppable/UnstoppableVault.sol";

/**
 * @title ReceiverUnstoppable
 * @author Damn Vulnerable DeFi (https://damnvulnerabledefi.xyz)
 */
contract ReceiverUnstoppable is Owned, IERC3156FlashBorrower {
    UnstoppableVault private immutable pool;

    error UnexpectedFlashLoan();

    constructor(address poolAddress) Owned(msg.sender) {
        pool = UnstoppableVault(poolAddress);
    }

    function onFlashLoan(
        address initiator,
        address token,
        uint256 amount,
        uint256 fee,
        bytes calldata
        
        // initiator Same contract
        // caller is address specified by the pool
        // fee for the flash loan is zero
    ) external returns (bytes32) {
        if (initiator != address(this) || msg.sender != address(pool) || token != address(pool.asset()) || fee != 0)
        // if conditions above arent met revert transaction
         revert UnexpectedFlashLoan();
    
        // if token approved 
        ERC20(token).approve(address(pool), amount);

        // function block executed and returns a string value
        return keccak256("IERC3156FlashBorrower.onFlashLoan");
    }
    // 
    function executeFlashLoan(uint256 amount) external onlyOwner {
        address asset = address(pool.asset());
        pool.flashLoan(
            this,
            asset,
            amount,
            bytes("")
        );
    }
}