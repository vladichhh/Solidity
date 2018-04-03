pragma solidity ^0.4.18;

contract Faucet {
    
    address private owner;
    uint256 private sendAmount;
    
    event LogWithdraw(address recipient, uint256 amount);
    
    modifier onlyOwner() {
        require(msg.sender == owner);
        _;
    }
    
    modifier withdrawState(uint256 amount) {
        require(this.balance >= amount);
        _;
    }
    
    function Faucet() public {
        owner = msg.sender;
        sendAmount = 1 ether;
    }
    
    function() public payable {
        
    }
    
    function getBalance() public view returns (uint256) {
        return this.balance;
    }
    
    function changeSendAmount(uint256 _sendAmount) public onlyOwner {
        require(_sendAmount > 0);
        sendAmount = _sendAmount;
    }
    
    function send(address recepient) public {
        recepient.transfer(sendAmount);
    }
    
    function ownerWithdraw(uint256 amount) public onlyOwner {
        withdraw(this, amount);
    }
    
    function nonOwnerWithdraw(address recipient) public {
        withdraw(recipient, sendAmount);
    }
    
    function withdraw(address recipient, uint256 amount) private 
            withdrawState(amount) {
        recipient.transfer(amount);
        LogWithdraw(recipient, amount);
    }
    
    function destroy() public onlyOwner {
        selfdestruct(owner);
    }
    
}
