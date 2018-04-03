pragma solidity ^0.4.18;

contract Consensus {
    
    uint256 constant private PROPOSAL_DURATION = 5 minutes;
    
    struct Proposal {
        address addr;
        uint256 amount;
        uint256 timestamp;
    }
    
    Proposal public proposal;
    address[] public owners;
    uint public nextToVote;
    
    modifier isOwner {
        for (uint i=0; i<owners.length; i++) {
            if (owners[i] == msg.sender) {
                _;
                break;
            }
        }
    }
    
    function Consensus(address[] _owners) public {
        owners = _owners;
    }
    
    function() public payable {
        
    }
    
    function propose(address addr, uint256 amount) public isOwner {
        require(now > proposal.timestamp + PROPOSAL_DURATION);
        proposal = Proposal(addr, amount, now);
        nextToVote = 0;
    }
    
    function accept() public {
        require(nextToVote < owners.length);
        require(owners[nextToVote] == msg.sender);
        require(now < proposal.timestamp + PROPOSAL_DURATION);
        
        nextToVote++;
        
        if (nextToVote >= owners.length) {
            proposal.addr.transfer(proposal.amount);
        }
    }
    
}
