pragma solidity 0.4.19;

// import "github.com/oraclize/ethereum-api/oraclizeAPI.sol";
/*
contract ERC20TokenRateOracle { // is usingOraclize {
    
    mapping(address => uint256) public rates;
    
    uint256 public ERC20ETH;
    
    function ERC20TokenRateOracle() public {
        update(0);
    }
    
    function __callback(bytes32 id, string result, bytes proof) public {
        // if (msg.sender != oraclize_cbAddress()) revert();
        // ERC20ETH = parseInt(result, 2);
    }
    
    function update(uint delay) payable public {
        if (oraclize_getPrice("URL") > this.balance) {
            NewOraclizeQuery("Oraclize query was NOT sent, please add some ETH to cover for the query fee");
        } else {
            oraclize_query(delay, "URL",
                "json(https://min-api.cryptocompare.com/data/price?fsym=EOS&tsyms=ETH).ETH");
        }
    }
    
    function getTokenRate(address ERC20TokenAddr) public returns (uint256) {
        return rates[ERC20TokenAddr];
    }
    
}
*/
