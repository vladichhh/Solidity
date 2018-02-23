pragma solidity ^0.4.18;

contract Funding {
    
    struct HighestBidder {
        address addr;
        uint256 amount;
    }
    
    HighestBidder public highestBidder;
    
    function Funding() public {
        // initialization
        highestBidder = HighestBidder(msg.sender, 0);
        
        // alternative initialization
        highestBidder = HighestBidder({addr : msg.sender, amount : 0});
        
        // costs more gas
        highestBidder.addr = msg.sender;
        highestBidder.amount = 0;
    }
    
    function bid() public payable {
        if (msg.value > highestBidder.amount) {
            highestBidder = HighestBidder(msg.sender, msg.value);
        }
    }
    
}
