pragma solidity 0.4.19;

import "./Marketplace.sol";
import "./AbstractExtendedMarketplace.sol";

contract ExtendedMarketplace is Marketplace, AbstractExtendedMarketplace {
    
    uint256 public constant PURCHASE_DURATION = 1 days;
    
    mapping(bytes32 => Purchase) purchases;
    mapping(address => uint256) balances;
    
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
        
        // added payment to the address balance
        balances[msg.sender] = balances[msg.sender].add(msg.value);
        
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
                                          price: price,
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
        
        // update address balance before the transfer
        balances[purchases[purchaseId].firstBuyer] = 
                balances[purchases[purchaseId].firstBuyer].sub(purchases[purchaseId].paied);
        
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
        
        // update balance of the address registered purchase
        balances[purchases[purchaseId].firstBuyer] = 
                balances[purchases[purchaseId].firstBuyer].sub(purchases[purchaseId].paied);
        
         // update purchase state
        purchases[purchaseId].state = PurchaseState.Completed;
        
        // log event
        PurchaseCompleted(purchaseId);
    }
    
}
