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
    
    function createProduct(string name, uint256 price, uint256 quantity) internal pure 
                returns (Product) {
        
        return Product({name: name, price: price, quantity: quantity, exists: true});
    }
    
    function updateProduct(Product storage self, uint256 quantity) internal {
        self.quantity = quantity;
    }
    
    function calculatePrice(Product storage self, uint256 quantity) internal view 
                returns (uint256) {
        
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

contract AbstractExtendedMarketplace {
    
    enum PurchaseState {
        New,
    //  Expired,
        Cancelled,
        Completed
    }
    
    struct Purchase {
        uint256 dateCreation;
        uint256 dateExpiration;
        address firstBuyer;
        address secondBuyer;
        bytes32 productId;
        uint256 quantity;
        uint256 paied;
        uint256 toPay;
        PurchaseState state;
        bool exists;
    }
    
    function getPurchase(bytes32 purchaseId) public view
                returns (uint256 dateExpiration, address secondBuyer, bytes32 productId,
                         uint256 quantity, uint256 toPay, PurchaseState state);
    function registerPurchase(bytes32 productId, uint256 quantity, address secondBuyer) public payable;
    function cancelPurchase(bytes32 purchaseId) public;
    function finishPurchase(bytes32 purchaseId) public;
    
    event PurchaseRegistered(bytes32 indexed purchaseId, address firstBuyer, 
                             address secondBuyer, uint256 toPay);
    event PurchaseCancelled(bytes32 indexed purchaseId);
    event PurchaseCompleted(bytes32 indexed purchaseId);
    
}

contract ExtendedMarketplace is Marketplace, AbstractExtendedMarketplace {
    
    uint256 public constant PURCHASE_DURATION = 1 days;
    
    mapping(bytes32 => Purchase) purchases;
    mapping(address => uint256) payments;
    
    modifier purchaseExists(bytes32 purchaseId) {
        require(purchases[purchaseId].exists);
        _;
    }
    
    modifier onlyPurchaseAttendees(bytes32 purchaseId) {
        (msg.sender == purchases[purchaseId].firstBuyer ||
         msg.sender == purchases[purchaseId].secondBuyer);
        _;
    }
    
    function getPurchase(bytes32 purchaseId) public view purchaseExists(purchaseId) 
                onlyPurchaseAttendees(purchaseId)
                returns (uint256 dateExpiration, address secondBuyer, bytes32 productId, 
                         uint256 quantity, uint256 toPay, PurchaseState state) {
        
        return (purchases[purchaseId].dateExpiration,
                purchases[purchaseId].secondBuyer,
                purchases[purchaseId].productId,
                purchases[purchaseId].quantity,
                purchases[purchaseId].toPay,
                purchases[purchaseId].state);
    }
    
    function registerPurchase(bytes32 productId, uint256 quantity, address secondBuyer) public 
                payable productExists(productId) hasValue hasQuantity(productId, quantity) {
        
        // calculate the amount required to buy the requested quantity
        uint256 price = getPrice(productId, quantity);
        
        require(msg.value >= price.div(2));
        
        // using ProductLib
        products[productId].buyProduct(quantity);
        
        // log event
        ProductPurchased(productId, msg.sender, quantity, price);
        
        // added payment for the address
        payments[msg.sender] = payments[msg.sender].add(msg.value);
        
        // generate purchase id
        bytes32 purchaseId = keccak256(msg.sender, secondBuyer, productId, quantity, price, now);
        
        require(!purchases[purchaseId].exists);
        
        // register co-purchase
        purchases[purchaseId] = Purchase({dateCreation: now,
                                          dateExpiration: now + PURCHASE_DURATION,
                                          firstBuyer: msg.sender,
                                          secondBuyer: secondBuyer,
                                          productId: productId,
                                          quantity: quantity,
                                          paied: msg.value,
                                          toPay: price.sub(msg.value),
                                          state: PurchaseState.New,
                                          exists: true});
        
        // log event
        PurchaseRegistered(purchaseId, msg.sender, secondBuyer, price.sub(msg.value));
    }
    
    function cancelPurchase(bytes32 purchaseId) public purchaseExists(purchaseId) {
        require(purchases[purchaseId].firstBuyer == msg.sender);
        require(purchases[purchaseId].state == PurchaseState.New);
        require(purchases[purchaseId].dateExpiration < now);
        
        bytes32 productId = purchases[purchaseId].productId;
        
        // revert product quantity
        products[productId].quantity = 
                products[productId].quantity.add(purchases[purchaseId].quantity);
        
        // update address payments before the transfer
        payments[purchases[purchaseId].firstBuyer] = 
                payments[purchases[purchaseId].firstBuyer].sub(purchases[purchaseId].paied);
        
        // revert payment of the address registered purchase
        purchases[purchaseId].firstBuyer.transfer(purchases[purchaseId].paied);
        
        // update purchase state
        purchases[purchaseId].state = PurchaseState.Cancelled;
        
        // log event
        PurchaseCancelled(purchaseId);
    }
    
    function finishPurchase(bytes32 purchaseId) public purchaseExists(purchaseId) {
        require(purchases[purchaseId].secondBuyer == msg.sender);
        require(purchases[purchaseId].state == PurchaseState.New);
        require(purchases[purchaseId].dateExpiration > now);
        
        // update payments for the address registered purchase
        payments[purchases[purchaseId].firstBuyer] = 
                payments[purchases[purchaseId].firstBuyer].sub(purchases[purchaseId].paied);
        
         // update purchase state
        purchases[purchaseId].state = PurchaseState.Completed;
        
        // log event
        PurchaseCompleted(purchaseId);
    }
    
}