pragma solidity ^0.4.18;

contract Owned {
    
    address public owner;
    
    modifier onlyOwner {
        require(msg.sender == owner);
        _;
    }
    
    function Owned() public {
        owner = msg.sender;
    }
}

contract MathHelper {
    
    // function that can safely add uint8s by checking for overflow
    function add(uint8 a, uint8 b) internal pure returns (uint8) {
        uint8 c = a + b;
        assert(c >= a);
        return c;
    }
}

contract OwnerCounter is Owned, MathHelper {
    
    uint8 public counter;
    
    function OwnerCounter() public {
        
    }
    
    function reset() public {
        counter = 0;
    }
    
    function addToCounter(uint8 b) public onlyOwner {
        counter = add(counter, b);
    }
    
}
