pragma solidity 0.4.20;

contract Members {
    
    struct Member {
        address addr;
        uint joinedAt; //timestamp
    }
    
    modifier onlyOwner {
        require(msg.sender == owner);
        _;
    }
    
    address owner;
    bool initialized;
    
    mapping(address => Member) public members;

    function Members() public {
        owner = msg.sender;
    }
    
    function init(address[] addresses) public onlyOwner {
        require(!initialized);
       
        for (uint i = 0; i < addresses.length; i++) {
            members[addresses[i]] = Member({addr: addresses[i], joinedAt: now});
        }
        
        initialized = true;
    }
    
}
