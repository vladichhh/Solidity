pragma solidity 0.4.19;

import "./Ownable.sol";

contract Destructible is Ownable {
    
    function Destructible() public payable { }
    
    function destroy() public onlyOwner {
        selfdestruct(owner);
    }
    
    function destroyAndSend(address recipient) public onlyOwner {
        selfdestruct(recipient);
    }
    
}
