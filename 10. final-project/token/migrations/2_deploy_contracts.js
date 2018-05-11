var VHToken = artifacts.require("./VHToken.sol");

module.exports = function(deployer) {
  deployer.deploy(VHToken);
};
