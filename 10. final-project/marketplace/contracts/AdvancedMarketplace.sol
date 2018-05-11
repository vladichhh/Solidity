pragma solidity 0.4.19;

import "./ExtendedMarketplace.sol";

contract AdvancedMarketplace is ExtendedMarketplace {
    
    // ERC20TokenRateOracle public oracle;
    
    mapping(address => bool) public supportedTokens;
    
    modifier tokenSupported(address ERC20TokenAddr) {
        require(supportedTokens[ERC20TokenAddr]);
        _;
    }
    
    function addSupportedToken(address ERC20TokenAddr) public {
        supportedTokens[ERC20TokenAddr] = true;
    }

    function buyWithTokens(bytes32 productId, uint256 quantity, address ERC20TokenAddr) public
        productExists(productId) hasQuantity(productId, quantity) tokenSupported(ERC20TokenAddr) {
        
        // StandardToken ERC20Token = StandardToken(ERC20TokenAddr);
        
        // calculate the amount required to buy the requested quantity
        uint256 price = getPrice(productId, quantity);
        
        // get token rate
        // uint256 rate = oracle.getTokenRate(ERC20TokenAddr);
        
        // uint256 nTokens = price.div(rate);
        
        // withdraw tokens
        // ERC20Token.transferFrom(msg.sender, address(0), nTokens);
        
        // using ProductLib
        products[productId].buyProduct(quantity);
        
        // log event
        ProductPurchased(productId, msg.sender, quantity, price);
    }
    
}
