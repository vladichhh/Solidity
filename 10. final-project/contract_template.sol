pragma solidity 0.4.19;

contract Marketplace {

    function buy(bytes32 ID, uint quantity) public payable;
    
    function update(bytes32 ID, uint newQuantity) public;
    
    function newProduct(string name, uint price, uint quantity) public returns(bytes32);
    
    function getProduct(bytes32 ID) public view returns(string name, uint price, uint quantity);
    
    function getProducts() public view returns(bytes32[]);
    
    function getPrice(bytes32 ID, uint quantity) public view returns (uint);
    
    function withdraw() public;
    
}
