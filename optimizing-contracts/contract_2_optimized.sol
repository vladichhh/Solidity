pragma solidity 0.4.20;

library VotingLib {
    
    struct Vote {
        uint256 id;
        uint256 votesFor;
        uint256 votesAgainst;
        uint256 target;
        bool finished;
        bool successful;
        mapping(address => bool) voted;
    }
    
    function update(Vote storage self, address voter, bool voteFor) public returns (bool) {
        require(!self.finished);
        require(!self.voted[voter]);
        
        self.voted[voter] = true;
        
        if (voteFor) {
            self.votesFor++;
        } else {
            self.votesAgainst++;
        }
        
        if (self.votesFor >= self.target) {
            self.finished = true;
            self.successful = true;
        } else if (self.votesAgainst >= self.target) {
            self.finished = true;
            self.successful = false;
        }
        
        return self.finished;
    }
    
}

contract Voting {
    
    using VotingLib for VotingLib.Vote;
    
    event LogStartedVote(uint256 id);
    event LogEndedVote(uint256 id, bool successful);
    
    mapping(uint256 => VotingLib.Vote) public votes;
    
    address owner;
    bool initialized;
    
    mapping(address => bool) voters;
    uint256 nVoters;
    
    modifier onlyOwner {
        require(msg.sender == owner);
        _;
    }
    
    modifier onlyVoter {
        require(voters[msg.sender]);
        _;
    }
    
    modifier isInit {
        require(initialized);
        _;
    }
    
    modifier voteExists(uint256 id) {
        require(votes[id].id != 0);
        _;
    }
    
    function Voting() public {
        owner = msg.sender;
    }
    
    function initialize(address[] _voters) public onlyOwner {
        require(_voters.length >= 2);
        require(!initialized);
        
        nVoters = (_voters.length % 2 == 0) ? _voters.length : _voters.length + 1;
        
        for (uint i=0; i<_voters.length; i++) {
            voters[_voters[i]] = true;
        }
        
        initialized = true;
    }
    
    function startVote() public isInit onlyVoter returns(uint256) {
        uint256 voteId = now;
        
        votes[voteId] = VotingLib.Vote({id: voteId,
                                        votesFor: 0,
                                        votesAgainst: 0,
                                        target: nVoters/2,
                                        finished: false,
                                        successful: false});
        
        LogStartedVote(voteId);
        
        return voteId;
    }
    
    function vote(uint256 id, bool voteFor) public isInit onlyVoter voteExists(id) {
        
        if (votes[id].update(msg.sender, voteFor)) {
            LogEndedVote(id, votes[id].successful);
        }
    }
    
}
