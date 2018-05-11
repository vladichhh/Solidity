pragma solidity 0.4.19;

contract Ownable {
    
    event OwnershipTransferred(address previousOwner, address newOwner);
    
    address public owner;
    
    modifier onlyOwner {
        require(msg.sender == owner);
        _;
    }
    
    function Ownable() public {
        owner = msg.sender;
    }
    
    function transferOwnership(address newOwner) public onlyOwner {
        require(newOwner != address(0));
        
        // log event
        OwnershipTransferred(owner, newOwner);
        
        // updates the owner
        owner = newOwner;
    }
    
}
