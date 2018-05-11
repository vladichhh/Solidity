pragma solidity 0.4.19;

contract AbstractMarketplace {
    
    function getBalance() public view returns (uint256);
    function newProduct(string name, uint256 price, uint256 quantity) public returns(bytes32);
    function getProduct(bytes32 productId) public view returns(string name, uint256 price, uint256 quantity);
    function getProducts() public view returns(bytes32[]);
    function getPrice(bytes32 productId, uint256 quantity) public view returns (uint256);
    function update(bytes32 productId, uint256 newQuantity) public;
    function buy(bytes32 productId, uint256 quantity) public payable;
    function withdraw() public;
    
    event ProductAdded(bytes32 indexed productId, string name, uint256 price, uint256 quantity);
    event ProductPurchased(bytes32 indexed productId, address buyer, uint256 quantity, uint256 price);
    event ProductUpdated(bytes32 indexed productId, uint256 newQuantity);
    event Withdrawal(uint256 amount);
    
}
