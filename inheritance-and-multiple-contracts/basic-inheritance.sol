pragma solidity ^0.4.18;

contract Parent {
    
    uint public a = 3;
    uint private b = 4;
    
    function incrementA() public {
        a++;
    }
    
    function incrementB() private {
        b++;
    }
    
    function getB() public view returns (uint) {
        return b;
    }
    
    function getRandomNumber() public pure returns (uint) {
        return 42;
    }
    
}

contract Child is Parent {
    
    function addToA(uint num) public {
        a += num;
        // b++; -> can't access private member
    }
    
    function randomActions() public {
        incrementA();
        this.incrementA();
        // incrementB(); -> can't access private member
    }
    
    function getRandomNumber() public pure returns (uint) {
        return 1337;
    }
    
}
