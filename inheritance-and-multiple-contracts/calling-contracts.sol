pragma solidity ^0.4.18;

contract MathHelper {
    function add(uint a, uint b) public pure returns (uint);
}

contract MathUser {
    
    MathHelper public mathHelper;
    uint public result;
    
    function MathUser(address helperAddress) public {
        mathHelper = MathHelper(helperAddress);
    }
    
    function work() public {
        uint n = 3;
        uint m = 4;
        
        result = mathHelper.add(n, m);
    }
    
    function tempContract(address helperAddress) public returns (MathHelper) {
        // option 1
        MathHelper helper = MathHelper(helperAddress);
        result = helper.add(7, 8);
        
        // option 2
        result = MathHelper(helperAddress).add(7, 8);
        
        // option 3
        result = helperAddress.add(7, 8);
        
        return helper;
    }
    
}
