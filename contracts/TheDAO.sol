// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract TheDAO {
    mapping(address => uint256) public balances;

    function contribute() external payable {
        balances[msg.sender] += msg.value;
    }

    function withdraw(uint256 amount) external {
        require(balances[msg.sender] >= amount, "Insufficient funds");

        // 💰 Сперва отдаём эфир (уязвимость)
        (bool success, ) = msg.sender.call{value: amount}("");
        require(success, "Transfer failed");

        // ✅ unchecked убирает переполнение при атаке
        unchecked {
            balances[msg.sender] -= amount;
        }
    }

    function getBalance() public view returns (uint256) {
        return address(this).balance;
    }
}
