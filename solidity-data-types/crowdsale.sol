pragma solidity ^0.4.18;

contract Crowdsale {
    
    struct Holder {
        uint tokens;
        bool flag;
    }
    
    mapping(address => Holder) private holders;
    
    address[] private holdersArr;
    
    uint constant private WITHDRAW_RESTRICTION_DURATION = 1 years;
    uint constant private CROWDSALE_DURATION = 5 minutes;
    
    address private owner;
    uint private start;
    
    modifier onlyOwner {
        require(msg.sender == owner);
        _;
    }
    
    modifier crowdsalePhase {
        require(now < start + CROWDSALE_DURATION);
        _;
    }
    
    modifier openExchangePhase {
        require(now > start + CROWDSALE_DURATION);
        _;
    }
    
    modifier withdrawAllowed {
        require(now > start + WITHDRAW_RESTRICTION_DURATION);
        _;
    }
    
    function Crowdsale() public {
        owner = msg.sender;
        start = now;
    }
    
    function buyTokens() public payable crowdsalePhase {
        uint256 tokens = (msg.value / 1 ether) * 5;
        
        updateTokenHolder(msg.sender, tokens);
        
        uint256 returnAmount = msg.value % 1 ether;
        
        if (returnAmount > 0) {
            msg.sender.transfer(returnAmount);
        }
    }
    
    function sendTokens(address recipient, uint tokens) 
            public openExchangePhase {
        require(holders[msg.sender].tokens >= tokens);
        
        holders[msg.sender].tokens -= tokens;
        
        updateTokenHolder(recipient, tokens);
    }
    
    function updateTokenHolder(address holderAddress, uint tokens) public {
        if (!holders[holderAddress].flag) {
            holders[holderAddress] = Holder(tokens, true);
            holdersArr.push(holderAddress);
        } else {
            holders[holderAddress].tokens += tokens;
        }
    }
    
    function getHolderBalance(address holderAddress) public view returns (uint) {
        return holders[holderAddress].tokens;
    }
    
    function getTokenHolders() public view returns (address[]) {
        return holdersArr;
    }
    
    // retrieve contract balance
    function getContractBalance() public view returns (uint) {
        return this.balance;
    }
    
    // withdraws the whole contract amount
    function withdraw() public onlyOwner withdrawAllowed {
        require(this.balance > 0);
        owner.transfer(this.balance);
    }
    
}
