// SPDX-License-Identifier: MIT
pragma solidity ^0.8.26;
//Transaction - from,to,timings,amount
contract Wallet {

//to store all the info regarding the transaction taking place
    struct Transaction{
      address from;
      address to;
      uint timestamp;
      uint amount;
    }
   //an array named as transactionHistory of type struct Transaction
    Transaction[] public transactionHistory;


    address public owner;
    string public str;
    bool public stop;
    event Transfer(address receiver,uint amount);  //store metadata after every transfer 
    event Receive(address sender,uint amonut);   //store data regarding every receive transaction
    event ReceiveUser(address sender, address receiver,uint amount);
   
    //constructor is deployed only once in a contract and tells the address who is deploying the contract
    constructor(){
        owner=msg.sender;
    }
 //to check that whether the person using the modifier is owner or not
    modifier onlyOwner() {
        require(msg.sender == owner,"You don't have access");
        _;
    }
    mapping(address => uint) suspiciousUser;


   
    modifier getSuspiciousUser(address _sender) {
      require(suspiciousUser[_sender]<5, "Activity found suspicious, Try later");
      _;
    }


    modifier isEmergencyDeclared() {
      require(stop==false,"Emergency declared");
      _;
    }
   
    function toggleStop() external onlyOwner {
      stop=!stop;
    }


    function changOwner(address newOwner) public onlyOwner isEmergencyDeclared {
       owner=newOwner;
    }


    /**Contract related functions**/
    function transferToContract(uint _startTime) external payable getSuspiciousUser(msg.sender) {
      require(block.timestamp>_startTime,"send after start time");
       transactionHistory.push(Transaction({
         from:msg.sender,
         to:address(this),
         timestamp:block.timestamp,
         amount:msg.value
       }));
    }




    function transferToUserViaContract(address payable to, uint _weiAmount) external onlyOwner {
        require(address(this).balance>=_weiAmount,"Not Enough Balance");
        require(to!=address(0),"Address format incorrect");
        to.transfer(_weiAmount);
         transactionHistory.push(Transaction({
         from:msg.sender,
         to:to,
         timestamp:block.timestamp,
         amount:_weiAmount
       }));
        emit Transfer(to,_weiAmount);
    }




    function withdrawFromContract(uint _weiAmount) external onlyOwner {
       require(address(this).balance >= _weiAmount, "Insuffficient balance");
       payable(owner).transfer(_weiAmount);
       transactionHistory.push(Transaction({
         from:address(this),
         to:owner,
         timestamp:block.timestamp,
         amount:_weiAmount
       }));
    }




    function getContractBalanceInWei() external view returns (uint) {
         return address(this).balance;
    }
   
     /**User related functions**/
    function transferToUserViaMsgValue(address _to) external payable {
       require(address(this).balance>=msg.value,"Insufficient Balance");
       require(_to!=address(0),"Adress format incorrect");
       payable (_to).transfer(msg.value);
       transactionHistory.push(Transaction({
         from:msg.sender,
         to:_to,
         timestamp:block.timestamp,
         amount:msg.value
       }));
    }


    //event - sender,receiver, amount
    function receiveFromUser() external payable {
      require(msg.value>0,"Wei Value must be greater than zero");
      payable(owner).transfer(msg.value);
      emit ReceiveUser(msg.sender, owner, msg.value);
      transactionHistory.push(Transaction({
         from:msg.sender,
         to:owner,
         timestamp:block.timestamp,
         amount:msg.value
       }));
    }


    function getOwnerBalanceInWei() external view returns(uint){
       return owner.balance;
    }


    receive() external payable {
      transactionHistory.push(Transaction({
         from:msg.sender,
         to:address(this),
         timestamp:block.timestamp,
         amount:msg.value
       }));
       emit Receive(msg.sender, msg.value);
    }


     function suspiciousActivity(address _sender) public {
      suspiciousUser[_sender] += 1;
    }


    fallback() external {
      suspiciousActivity(msg.sender);
    }


    function getTransactionHistory() external view returns(Transaction[] memory){
      return transactionHistory;
    }


    function emergencyWithdrawl() external {
      require(stop==true,"Emergency not declared");
      payable(owner).transfer(address(this).balance);
    }




}
