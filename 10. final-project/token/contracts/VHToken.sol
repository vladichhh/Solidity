pragma solidity 0.4.19;

import "./StandardToken.sol";

contract VHToken is StandardToken {
    
    string public constant name = 'VH Token';
    string public constant symbol = 'VHT';
    uint256 public constant initialSupply = 1000000;

    function VHToken() public {
        nTokens = initialSupply;
        balances[msg.sender] = initialSupply;
        
        Transfer(address(0), msg.sender, initialSupply);
    }
    
}
