pragma solidity 0.4.19;

contract Ownable {
    
    event OwnershipTransferred(address previousOwner, address newOwner, uint256 timestamp);
    
    address public owner;
    
    modifier onlyOwner {
        require(msg.sender == owner);
        _;
    }
    
    function Ownable() public {
        owner = msg.sender;
    }
    
    function transferOwnership(address newOwner) public onlyOwner {
        require(newOwner != address(0));
        
        // log event
        OwnershipTransferred(owner, newOwner, now);
        
        // updates the owner
        owner = newOwner;
    }
    
}

contract Destructible is Ownable {
    
    function Destructible() public payable { }
    
    // destroys the contract and sends the balance to the owner
    function destroy() public onlyOwner {
        selfdestruct(owner);
    }
    
    // destroys the contract and sends the balance to the specified recipient
    function destroyAndSend(address recipient) public onlyOwner {
        selfdestruct(recipient);
    }
    
}

library SafeMath {
    
    function add(uint256 a, uint256 b) internal pure returns (uint256) {
        uint256 c = a + b;
        assert(c >= a);
        return c;
    }
    
    function sub(uint256 a, uint256 b) internal pure returns (uint256) {
        assert(b <= a);
        return a - b;
    }
    
    function mul(uint256 a, uint256 b) internal pure returns (uint256) {
        if (a == 0) {
            return 0;
        }
        
        uint256 c = a * b;
        assert(c / a == b);
        return c;
    }
    
    function div(uint256 a, uint256 b) internal pure returns (uint256) {
        assert(b > 0);
        uint256 c = a / b;
        assert(a == b * c + a % b);
        return c;
    }
    
}

library ProductLib {
    
    using SafeMath for uint256;
    
    struct Product {
        string name;
        uint256 price;
        uint256 quantity;
        bool exists;
    }
    
    function createProduct(string _name, uint256 _price, uint256 _quantity) internal pure returns (Product) {
        // converts the price from Eth to Wei
        return Product({name: _name, price: toWei(_price), quantity: _quantity, exists: true});
    }
    
    function updateProduct(Product storage self, uint256 _quantity) internal {
        self.quantity = _quantity;
    }
    
    function calculatePrice(Product storage self, uint256 _quantity) internal view returns (uint256) {
        return self.price.mul(_quantity);
    }
    
    function buyProduct(Product storage self, uint256 _quantity) internal {
        self.quantity = self.quantity.sub(_quantity);
    }
    
    function toWei(uint256 value) internal pure returns (uint256) {
        return value.mul(1000000000000000000);
    }
    
}

contract AbstractMarketplace {
    
    function getBalance() public view returns (uint256);
    function newProduct(string name, uint256 price, uint256 quantity) public returns(bytes32);
    function getProduct(bytes32 productId) public view returns(string name, uint256 price, uint256 quantity);
    function getProducts() public view returns(bytes32[]);
    function getPrice(bytes32 productId, uint256 quantity) public view returns (uint256);
    function update(bytes32 productId, uint256 newQuantity) public;
    function buy(bytes32 productId, uint256 quantity) public payable;
    function withdraw() public;
    
    event ProductAdded(bytes32 indexed productId, string name, uint256 price, uint256 quantity, uint256 timestamp);
    event ProductPurchased(bytes32 indexed productId, uint256 price, uint256 quantity, uint256 timestamp);
    event ProductUpdated(bytes32 indexed productId, uint256 initQuantity, uint256 newQuantity, uint256 timestamp);
    event Withdrawal(uint256 amount, uint256 timestamp);
    
}

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
     * Adds a new product to the Marketplace by specifying its name, price and initial quantity. Function 
     * is called only from the contract owner.
     */
    function newProduct(string name, uint256 price, uint256 quantity) public onlyOwner returns (bytes32) {
        require(price > 0);
        
        // callculate product id
        bytes32 productId = keccak256(name, price, quantity);
        
        // product should not exist already
        require(!products[productId].exists);
        
        // using ProductLib
        products[productId] = ProductLib.createProduct(name, price, quantity);
        
        productIds.push(productId);
        
        // log event
        ProductAdded(productId, name, price, quantity, now);
        
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
    function getPrice(bytes32 productId, uint256 quantity) public view 
                productExists(productId) returns (uint256) {
        
        // using ProductLib
        return products[productId].calculatePrice(quantity);
    }
    
     /**
     * Updates the stock of an item by taking its id and the new availability (items in stock). Function 
     * is called only from the contract owner.
     */
    function update(bytes32 productId, uint256 newQuantity) public onlyOwner productExists(productId) {
        uint256 initQuantity = products[productId].quantity;
        
        // using ProductLib
        products[productId].updateProduct(newQuantity);
        
        // log event
        ProductUpdated(productId, initQuantity, newQuantity, now);
    }
    
    /**
     * Buys a store item by specifying its id and quantity. The method should execute successfully 
     * if the Marketplace has enough of the item in stock and the sent funds are sufficient. Overpay 
     * is considered a tip.
     */
    function buy(bytes32 productId, uint256 quantity) public payable productExists(productId) 
                hasValue hasQuantity(productId, quantity) {
        
        // calculate the amount required to buy the requested quantity
        uint256 requiredAmount = products[productId].calculatePrice(quantity);
        
        require(msg.value >= requiredAmount);
        
        // using ProductLib
        products[productId].buyProduct(quantity);
        
        // log event
        ProductPurchased(productId, products[productId].price, quantity, now);
        
        // calculate the amount to be returned
        uint256 returnAmount = msg.value.sub(requiredAmount);
        
        if (returnAmount > 0) {
            // execute the transfer
            msg.sender.transfer(returnAmount);
        }
    }
    
    /**
     * Withdraws the funds from the contract. Function is called only from the contract owner.
     */
    function withdraw() public onlyOwner {
        require(this.balance > 0);
        
        uint256 amount = this.balance;
        
        // execute the tranfer
        owner.transfer(amount);
        
        // log event
        Withdrawal(amount, now);
    }
    
}
