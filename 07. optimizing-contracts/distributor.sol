pragma solidity 0.4.20;

contract Ownable {
    
    address owner;
    
    modifier onlyOwner {
        require(msg.sender == owner);
        _;
    }
    
    function Ownable() public {
        owner = msg.sender;
    }    
}

contract Distributor is Ownable {
    
    modifier isInitialized {
        require(initialized);
        _;
    }

    bool initialized;
    address[] addresses;
    mapping(address => uint256) public withdrawals;
    
    
    function initialize(address[] _addresses) public onlyOwner {
        require(!initialized);
        
        addresses = _addresses;
        
        initialized = true;
    }
    
    function donate() public isInitialized payable {
        uint256 amount = this.balance / addresses.length;
        
        for (uint256 i=0; i<addresses.length; i++) {
            withdrawals[addresses[i]] += amount;
        }
    }
    
    function withdraw() public {
        withdrawals[msg.sender] = 0;
        msg.sender.transfer(withdrawals[msg.sender]);
    }

}
