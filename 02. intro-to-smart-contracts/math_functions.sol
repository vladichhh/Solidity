pragma solidity ^0.4.18;

contract MathFunctions {
    
    int256 private x = 0;
    
    function get() public view returns (int256) {
        return x;
    }
    
    function reset() public {
        x = 0;
    }
    
    function add(int256 y) public returns (int256) {
        x += y;
        return x;
    }
    
    function substract(int256 y) public returns (int256) {
        x -= y;
        return x;
    }
    
    function multiply(int256 y) public returns (int256) {
        x *= y;
        return x;
    }
    
    function divide(int256 y) public returns (int256) {
        x /= y;
        return x;
    }
    
    function remainder(int256 y) public returns (int256) {
        x %= y;
        return x;
    }
    
    function power(uint256 y) public returns (int256) {
        bool positive = x >= 0; 
        
        if (!positive) {
            x *= -1;
        }
        
        x = int256(uint256(x) ** y);
        
        if (!positive && (y % 2 != 0)) {
            x *= -1;
        }
        
        return x;
    }
    
}
