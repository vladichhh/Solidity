pragma solidity 0.4.19;

import "./Ownable.sol";
import "./Destructible.sol";
import "./AbstractMarketplace.sol";
import "./SafeMath.sol";
import "./ProductLib.sol";

contract Marketplace is Ownable, Destructible, AbstractMarketplace {
    
    using ProductLib for ProductLib.Product;
    
    mapping(bytes32 => ProductLib.Product) products;
    bytes32[] productIds;
    
    modifier productExists(bytes32 productId) {
        require(products[productId].exists);
        _;
    }
    
    modifier hasValue {
        require(msg.value > 0);
        _;
    }
    
    /**
     * Buys a store item by specifying its id and quantity. The method should execute successfully 
     * if the Marketplace has enough of the item in stock and the sent funds are sufficient. Overpay 
     * is considered a tip.
     */
    function buy(bytes32 productId, uint quantity) public payable hasValue productExists(productId) {
        require(quantity > 0);
        require(products[productId].quantity >= quantity);
        
        if (products[productId].buyProduct(quantity)) {
            ProductPurchased(productId, quantity, now);
        }
    }
    
    /**
     * Updates the stock of an item by taking its id and the new availability (items in stock). This 
     * method should only be called from the contract owner.
     */
    function update(bytes32 productId, uint newQuantity) public onlyOwner productExists(productId) {
        products[productId].updateProduct(newQuantity);
        
        ProductUpdated(productId, newQuantity, now);
    }
    
    /**
     * Adds a new product to the Marketplace by specifying its name, price and initial quantity. 
     * Function is called only by the contract owner.
     */
    function newProduct(string name, uint price, uint quantity) public onlyOwner returns (bytes32) {
        require(price > 0);
        
        bytes32 productId = keccak256(name, price, quantity);
        
        require(!products[productId].exists);
        
        products[productId] = ProductLib.createProduct(name, price, quantity);
        productIds.push(productId);
        
        ProductAdded(productId, name, price, quantity, now);
        
        return productId;
    }
    
    /**
     * Returns the price, name and stock about a product by its id.
     */
    function getProduct(bytes32 productId) public view productExists(productId) returns (string name, uint price, uint quantity) {
        return (products[productId].name, 
                products[productId].price, 
                products[productId].quantity);
    }
    
    /**
     * Returns an array of all product ids.
     */
    function getProducts() public view returns (bytes32[]) {
        return productIds;
    }
    
    /**
     * Calculates the price to be paied for the specified quantitity of a certain product.
     */
    function getPrice(bytes32 productId, uint quantity) public view productExists(productId) returns (uint) {
        return products[productId].calculatePrice(quantity);
    }
    
    /**
     * Withdraws the funds from the contract. This function should be called only from the contract owner.
     */
    function withdraw() public onlyOwner {
        require(address(this).balance > 0);
        
        uint256 amount = address(this).balance;
        
        owner.transfer(amount);
        
        Withdrawal(amount, now);
    }
    
}
