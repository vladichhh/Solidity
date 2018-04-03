pragma solidity ^0.4.18;

// abstract contract
contract Feline {
    function utterance() public returns (string);
}

contract Cat is Feline {
    
    // implement the abstract method from parent
    function utterance() public returns (string) {
        return "miaow";
    }
    
}
