pragma solidity 0.4.19;

import "./SafeMath.sol";

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
