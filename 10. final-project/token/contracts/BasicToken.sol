pragma solidity 0.4.19;

import "./SafeMath";
import "./ERC20.sol";

contract BasicToken is ERC20 {
    
    using SafeMath for uint256;
    
    mapping(address => uint256) balances;
    
    uint256 nTokens;

    /**
     * @dev Total number of tokens in existence.
     */
    function totalSupply() public view returns (uint256) {
        return nTokens;
    }
    
    /**
     * @dev Transfer token for a specified address.
     * @param to The address to transfer to.
     * @param value The amount to be transferred.
     */
    function transfer(address to, uint256 value) public returns (bool) {
        require(to != address(0));
        require(value <= balances[msg.sender]);
    
        balances[msg.sender] = balances[msg.sender].sub(value);
        balances[to] = balances[to].add(value);
        
        Transfer(msg.sender, to, value);
        
        return true;
    }
    
    /**
     * @dev Gets the balance of the specified address.
     * @param owner The address to query the the balance of.
     * @return An uint256 representing the amount owned by the passed address.
     */
    function balanceOf(address owner) public view returns (uint256) {
        return balances[owner];
    }
    
}
