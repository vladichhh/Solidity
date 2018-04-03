const Marketplace = artifacts.require("Marketplace");

contract('Marketplace [unit tests]', async (accounts) => {
	
	let instance;
	let productId = "0x78c526e417603a7d506203ad658e0c3617aa7b9bf15946300d5ac1354fe5ab4b";

	beforeEach('setup contract for each test', async function () {
		instance = await Marketplace.new(accounts[0]);
	});
	
	// ============================================================================================
	// ==========================================   GET   =========================================
	// ============================================================================================
	
	it("should block non-owner to retrieve contract balance", async () => {
		try {
			await instance.getBalance.call({from: accounts[1]});
			assert(false, "Only owner has permissions to call getBalance()");
		} catch (error) {}
	});
	
	it("should check is the initial contract balance 0", async () => {
		let balance = await instance.getBalance.call({from: accounts[0]});
		assert.equal(balance.toNumber(), 0, "The initial contract balance is not 0");
	});
	
	it("should contain no products initially", async () => {
		let productIds = await instance.getProducts.call({from: accounts[0]});
		assert.equal(productIds, 0, "There should not be any products initially");
	});
	
	it("should add 3 new products and get product count correctly", async () => {
		await instance.newProduct("apple", "1", "100", {from: accounts[0]});
		await instance.newProduct("orange", "2", "20", {from: accounts[0]});
		await instance.newProduct("banana", "1", "50", {from: accounts[0]});
		let productIds = await instance.getProducts.call({from: accounts[0]});
		assert.equal(productIds.length, 3, "There should not be any products initially");
	});
	
	it("should fail trying to get product with non existing id", async () => {
		try {
			let productIds = await instance.getProduct.call("0x123456789", {from: accounts[0]});
			assert(false, "Product lookup should fail for a non existing id");
		} catch (error) {}
	});
	
	it("should get price for a specified quantity of a certain product", async () => {
		try {
			await instance.getPrice.call("0x123456789", 15, {from: accounts[0]});
			assert(false, "Should fail trying to get price for a quantity of non existing product");
		} catch (error) {}
	});
	
	it("should get price for a specified quantity of a certain product", async () => {
		await instance.newProduct("apple", "1", "100", {from: accounts[0]});
		let details = await instance.getProduct.call(productId, {from: accounts[0]});
		let price = await instance.getPrice.call(productId, 15, {from: accounts[0]});
		let expectedPrice = details[1].toNumber() * 15;
		assert.equal(price.toNumber(), expectedPrice, "Product quantity has not been updated");
	});
	
	// ============================================================================================
	// ==========================================   ADD   =========================================
	// ============================================================================================
	
	it("should block non-owner to add a new product", async () => {
		try {
			await instance.newProduct("apple", "1", "100", {from: accounts[1]});
			assert(false, "Only contract owner has permissions to add new products");
		} catch (error) {}
	});
	
	it("should not allow to add product with empty/zero price", async () => {
		try {
			await instance.newProduct("apple", "0", "100", {from: accounts[1]});
			assert(false, "Product should not be added - price value is not valid");
		} catch (error) {}
	});
	
	it("should add new product successfully", async () => {
		let result = await instance.newProduct("apple", "1", "100", {from: accounts[0]});
		let details = await instance.getProduct.call(productId, {from: accounts[0]});
		assert.equal("apple", details[0], "Name of the added product is not matching");
		assert.equal(web3.toWei(1), details[1], "Price of the added product price is not matching");
		assert.equal("100", details[2], "Quantity of the added product is not matching");
		
		// checks for event ProductAdded
		assert.equal(result.logs[0].event, "ProductAdded", "There is no ProductAdded event");
	});
	
	// ============================================================================================
	// ========================================   UPDATE   ========================================
	// ============================================================================================
	
	it("should block non-owner to update a product", async () => {
		await instance.newProduct("apple", "1", "100", {from: accounts[0]});
		try {
			await instance.updateProduct(productId, 150, {from: accounts[1]});
			assert(false, "Only contract owner has permissions to update products");
		} catch (error) {}
	});
	
	it("should fail to update a non existing product", async () => {
		try {
			await instance.updateProduct("0x123456789", 150, {from: accounts[0]});
			assert(false, "Should fail trying to update non existing products");
		} catch (error) {}
	});
	
	it("should update specified product successfully", async () => {
		await instance.newProduct("apple", "1", "100", {from: accounts[0]});
		let details = await instance.getProduct.call(productId, {from: accounts[0]});
		let result = await instance.update(productId, 150, {from: accounts[0]});
		let newDetails = await instance.getProduct.call(productId, {from: accounts[0]});
		assert.equal(newDetails[2].toNumber(), 150, "Product quantity has not been updated");
		
		// checks for event ProductUpdated
		assert.equal(result.logs[0].event, "ProductUpdated", "There is no ProductUpdated event");
	});
	
	// ============================================================================================
	// ==========================================   BUY   =========================================
	// ============================================================================================
	
	it("should prevent purchasing a non existing product", async () => {
		try {
			await instance.buy("0x123456789", 10, {from: accounts[1], value: web3.toWei('10', 'ether')});
			assert(false, "Should fail trying to buy non existing product");
		} catch (error) {}
	});
	
	it("should prevent product purchase without any money", async () => {
		await instance.newProduct("apple", "1", "100", {from: accounts[0]});
		try {
			await instance.buy(productId, 10, {from: accounts[1], value: web3.toWei('0', 'ether')});
			assert(false, "Should fail trying to buy a product without any money");
		} catch (error) {}
	});
	
	it("should prevent product purchase without enough money", async () => {
		await instance.newProduct("apple", "1", "100", {from: accounts[0]});
		try {
			await instance.buy(productId, 10, {from: accounts[1], value: web3.toWei('5', 'ether')});
			assert(false, "Should fail trying to buy a product without enough money");
		} catch (error) {}
	});
	
	it("should prevent to buy 0 quantity from a certain product", async () => {
		await instance.newProduct("apple", "1", "10", {from: accounts[0]});
		try {
			await instance.buy(productId, 0, {from: accounts[1], value: web3.toWei('10', 'ether')});
			assert(false, "Should fail trying to buy 0 quantity from a product");
		} catch (error) {}
	});
	
	it("should prevent product purchase without enough quantity", async () => {
		await instance.newProduct("apple", "1", "10", {from: accounts[0]});
		try {
			await instance.buy(productId, 20, {from: accounts[1], value: web3.toWei('20', 'ether')});
			assert(false, "Should fail trying to buy a product without enough quantity");
		} catch (error) {}
	});
	
	it("should process a sample product purchase", async () => {
		await instance.newProduct("apple", "1", "100", {from: accounts[0]});
		let details = await instance.getProduct.call(productId, {from: accounts[0]});
		let result = await instance.buy(productId, 10, {from: accounts[1], value: web3.toWei('10', 'ether')});
		let newDetails = await instance.getProduct.call(productId, {from: accounts[0]});
		let newQuantity = newDetails[2];
		assert.equal(details[2].toNumber() - 10, newDetails[2].toNumber(), "Quantity not updated correctly");
		
		// checks for event ProductPurchased
		assert.equal(result.logs[0].event, "ProductPurchased", "There is no ProductPurchased event");
	});
	
	// ============================================================================================
	// =======================================   WITHDRAW   =======================================
	// ============================================================================================
	
	it("should block non-owner to make a withdrawal", async () => {
		try {
			await instance.withdraw({from: accounts[1]});
			assert(false, "Only contract owner has permissions to make a withdrawals");
		} catch (error) {}
	});
	
	it("should prevent the withdrawal if contract balance is 0", async () => {
		try {
			await instance.withdraw({from: accounts[0]});
			assert(false, "Withdrawal should not be allowed in case of empty balance");
		} catch (error) {}
	});
	
	it("should process a withdraw successfully", async () => {
		await instance.newProduct("apple", "1", "100", {from: accounts[0]});
		await instance.buy(productId, 10, {from: accounts[1], value: web3.toWei('10', 'ether')});
		let result = await instance.withdraw({from: accounts[0]});
		let contract = await instance.address;
		let balance = web3.eth.getBalance(contract);
		assert.equal(balance, 0, "Contract balance should be 0 after withdrawal");
		
		// checks for event Withdrawal
		assert.equal(result.logs[0].event, "Withdrawal", "There is no Withdrawal event");
	});
	
});
