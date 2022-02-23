// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import './EsadToken.sol';
import "@chainlink/contracts/src/v0.8/interfaces/AggregatorV3Interface.sol";

contract EsadTokenSale{
    address payable public admin;
    address payable private ethFunds = payable(0xAb0Ba71c1A1fDa4e2c5E67c9b94bBAA136887f70);
    EsadToken public token;
    uint256 public tokensSold;
    int public tokenPriceUSD;
    AggregatorV3Interface internal priceFeed;
    
    uint256 public transactionCount;
    event Sell(address _buyer, uint256 _amount);
    
    struct Transaction{
        address buyer;
        uint256 amount;
    }

    mapping(uint256 => Transaction) public transaction;

    constructor(EsadToken _token){
        priceFeed = AggregatorV3Interface(0x9326BFA02ADD2366b30bacB125260Af641031331);
        tokenPriceUSD = 1;
        token = _token;
        admin = payable(msg.sender);
    }



    function getETHprice() public view returns(int) {
         (, int price, , , ) = priceFeed.latestRoundData();
         return (price / 10**8);
    } 
         
       

    function EsadTokenPriceInETH() public view returns(int) {
         int ethPrice = getETHprice();
         return tokenPriceUSD / ethPrice;
    }
    
    function buyToken(uint256 _amount) public payable{
        int EsadTokenPriceETH = EsadTokenPriceInETH();
        require(int(msg.value) >= EsadTokenPriceETH * int(_amount));
        require(token.balanceOf(address(this)) >= _amount);
        require(token.transfer(msg.sender, _amount));
        ethFunds.transfer(msg.value);
        tokensSold += _amount;
        transaction[transactionCount] = Transaction(msg.sender, _amount);
        transactionCount++;
        emit Sell(msg.sender, _amount);
    }
    
    function endSale() public {
        require(msg.sender == admin);
        uint256 amount = token.balanceOf(address(this));
        require(token.transfer(admin, amount));
        selfdestruct(payable(admin));
        
    }


}