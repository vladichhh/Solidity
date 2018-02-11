pragma solidity ^0.4.18;

contract MathFunctions {
    
    int private x = 0;
    
    function get() public view returns (int) {
        return x;
    }
    
    function reset() public {
        x = 0;
    }
    
    function add(int y) public returns (int) {
        x += y;
        return x;
    }
    
    function substract(int y) public returns (int) {
        x -= y;
        return x;
    }
    
    function multiply(int y) public returns (int) {
        x *= y;
        return x;
    }
    
    function divide(int y) public returns (int) {
        x /= y;
        return x;
    }
    
    function remainder(int y) public returns (int) {
        x %= y;
        return x;
    }
    
    function power(uint y) public returns (int) {
        bool positive = x >= 0; 
        
        if (!positive) {
            x *= -1;
        }
        
        x = int(uint(x) ** y);
        
        if (!positive && (y % 2 != 0)) {
            x *= -1;
        }
        
        return x;
    }
    
}
