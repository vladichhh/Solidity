pragma solidity 0.4.21;

contract Ownable {
    
    address owner;
    
    modifier onlyOwner {
        require(msg.sender == owner);
        _;
    }
    
    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);
    
    function Ownable() public {
        owner = msg.sender;
    }
    
    function transferOwnership(address newOwner) public onlyOwner {
        require(newOwner != address(0));
        emit OwnershipTransferred(owner, newOwner);
        owner = newOwner;
    }
    
}

contract Destructible is Ownable {
    
    function Destructible() public payable { }
    
    function destroy() public onlyOwner {
        selfdestruct(owner);
    }
    
    function destroyAndSend(address recipient) public onlyOwner {
        selfdestruct(recipient);
    }
    
}

library VotingLib {
    
    struct Voting {
        bool exists;
        address recipient;
        uint amount;
        uint pointsFor;
        uint pointsAgainst;
        uint target;
        bool finished;
        bool successful;
        mapping(address => bool) voted;
    }
    
    function createVoting(address addr, uint value, uint targetPoints) internal 
            pure returns (Voting) {
        return Voting({exists: true,
                       recipient: addr,
                       amount: value,
                       pointsFor: 0,
                       pointsAgainst: 0,
                       target: targetPoints,
                       finished: false,
                       successful: false});
    }
    
    function update(Voting storage self, bool voteFor, uint8 importance) 
            internal returns (bool) {
        
        require(self.exists);
        require(!self.finished);
        require(!self.voted[msg.sender]);
        
        self.voted[msg.sender] = true;
        
        if (voteFor) {
            self.pointsFor += importance;
        } else {
            self.pointsAgainst += importance;
        }
        
        if (self.pointsFor >= self.target) {
            self.finished = true;
            self.successful = true;
        } else if (self.pointsAgainst >= self.target) {
            self.finished = true;
            self.successful = false;
        }
        
        return self.finished;
    }
    
}

contract MemberVoter is Ownable, Destructible {
    
    using VotingLib for VotingLib.Voting;
    
    event DonationExecuted(address indexed addr, uint amount);
    event VotingStarted(bytes32 indexed id, address recipient, uint value);
    event VotingEnded(bytes32 indexed id, bool successful);
    event WithdrawalApproved(address indexed addr, uint amount);
    event WithdrawalExecuted(address indexed addr, uint amount);
    
    struct Member {
        address addr;
        uint8 importance;
        uint timestamp;
    }
    
    mapping(address => Member) members;
    mapping(bytes32 => VotingLib.Voting) votings;
    mapping(address => uint) approvedWithdrawals;
    
    bool initialized;
    uint totalPoints;
    
    modifier onlyMember {
        require(members[msg.sender].addr != 0);
        _;
    }
    
    modifier canWithdraw {
        require(approvedWithdrawals[msg.sender] > 0);
        _;
    }
    
    function initialize(address[] addresses, uint8[] importances) public onlyOwner {
        require(!initialized);
        require(addresses.length >= 3);
        require(addresses.length == importances.length);
        
        uint points;
        
        for (uint i=0; i<addresses.length; i++) {
            members[addresses[i]] = Member({addr: addresses[i],
                                            importance: importances[i],
                                            timestamp: now});
            
            require(importances[i] >= 1 && importances[i] <= 3);
            
            points += importances[i];
        }
        
        totalPoints = points;
        initialized = true;
    }
    
    function donate() public payable {
        require(msg.value > 0);
        
        emit DonationExecuted(msg.sender, msg.value);
    }
    
    function startVoting(address addr, uint value) public onlyOwner returns (bytes32) {
        require(addr != address(0));
        require(value > 0);
        
        bytes32 votingId = keccak256(addr, value, now);
        
        require(!votings[votingId].exists);
        
        votings[votingId] = VotingLib.createVoting(addr, value, totalPoints);
        
        emit VotingStarted(votingId, addr, value);
        
        return votingId;
    }
    
    function vote(bytes32 id, bool voteFor) public {
        if (votings[id].update(voteFor, members[msg.sender].importance)) {
            emit VotingEnded(id, votings[id].successful);
            
            if (votings[id].successful) {
                approvedWithdrawals[votings[id].recipient] = votings[id].amount;
                emit WithdrawalApproved(votings[id].recipient, votings[id].amount);
            }
        }
    }
    
    function withdraw() public canWithdraw {
        uint amount = approvedWithdrawals[msg.sender];
        
        approvedWithdrawals[msg.sender] = 0;
        
        msg.sender.transfer(amount);
        
        emit WithdrawalExecuted(msg.sender, amount);
    }
    
}
