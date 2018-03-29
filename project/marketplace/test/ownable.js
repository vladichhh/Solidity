const Ownable = artifacts.require("Ownable");

contract('Ownable [unit tests]', async (accounts) => {
	
	let instance;
	let owner;

	beforeEach('setup contract for each test', async function () {
		instance = await Ownable.new({from: accounts[0]});
		owner = await instance.owner.call();
	});
	
	it("should check if the contract has an owner", async () => {
		assert.notEqual(owner, 0, "The contract does not have an owner");
	});
		
	it("should check is the contract owner the same as contract creator", async () => {
		assert.equal(owner, accounts[0], "The contract owner does not match the creator of the contract");
	});
	
	it('should block an attempt non-owner to call transferOwnership()', async function () {
		try {
			await instance.transferOwnership({from: accounts[1]});
			assert(false, 'Only contract owner has a permission to call transferOwnership()');
		} catch (error) {}
	});
	
	it('should prevent from transferring the contract ownership to an empty account', async function () {
		try {
			await instance.transferOwnership(null, {from: accounts[0]});
			assert(false, "Contract ownership transferred to an empty account");
		} catch (error) {}
	});
	
	it('should transfer the contract ownership to a specified account successfully', async function () {
		let result = await instance.transferOwnership(accounts[1], {from: accounts[0]});
		let newOwner = await instance.owner.call();
		assert.equal(accounts[1], newOwner, "Contract ownership transferred to unexpected account");
		
		// checks for event OwnershipTransferred
		assert.equal(result.logs[0].event, "OwnershipTransferred", "There is no OwnershipTransferred event");
	});
	
});
