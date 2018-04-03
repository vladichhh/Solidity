
pragma solidity ^0.4.18;

contract Service {
    
    uint256 constant internal SERVICE_PRICE = 1 ether;
    uint256 constant internal WITHDRAW_AMOUNT_LIMIT = 5 ether;
    uint256 constant internal PURCHASE_LOCK_TIME = 2 minutes;
    uint256 constant internal WITHDRAW_LOCK_TIME = 1 hours;
    
    address private owner;
    uint256 private lastPurchase;
    uint256 private lastWithdraw;
    
    event LogPurchase(address indexed buyer, uint256 returnAmount);
    
    modifier onlyOwner() {
        require(msg.sender == owner);
        _;
    }
    
    modifier purchaseLock() {
        require(now >= lastPurchase + PURCHASE_LOCK_TIME);
        _;
    }
    
    modifier withdrawLock() {
        require(now >= lastWithdraw + WITHDRAW_LOCK_TIME);
        _;
    }
    
    modifier positiveBalance() {
        require(this.balance > 0);
        _;
    }
    
    function Service() public {
        owner = msg.sender;
    }
    
    function getBalance() public view returns (uint256) {
        return this.balance;
    }
    
    function purchase() public payable purchaseLock {
        uint256 balanceBeforeTransfer;
        uint256 returnAmount;
        
        require(msg.value >= SERVICE_PRICE);
        
        if (msg.value > SERVICE_PRICE) {
            returnAmount = msg.value - SERVICE_PRICE;
            msg.sender.transfer(returnAmount);
        }
        
        assert(this.balance == balanceBeforeTransfer - returnAmount);
        
        LogPurchase(msg.sender, returnAmount);
    }
    
    function withdraw() public onlyOwner withdrawLock positiveBalance {
        uint256 balanceBeforeWithdraw;
        uint256 withdrawAmount = (this.balance >= WITHDRAW_AMOUNT_LIMIT) 
            ? WITHDRAW_AMOUNT_LIMIT : this.balance;
        
        owner.transfer(withdrawAmount);
        
        assert(this.balance == balanceBeforeWithdraw - withdrawAmount);
        
        lastWithdraw = now;
    }
    
}
