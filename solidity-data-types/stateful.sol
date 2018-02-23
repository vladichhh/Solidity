pragma solidity ^0.4.18;

contract Stateful {
    
    enum State {Unlocked, Restricted, Locked}
    
    struct Counter {
        address addr;
        uint256 timestamp;
        uint256 count;
    }
    
    modifier onlyOwner {
        require(msg.sender == owner);
        _;
    }
    
    modifier isCallable {
        require(state == State.Unlocked || 
            (state == State.Restricted && msg.sender == owner));
        _;
    }
    
    State public state;
    Counter public counter;
    address public owner;
    
    function Stateful() public {
        state = State.Unlocked;
        counter = Counter(msg.sender, now, 0);
        owner = msg.sender;
    }
    
    function changeState(State _state) public onlyOwner {
        state = _state;
    }
    
    function increment() public isCallable {
        inc();
    }
    
    function() public payable isCallable {
        inc();
    }
    
    function inc() private {
        counter = Counter(msg.sender, now, counter.count + 1);
    }
    
}
