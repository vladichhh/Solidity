pragma solidity ^0.4.18;

contract Service {
    
    uint constant internal SERVICE_PRICE = 1 ether;
    uint constant internal WITHDRAW_AMOUNT_LIMIT = 5 ether;
    
    address private owner;
    uint private lastPurchase;
    uint private lastWithdraw;
    
    event LogPurchase(address indexed buyer, uint returnAmount);
    
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
    
    function Service() public {
        owner = msg.sender;
    }
    
    function getBalance() public view returns (uint) {
        return this.balance;
    }
    
    function purchase() public payable purchaseLock {
        uint balanceBeforeTransfer;
        uint returnAmount;
        
        require(msg.value >= SERVICE_PRICE);
        
        if (msg.value > SERVICE_PRICE) {
            returnAmount = msg.value - SERVICE_PRICE;
            msg.sender.transfer(returnAmount);
        }
        
        assert(this.balance == balanceBeforeTransfer - returnAmount);
        
        LogPurchase(msg.sender, returnAmount);
    }
    
    function withdraw() public onlyOwner withdrawLock positiveBalance {
        uint balanceBeforeWithdraw;
        uint withdrawAmount = (this.balance >= WITHDRAW_AMOUNT_LIMIT) 
            ? WITHDRAW_AMOUNT_LIMIT : this.balance;
        
        owner.transfer(withdrawAmount);
        
        assert(this.balance == balanceBeforeWithdraw - withdrawAmount);
        
        lastWithdraw = now;
    }
    
}
