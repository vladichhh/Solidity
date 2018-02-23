pragma solidity ^0.4.18;

contract Ownership {
    
    address private owner;
    
    modifier onlyOwner {
        require(msg.sender == owner);
        _;
    }
    
    event LogChangeOwnership(address oldOwner, address newOwner);
    
    function changeOwner(address _owner) public onlyOwner {
        LogChangeOwnership(owner, msg.sender);
        owner = _owner;
    }
    
}
