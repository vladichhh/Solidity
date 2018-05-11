pragma solidity 0.4.19;

import "./Ownable.sol";

contract Destructible is Ownable {
    
    function Destructible() public payable { }
    
    // destroys the contract and sends the balance to the owner
    function destroy() public onlyOwner {
        selfdestruct(owner);
    }
    
    // destroys the contract and sends the balance to the specified recipient
    function destroyAndSend(address recipient) public onlyOwner {
        selfdestruct(recipient);
    }
    
}
