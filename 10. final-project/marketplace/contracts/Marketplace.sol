pragma solidity 0.4.19;

contract Ownable {
    
    event OwnershipTransferred(address previousOwner, address newOwner);
    
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
        OwnershipTransferred(owner, newOwner);
        
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
    
    function createProduct(string name, uint256 price, uint256 quantity) internal pure returns (Product) {
        return Product({name: name, price: price, quantity: quantity, exists: true});
    }
    
    function updateProduct(Product storage self, uint256 quantity) internal {
        self.quantity = quantity;
    }
    
    function calculatePrice(Product storage self, uint256 quantity) internal view returns (uint256) {
        return self.price.mul(quantity);
    }
    
    function buyProduct(Product storage self, uint256 quantity) internal {
        self.quantity = self.quantity.sub(quantity);
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
    
    event ProductAdded(bytes32 indexed productId, string name, uint256 price, uint256 quantity);
    event ProductPurchased(bytes32 indexed productId, address buyer, uint256 quantity, uint256 price);
    event ProductUpdated(bytes32 indexed productId, uint256 newQuantity);
    event Withdrawal(uint256 amount);
    
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
     * Adds a new product to the Marketplace by specifying its name, price and initial 
     * quantity. Function is called only from the contract owner.
     */
    function newProduct(string name, uint256 price, uint256 quantity) public onlyOwner 
                returns (bytes32) {
        
        require(price > 0);
        
        // callculate product id
        bytes32 productId = keccak256(name, price, quantity, now);
        
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
        uint256 amountToPay = getPrice(productId, quantity);
        
        require(msg.value >= amountToPay);
        
        // using ProductLib
        products[productId].buyProduct(quantity);
        
        // log event
        ProductPurchased(productId, msg.sender, quantity, amountToPay);
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