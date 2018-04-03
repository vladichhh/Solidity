pragma solidity ^0.4.18;

/*
   interface contract (like abstract contracts, but with the additional limitations)
    - cannot have implemented functions
    - cannot inherit other interfaces or contracts
    - cannot define constructors, variables and custom types (struct, enum, etc.)
*/
interface Feline {
    function utterance() external returns (string);
}

contract Cat is Feline {
    
    // implement the abstract method from parent
    function utterance() external returns (string) {
        return "miaow";
    }
    
}
