// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract EtherEscrow {
    address public owner; // @dev set to private in production

    struct Escrow {
        uint amount;
        address payer;
        address payee;
        string password;
        bool payerRefundable;
        bool fixedPayee;
    }
    Escrow[] public allEscrows; // @dev set to private in production

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
    }

    function searchEscrowsIDByPayer() external view returns (uint) {
        for (uint i; i < allEscrows.length; i++) {
            if (allEscrows[i].payer == msg.sender && allEscrows[i].amount > 0) {
                return i;
            }
        }
        return 0;
    }

    function searchEscrowsIDByPayee() external view returns (uint) {
        for (uint i; i < allEscrows.length; i++) {
            if (allEscrows[i].payee == msg.sender && allEscrows[i].amount > 0) {
                return i;
            }
        }
        return 0;
    }

    function depositEther(
        address payee,
        string memory password,
        bool payerRefundable,
        bool fixedPayee
    ) external payable {
        address payer = msg.sender;
        require(payee != address(0), "Invalid receiver address");

        allEscrows.push(
            Escrow(
                msg.value,
                payer,
                payee,
                password,
                payerRefundable,
                fixedPayee
            )
        );
        emit EtherEscrowed(msg.sender, payee, msg.value);
    }

    function withdrawEther(uint id, string memory password) external payable {
        require(
            allEscrows[id].payee == msg.sender,
            "You are not the payee of this payment"
        );
        require(allEscrows[id].amount > 0, "No ether to withdraw");
        require(
            keccak256(abi.encodePacked(password)) ==
                keccak256(abi.encodePacked(allEscrows[id].password)),
            "Incorrect password"
        );

        payable(msg.sender).transfer(allEscrows[id].amount);

        emit EtherWithdrawn(msg.sender, allEscrows[id].amount);
        allEscrows[id].amount = 0;
    }

    function refundEhter(uint id) external payable {
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
