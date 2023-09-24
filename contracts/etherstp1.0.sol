// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract EtherSecureTransferProtocol {
    address private owner;

    struct Escrow {
        uint amount;
        address payer;
        address payee;
    }
    Escrow[] public allEscrows;

    event EtherEscrowed(
        address indexed sender,
        address indexed receiver,
        uint256 amount
    );
    event EtherWithdrawn(address indexed receiver, uint256 amount);
    event EtherRefunded(address indexed sender, uint256 amount);

    modifier onlyOwner() {
        require(msg.sender == owner, "You are not the owner");
        _;
    }

    constructor() {
        owner = msg.sender;
        allEscrows.push(Escrow(0, owner, owner));
    }

    function searchEscrowsIDByPayer(
        address payer
    ) external view returns (uint) {
        for (uint i; i < allEscrows.length; i++) {
            if (allEscrows[i].payer == payer && allEscrows[i].amount > 0) {
                return i;
            }
        }
        return 0;
    }

    function searchEscrowsIDByPayee(
        address payee
    ) external view returns (uint) {
        for (uint i; i < allEscrows.length; i++) {
            if (allEscrows[i].payee == payee && allEscrows[i].amount > 0) {
                return i;
            }
        }
        return 0;
    }

    function deposit(address payee) external payable {
        address payer = msg.sender;
        require(payee != address(0), "Invalid receiver address");

        allEscrows.push(Escrow(msg.value, payer, payee));
        emit EtherEscrowed(msg.sender, payee, msg.value);
    }

    function withdraw(uint id) external payable {
        require(
            allEscrows[id].payee == msg.sender,
            "You are not the payee of this payment"
        );
        require(allEscrows[id].amount > 0, "No ether to withdraw");
        payable(msg.sender).transfer(allEscrows[id].amount);

        emit EtherWithdrawn(msg.sender, allEscrows[id].amount);
        allEscrows[id].amount = 0;
    }

    function refund(uint id) external payable {
        require(
            allEscrows[id].payer == msg.sender,
            "You don't owner this payment"
        );
        require(allEscrows[id].amount > 0, "No ether to refund");
        payable(msg.sender).transfer(allEscrows[id].amount);

        emit EtherRefunded(msg.sender, allEscrows[id].amount);
        allEscrows[id].amount = 0;
    }

    function setOwner(address newOwner) external onlyOwner {
        require(newOwner != address(0), "Invalid owner address");
        owner = newOwner;
    }
}
