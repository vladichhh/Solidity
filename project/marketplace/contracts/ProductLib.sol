pragma solidity 0.4.19;

import "./SafeMath.sol";

library ProductLib {
    
    using SafeMath for uint;
    
    struct Product {
        string name;
        uint price;
        uint quantity;
        bool exists;
    }
    
    function createProduct(string _name, uint _price, uint _quantity) internal pure returns (Product) {
        return Product({name: _name, price: _price, quantity: _quantity, exists: true});
    }
    
    function updateProduct(Product storage self, uint _quantity) internal {
        self.quantity = _quantity;
    }
    
    function calculatePrice(Product storage self, uint _quantity) internal view returns (uint) {
        return self.price.mul(_quantity);
    }
    
    function buyProduct(Product storage self, uint _quantity) internal view returns (bool) {
        self.quantity.sub(_quantity);
    }
    
}
