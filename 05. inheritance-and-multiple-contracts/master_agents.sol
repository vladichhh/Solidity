pragma solidity ^0.4.18;

contract Agent {
    uint public constant WAIT_INTERVAL = 15 seconds;
    
    address public master;
    uint public lastOrder;
    
    modifier onlyMaster {
        require(msg.sender == master);
        _;
    }
    
    modifier canReceiveOrder {
        require(isReady());
        _;
    }
    
    function Agent(address _master) public {
        master = _master;
    }
    
    function receiveOrder() public onlyMaster canReceiveOrder {
        lastOrder = now;
    }
    
    function isReady() public view returns (bool) {
        return now > lastOrder + WAIT_INTERVAL;
    }
    
}

contract Master {
    
    address public owner;
    mapping(address => bool) public approvedAgents;
    
    modifier onlyOwner {
        require(msg.sender == owner);
        _;
    }
    
    modifier approvedAgent(Agent agent) {
        require(!approvedAgents[agent]);
        _;
    }
    
    function createAgent() public onlyOwner returns (Agent) {
        Agent agent = new Agent(this);
        approvedAgents[agent] = true;
        return agent;
    }
    
    function approveAgent(Agent agent) public onlyOwner {
        approvedAgents[agent] = true;
    }
    
    function giveOrder(Agent agent) public onlyOwner approvedAgent(agent) {
        return agent.receiveOrder();
    }
    
    function queryAgent(Agent agent) public view approvedAgent(agent) 
            returns (bool) {
        return agent.isReady();
    }
    
}
