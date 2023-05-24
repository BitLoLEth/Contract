// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";

contract BitLoL is ERC20 {
    uint256 public circulatingSupply = 0;
    uint256 public constant TAX_UNTIL = 2100000000 * 10**18; // 2.1 billion in gwei
    uint256 public constant BURN_RATE = 21; // 2.1%
    uint256 public constant TOTAL_SUPPLY = 21000000000 * 10**18; // 21 billion in gwei
    uint256 public constant MAX_PURCHASE = 100000000 * 10**18; // 100 million in gwei
    uint256 public constant TOKEN_PRICE = 1 * 10**9; // 0.000000001 ETH per token in wei
    uint256 public constant NOLIM_HOLDERS = 300;
    uint256 public totalHolders = 0;
    address public owner;
    bool public saleEnded = false;
    mapping(address => uint256) public purchaseRecords;
    mapping(address => bool) public isHolder;

    constructor() ERC20("BitLoL", "LOL") {
        owner = msg.sender;
        circulatingSupply = TOTAL_SUPPLY;
        uint256 ownerSupply = TOTAL_SUPPLY / 2; // 50%
        _mint(owner, ownerSupply);
        _mint(address(this), TOTAL_SUPPLY - ownerSupply);
        isHolder[owner] = true;
        totalHolders++;
    }

    function _transfer(address sender, address recipient, uint256 amount) internal override {
        require(!saleEnded || recipient != address(this), "Cannot send tokens to contract after sale ended.");
        if(sender != owner && sender != address(this)) {
            if(circulatingSupply >= TAX_UNTIL) {
                uint256 burnAmount = (amount * BURN_RATE) / 1000; // 2.1%
                super._transfer(sender, 0x000000000000000000000000000000000000dEaD, burnAmount);
                amount -= burnAmount;
                circulatingSupply -= burnAmount;
            }
            if(totalHolders < NOLIM_HOLDERS) {
                require(amount <= MAX_PURCHASE, "Transfer amount exceeds maximum limit.");
            }
        }
        super._transfer(sender, recipient, amount);
        if(!isHolder[recipient] && recipient != address(0)) {
            isHolder[recipient] = true;
            totalHolders++;
        }
    }

    receive() external payable {
        require(!saleEnded, "Sale has ended.");
        require(msg.sender != owner, "Owner cannot purchase more tokens.");

        uint256 toPurchase = (msg.value * 10**18) / TOKEN_PRICE; // first multiply with 10^18 then divide
        uint256 contractBalance = balanceOf(address(this));

        if(toPurchase > contractBalance) {
            uint256 returnEther = (toPurchase - contractBalance) * TOKEN_PRICE;
            payable(msg.sender).transfer(returnEther);

            toPurchase = contractBalance;
        }

        uint256 userTotalPurchase = purchaseRecords[msg.sender] + toPurchase;
        if(userTotalPurchase > MAX_PURCHASE) {
            uint256 excess = userTotalPurchase - MAX_PURCHASE;
            uint256 returnEther = excess * TOKEN_PRICE;
            payable(msg.sender).transfer(returnEther);
            toPurchase -= excess;
        }

        purchaseRecords[msg.sender] = purchaseRecords[msg.sender] + toPurchase;
        _transfer(address(this), msg.sender, toPurchase);
        payable(owner).transfer(msg.value - msg.value % TOKEN_PRICE); // forward the ETH to the owner

        if(balanceOf(address(this)) == 0) {
            saleEnded = true;
            }
        }

        function renounceOwnership() public {
            require(msg.sender == owner, "Only the owner can renounce ownership.");
            owner = address(0);
        }

        function getCirculatingSupply() public view returns (uint256) {
            return circulatingSupply;
        }
    }



