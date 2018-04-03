const Destructible = artifacts.require("Destructible");

contract('Destructible [unit tests]', async (accounts) => {
	
	let instance
	let contract;

	beforeEach('setup contract for each test', async function () {
		instance = await Destructible.new({from: accounts[0], value: web3.toWei('10', 'ether')});
		contract = instance.address;
	});
	
	it('should create the contract with initial balance of 10 ethers', async function () {
		let initContractBalance = web3.eth.getBalance(contract);
		assert.equal(web3.fromWei(initContractBalance.toNumber(), "ether"), 10, "Initial contract balance is not 10 ethers");
	});
	
	it('should block an attempt non-owner to call destroy()', async function () {
		let success = false;		
		try {
			await instance.destroy({from: accounts[1]});
			assert(false, 'Only contract owner has a permission to call destroy()');
		} catch (error) {}
	});
	
	it('should block an attempt non-owner to call destroyAndSend()', async function () {		
		try {
			await instance.destroyAndSend({from: accounts[1]});
			assert(false, 'Only contract owner has a permission to call destroyAndSend()');
		} catch (error) {}
	});
	
	it('should destroy the contract and send contract balance to the owner', async function () {
		let initOwnerBalance = web3.eth.getBalance(accounts[0]);
		await instance.destroy({from: accounts[0]});
		let newOwnerBalance = web3.eth.getBalance(accounts[0]);
		let newContractBalance = web3.eth.getBalance(contract);
		assert.isAbove(newOwnerBalance.toNumber(), initOwnerBalance.toNumber(), "Owner balance not increased after destruction");
		assert.equal(newContractBalance.toNumber(), 0, "Contract balance is not empty after destruction");
	});
	
	it('should destroy the contract and send contract balance to the specified recipient', async function () {
		let initRecipientBalance = web3.eth.getBalance(accounts[1]);
		await instance.destroyAndSend(accounts[1], {from: accounts[0]});
		let newRecipientBalance = web3.eth.getBalance(accounts[1]);
		let newContractBalance = web3.eth.getBalance(contract);
		assert.isAbove(newRecipientBalance.toNumber(), initRecipientBalance.toNumber(), "Recipient balance not increased after destruction");
		assert.equal(newContractBalance.toNumber(), 0, "Contract balance is not empty after destruction");
	});
	
});
