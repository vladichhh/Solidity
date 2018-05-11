pragma solidity 0.4.19;

import "./SafeMath.sol";
import "./Destructible.sol";
import "./ProductLib.sol";
import "./AbstractMarketplace.sol";

contract Marketplace is Ownable, Destructible, AbstractMarketplace {
    
    using ProductLib for ProductLib.Product;
    using SafeMath for uint256;
    
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
    
    modifier hasQuantity(bytes32 productId, uint256 quantity) {
        require(quantity > 0);
        require(products[productId].quantity >= quantity);
        _;
    }
    
    /**
     * Retieves the contract balance. Function is called only from the contract owner.
     */
    function getBalance() public view onlyOwner returns (uint256) {
        return this.balance;
    }
    
    /**
     * Adds a new product to the Marketplace by specifying its name, price and initial 
     * quantity. Function is called only from the contract owner.
     */
    function newProduct(string name, uint256 price, uint256 quantity) public onlyOwner 
                returns (bytes32) {
        
        require(price > 0);
        
        // callculate product id
        bytes32 productId = keccak256(name, quantity, price, now);
        
        // product should not exist already
        require(!products[productId].exists);
        
        products[productId] = ProductLib.Product({name: name,
                                                  price: price,
                                                  quantity: quantity, 
                                                  exists: true});
        productIds.push(productId);
        
        // log event
        ProductAdded(productId, name, price, quantity);
        
        return productId;
    }
    
    /**
     * Returns the price, name and stock about a product by its id.
     */
    function getProduct(bytes32 productId) public view productExists(productId) 
                returns (string name, uint256 price, uint256 quantity) {
        
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
    function getPrice(bytes32 productId, uint256 quantity) public view productExists(productId) 
                returns (uint256) {
        
        // using ProductLib
        return products[productId].calculatePrice(quantity);
    }
    
     /**
     * Updates the stock of an item by taking its id and the new availability (items in 
     * stock). Function is called only from the contract owner.
     */
    function update(bytes32 productId, uint256 newQuantity) public onlyOwner productExists(productId) {
        // using ProductLib
        products[productId].updateProduct(newQuantity);
        
        // log event
        ProductUpdated(productId, newQuantity);
    }
    
    /**
     * Buys a store item by specifying its id and quantity. The method should execute 
     * successfully if the Marketplace has enough of the item in stock and the sent funds
     * are sufficient. Overpay is considered a tip.
     */
    function buy(bytes32 productId, uint256 quantity) public payable productExists(productId) 
                hasValue hasQuantity(productId, quantity) {
        
        // calculate the amount required to buy the requested quantity
        uint256 price = getPrice(productId, quantity);
        
        require(msg.value >= price);
        
        // using ProductLib
        products[productId].buyProduct(quantity);
        
        // log event
        ProductPurchased(productId, msg.sender, quantity, price);
    }
    
    /**
     * Withdraws the funds from the contract. Function is called only from the contract owner.
     */
    function withdraw() public onlyOwner {
        require(this.balance > 0);
        
        uint256 amount = this.balance;
        
        // execute the transfer
        owner.transfer(amount);
        
        // log event
        Withdrawal(amount);
    }
    
}
