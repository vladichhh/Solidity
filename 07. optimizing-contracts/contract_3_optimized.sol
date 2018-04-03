pragma solidity 0.4.21;

contract Ownable {
    
    address public owner;
    
    modifier onlyOwner() {
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

library MemberLib {
    
    struct Member {
        address addr;
        uint256 joinedAt;
        uint256 donated;
    }
    
    function createMember(address _addr) internal view returns (Member) {
        return Member({addr: _addr, joinedAt: now, donated: 0});
    }
    
    function donate(Member self, uint256 value) internal pure {
        self.donated += value;
    }
    
}

contract Members is Ownable {
    
    using MemberLib for MemberLib.Member;
    
    mapping(address => MemberLib.Member) public members;
    
    modifier onlyMember {
        require(members[msg.sender].addr != 0);
        _;
    }
    
    function addMember(address addr) public onlyOwner {
        require(addr != address(0));
        require(members[addr].addr == 0);
        
        members[addr] = MemberLib.createMember(addr);
    }
    
    function donate() public onlyMember payable {
        require(msg.value > 0);
        
        members[msg.sender].donate(msg.value);
    }
    
}
