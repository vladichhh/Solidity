pragma solidity 0.4.19;

import "./BasicToken.sol";

contract StandardToken is ERC20, BasicToken {
    
    mapping (address => mapping (address => uint256)) internal allowed;
    
    /**
     * @dev Transfer tokens from one address to another.
     * @param from address The address which you want to send tokens from.
     * @param to address The address which you want to transfer to.
     * @param value uint256 the amount of tokens to be transferred.
     */
    function transferFrom(address from, address to, uint256 value) public returns (bool) {
        require(to != address(0));
        require(value <= balances[from]);
        require(value <= allowed[from][msg.sender]);
    
        balances[from] = balances[from].sub(value);
        balances[to] = balances[to].add(value);
        allowed[from][msg.sender] = allowed[from][msg.sender].sub(value);
        
        Transfer(from, to, value);
        
        return true;
    }
    
    /**
     * @dev Approve the passed address to spend the specified amount of tokens on behalf of msg.sender.
     * @param spender The address which will spend the funds.
     * @param value The amount of tokens to be spent.
     */
    function approve(address spender, uint256 value) public returns (bool) {
        allowed[msg.sender][spender] = value;
        
        Approval(msg.sender, spender, value);
        
        return true;
    }
    
    /**
     * @dev Function to check the amount of tokens that an owner allowed to a spender.
     * @param owner address The address which owns the funds.
     * @param spender address The address which will spend the funds.
     * @return A uint256 specifying the amount of tokens still available for the spender.
     */
    function allowance(address owner, address spender) public view returns (uint256) {
        return allowed[owner][spender];
    }
    
}
