pragma solidity ^0.4.18;

contract Service {
    
    uint constant private servicePrice = 1 ether;
    uint constant private withdrawAmountLimit = 5 ether;
    
    address private owner;
    uint private lastPurchase;
    uint private lastWithdraw;
    
    modifier onlyOwner() {
        require(msg.sender == owner);
        _;
    }
    
    modifier purchaseLock() {
        require(now >= lastPurchase + 2 minutes);
        _;
    }
    
    modifier withdrawLock() {
        require(now >= lastWithdraw + 1 hours);
        _;
    }
    
    modifier positiveBalance() {
        require(this.balance > 0 ether);
        _;
    }
    
    event Purchase(address indexed buyer, uint returnAmount);
    
    function Service() public {
        owner = msg.sender;
    }
    
    function getBalance() public view returns (uint) {
        return this.balance;
    }
    
    function purchase() public payable purchaseLock {
        address buyer = msg.sender;
        uint payedPrice = msg.value;
        uint balanceBeforeTransfer;
        uint returnAmount;
        
        require(payedPrice >= servicePrice);
        
        if (payedPrice > servicePrice) {
            returnAmount = payedPrice - servicePrice;
            buyer.transfer(returnAmount);
        }
        
        assert(this.balance == balanceBeforeTransfer - returnAmount);
        
        Purchase(buyer, returnAmount);
    }
    
    function withdraw() public onlyOwner withdrawLock positiveBalance {
        uint balanceBeforeWithdraw;
        uint withdrawAmount = (this.balance >= withdrawAmountLimit) 
            ? withdrawAmountLimit : this.balance;
        
        owner.transfer(withdrawAmount);
        
        assert(this.balance == balanceBeforeWithdraw - withdrawAmount);
        
        lastWithdraw = now;
    }
    
}
