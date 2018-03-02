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
    
    function changeOwnership(address _owner) public {
        owner = _owner;
    }
    
}

contract SafeMath {
    
    function add(uint256 a, uint256 b) public pure returns (uint256) {
        uint256 c = a + b;
        assert(c >= a);
        return c;
    }
    
    function substract(uint256 a, uint256 b) public pure returns (uint256) {
        assert(a >= b);
        return a - b;
    }
    
    function multiply(uint256 a, uint256 b) public pure returns (uint256) {
        uint256 c;
        
        if (a == 0 || b == 0) {
            return 0;
        } else {
            c = a * b;
            assert(a == c / b);
        }
        
        return c;
    }
    
}

contract Counter is Owned, SafeMath {
    
    uint256 public state;
    uint256 lastChange = now;
    
    function changeState() public onlyOwner {
        state = add(state, now % 256);
        state = multiply(state, substract(now, lastChange));
        state = substract(state, block.gaslimit);
    }
    
}
