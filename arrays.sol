pragma solidity ^0.4.18;

contract Arrays {
    
    int[5] private fixedArr = [1, 2, 3, 4, 5];
    int[] private dynamicArr;
    
    function getFixedArr() public view returns (int[5]) {
        return fixedArr;
    }
    
    function getDynamicArr() public view returns (int[]) {
        return dynamicArr;
    }
    
    function push(int element) public {
        dynamicArr.push(element);
        
        // alternative way to push an element
        dynamicArr.length++;
        dynamicArr[dynamicArr.length-1] = element;
    }
    
}
