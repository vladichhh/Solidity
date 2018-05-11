pragma solidity 0.4.19;

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
        uint256 price;
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
