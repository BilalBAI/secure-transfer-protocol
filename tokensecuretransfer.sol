// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

interface IERC20 {
    function transfer(
        address recipient,
        uint256 amount
    ) external returns (bool);

    function balanceOf(address account) external view returns (uint256);

    function transferFrom(
        address from,
        address to,
        uint256 value
    ) external returns (bool);
}

contract TokenEscrow {
    address public owner;
    uint256 public refundTime = 1 days; // 1 day (24 hours) for refund
    mapping(address => mapping(address => uint256)) public escrowedTokens;
    mapping(address => string) public senderPasswords;
    mapping(address => uint256) public tokenDepositTimes;

    struct Escrow {
        address token;
        uint amount;
        address payer;
        address payee;
        string password;
        bool payerRefundable;
        bool fixedPayee;
    }
    Escrow[] private allEscrows;

    event TokensEscrowed(
        address indexed sender,
        address indexed receiver,
        address indexed token,
        uint256 amount
    );
    event TokensWithdrawn(
        address indexed receiver,
        address indexed token,
        uint256 amount
    );
    event TokensRefunded(
        address indexed sender,
        address indexed token,
        uint256 amount
    );

    modifier onlyOwner() {
        require(msg.sender == owner, "You are not the owner");
        _;
    }

    constructor() {
        owner = msg.sender;
    }

    function searchEscrowsIDByPayer(
        address token
    ) external view returns (uint) {
        for (uint i; i < allEscrows.length; i++) {
            if (
                allEscrows[i].payer == msg.sender &&
                allEscrows[i].token == token &&
                allEscrows[i].amount > 0
            ) {
                return i;
            }
        }
        return 0;
    }

    function searchEscrowsIDByPayee(
        address token
    ) external view returns (uint) {
        for (uint i; i < allEscrows.length; i++) {
            if (
                allEscrows[i].payee == msg.sender &&
                allEscrows[i].token == token &&
                allEscrows[i].amount > 0
            ) {
                return i;
            }
        }
        return 0;
    }

    function setTokenPassword(string memory password) external {
        require(bytes(password).length > 0, "Password cannot be empty");
        senderPasswords[msg.sender] = password;
    }

    function depositTokens(
        address token,
        uint amount,
        address payee,
        string memory password,
        bool payerRefundable,
        bool fixedPayee
    ) external payable {
        address payer = msg.sender;
        require(token != address(0), "Invalid token address");
        require(payee != address(0), "Invalid receiver address");

        IERC20 erc20Token = IERC20(token);
        uint256 senderBalance = erc20Token.balanceOf(msg.sender);
        require(senderBalance >= amount, "Insufficient token balance");
        require(
            erc20Token.transferFrom(msg.sender, address(this), amount),
            "Token transfer failed"
        );

        allEscrows.push(
            Escrow(
                token,
                amount,
                payer,
                payee,
                password,
                payerRefundable,
                fixedPayee
            )
        );
        emit TokensEscrowed(msg.sender, payee, token, amount);
    }

    function withdrawTokens(uint id, string memory password) external {
        require(
            allEscrows[id].payee == msg.sender,
            "You are not the payee of this payment"
        );
        require(allEscrows[id].amount > 0, "No tokens to withdraw");
        require(
            keccak256(abi.encodePacked(password)) ==
                keccak256(abi.encodePacked(allEscrows[id].password)),
            "Incorrect password"
        );
        IERC20 erc20Token = IERC20(allEscrows[id].token);
        require(
            erc20Token.transferFrom(
                address(this),
                msg.sender,
                allEscrows[id].amount
            ),
            "Token transfer failed"
        );

        emit TokensWithdrawn(
            msg.sender,
            allEscrows[id].token,
            allEscrows[id].amount
        );
        allEscrows[id].amount = 0;
    }

    function refundTokens(uint id) external {
        require(
            allEscrows[id].payer == msg.sender,
            "You don't owner this payment"
        );
        require(allEscrows[id].amount > 0, "No tokens to refund");

        // require(
        //     block.timestamp >= tokenDepositTimes[msg.sender] + refundTime,
        //     "Refund time not reached yet"
        // );

        // escrowedTokens[msg.sender][token] = 0;
        // tokenDepositTimes[msg.sender] = 0;

        IERC20 erc20Token = IERC20(allEscrows[id].token);
        require(
            erc20Token.transferFrom(
                address(this),
                msg.sender,
                allEscrows[id].amount
            ),
            "Token transfer failed"
        );

        emit TokensRefunded(
            msg.sender,
            allEscrows[id].token,
            allEscrows[id].amount
        );
        allEscrows[id].amount = 0;
    }

    function depositEther(
        uint amount,
        address payee,
        string memory password,
        bool payerRefundable,
        bool fixedPayee
    ) external payable {
        address payer = msg.sender;
        require(payee != address(0), "Invalid receiver address");
        require(msg.value >= amount, "Insufficient Ether balance");

        allEscrows.push(
            Escrow(
                address(0),
                amount,
                payer,
                payee,
                password,
                payerRefundable,
                fixedPayee
            )
        );
        emit TokensEscrowed(msg.sender, payee, address(0), amount);
    }

    function withdrawEther(uint id, string memory password) external {
        require(
            allEscrows[id].payee == msg.sender,
            "You are not the payee of this payment"
        );
        require(allEscrows[id].amount > 0, "No tokens to withdraw");
        require(
            keccak256(abi.encodePacked(password)) ==
                keccak256(abi.encodePacked(allEscrows[id].password)),
            "Incorrect password"
        );
        IERC20 erc20Token = IERC20(allEscrows[id].token);
        require(
            erc20Token.transferFrom(
                address(this),
                msg.sender,
                allEscrows[id].amount
            ),
            "Token transfer failed"
        );

        emit TokensWithdrawn(
            msg.sender,
            allEscrows[id].token,
            allEscrows[id].amount
        );
        allEscrows[id].amount = 0;
    }

    function setOwner(address newOwner) external onlyOwner {
        require(newOwner != address(0), "Invalid owner address");
        owner = newOwner;
    }
}
