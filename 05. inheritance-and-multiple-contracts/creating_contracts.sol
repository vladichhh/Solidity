pragma solidity ^0.4.18;

contract MathHelper {
    
    function add(uint a, uint b) public pure returns (uint) {
        return a + b;
    }
    
}

contract MathUser {
    
    MathHelper public mathHelper;
    uint public result;
    
    function MathUser() public {
        mathHelper = new MathHelper();
    }
    
    function work() public {
        uint n = 3;
        uint m = 4;
        
        result = mathHelper.add(n, m);
    }
    
    function tempContract() public returns (MathHelper) {
        MathHelper helper = new MathHelper();
        
        result = helper.add(7, 8);
        
        return helper;
    }
    
}
