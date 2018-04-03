window.onload = function() {
	if (typeof web3 === 'undefined') {
		// if there is no web3 variable
		displayMessage("Error! Are you sure that you are using MetaMask browser extension ?");
	} else {
		displayMessage("Welcome to Marketplace DAPP!");
		init();
	}
}

var contractInstance;

var abi = [{"constant":false,"inputs":[{"name":"productId","type":"bytes32"},{"name":"quantity","type":"uint256"}],"name":"buy","outputs":[],"payable":true,"stateMutability":"payable","type":"function"},{"constant":true,"inputs":[],"name":"getBalance","outputs":[{"name":"","type":"uint256"}],"payable":false,"stateMutability":"view","type":"function"},{"constant":true,"inputs":[{"name":"productId","type":"bytes32"}],"name":"getProduct","outputs":[{"name":"name","type":"string"},{"name":"price","type":"uint256"},{"name":"quantity","type":"uint256"}],"payable":false,"stateMutability":"view","type":"function"},{"constant":false,"inputs":[],"name":"withdraw","outputs":[],"payable":false,"stateMutability":"nonpayable","type":"function"},{"constant":false,"inputs":[],"name":"destroy","outputs":[],"payable":false,"stateMutability":"nonpayable","type":"function"},{"constant":true,"inputs":[],"name":"owner","outputs":[{"name":"","type":"address"}],"payable":false,"stateMutability":"view","type":"function"},{"constant":false,"inputs":[{"name":"productId","type":"bytes32"},{"name":"newQuantity","type":"uint256"}],"name":"update","outputs":[],"payable":false,"stateMutability":"nonpayable","type":"function"},{"constant":true,"inputs":[],"name":"getProducts","outputs":[{"name":"","type":"bytes32[]"}],"payable":false,"stateMutability":"view","type":"function"},{"constant":true,"inputs":[{"name":"productId","type":"bytes32"},{"name":"quantity","type":"uint256"}],"name":"getPrice","outputs":[{"name":"","type":"uint256"}],"payable":false,"stateMutability":"view","type":"function"},{"constant":false,"inputs":[{"name":"name","type":"string"},{"name":"price","type":"uint256"},{"name":"quantity","type":"uint256"}],"name":"newProduct","outputs":[{"name":"","type":"bytes32"}],"payable":false,"stateMutability":"nonpayable","type":"function"},{"constant":false,"inputs":[{"name":"newOwner","type":"address"}],"name":"transferOwnership","outputs":[],"payable":false,"stateMutability":"nonpayable","type":"function"},{"constant":false,"inputs":[{"name":"recipient","type":"address"}],"name":"destroyAndSend","outputs":[],"payable":false,"stateMutability":"nonpayable","type":"function"},{"anonymous":false,"inputs":[{"indexed":true,"name":"productId","type":"bytes32"},{"indexed":false,"name":"name","type":"string"},{"indexed":false,"name":"price","type":"uint256"},{"indexed":false,"name":"quantity","type":"uint256"},{"indexed":false,"name":"timestamp","type":"uint256"}],"name":"ProductAdded","type":"event"},{"anonymous":false,"inputs":[{"indexed":true,"name":"productId","type":"bytes32"},{"indexed":false,"name":"price","type":"uint256"},{"indexed":false,"name":"quantity","type":"uint256"},{"indexed":false,"name":"timestamp","type":"uint256"}],"name":"ProductPurchased","type":"event"},{"anonymous":false,"inputs":[{"indexed":true,"name":"productId","type":"bytes32"},{"indexed":false,"name":"initQuantity","type":"uint256"},{"indexed":false,"name":"newQuantity","type":"uint256"},{"indexed":false,"name":"timestamp","type":"uint256"}],"name":"ProductUpdated","type":"event"},{"anonymous":false,"inputs":[{"indexed":false,"name":"amount","type":"uint256"},{"indexed":false,"name":"timestamp","type":"uint256"}],"name":"Withdrawal","type":"event"},{"anonymous":false,"inputs":[{"indexed":false,"name":"previousOwner","type":"address"},{"indexed":false,"name":"newOwner","type":"address"},{"indexed":false,"name":"timestamp","type":"uint256"}],"name":"OwnershipTransferred","type":"event"}]

var address = "0x8cdaf0cd259887258bc13a92c0a6da92698644c0";
var acc;

function init() {
	var Contract = web3.eth.contract(abi);
	contractInstance = Contract.at(address);
	updateAccount();
}

function updateAccount() {
	// In MetaMask, the accounts array is of size 1 and only contains the currently selected account.
	// The user can select a different account and so we need to update our account variable.
	acc = web3.eth.accounts[0];
}

function displayMessage(message) {
	var el = document.getElementById("message");
	el.innerHTML = message;
}

function displayProducts(productList) {
	var productArr = productList.toString().split(",");
	var output = "";

	for (var i=0; i<productArr.length; i++) {
		output = output.concat(productArr[i]) + "<br>";
	}

	var el = document.getElementById("products");
	el.innerHTML = output;s
}

function getTextInput1() {
	return document.getElementById("input1").value;
}

function getTextInput2() {
	return document.getElementById("input2").value;
}

function getTextInput3() {
	return document.getElementById("input3").value;
}


function onGetBalance() {
	updateAccount();
	onReset();

	contractInstance.getBalance.call({"from": acc}, function(err, res) {
		if (!err) {
			displayMessage("Contract balance");
			document.getElementById("input1").value = web3.fromWei(res, 'ether') + " ether(s)";
		} else {
			displayMessage("Something went wrong.");
			console.error(err);
		}
	});
}

function onAddProduct() {
	updateAccount();

	var input1 = getTextInput1();
	var input2 = getTextInput2();
	var input3 = getTextInput3();

	contractInstance.newProduct(input1, input2, input3, {"from": acc}, function(err, res) {
		if (!err) {
			displayMessage("Success! Transaction hash: " + res.valueOf());
		} else {
			displayMessage("Something went wrong.");
			console.error(err);
		}
	});
}

function onGetProduct() {
	updateAccount();

	var input = getTextInput1();
	var isProductId = input.startsWith("0x");

	if (isProductId) {
		contractInstance.getProduct.call(input, {"from": acc}, function(err, res) {
			if (!err) {
				document.getElementById("input1").value = res[0];
				document.getElementById("input2").value = web3.fromWei(res[1], 'ether') + " ether(s)";
				document.getElementById("input3").value = res[2];
				displayMessage("Product details");
			} else {
				displayMessage("Something went wrong.");
				console.error(err);
			}
		});
	} else {
		displayMessage("The input field does not contain a valid productId");
	}
}

function onGetAllProducts() {
	updateAccount();
	onReset();

	contractInstance.getProducts.call({"from": acc}, function(err, res) {
		if (!err) {
			displayProducts(res);
		} else {
			displayMessage("Something went wrong.");
			console.error(err);
		}
	});
}

function onGetPrice() {
	updateAccount();
	
	var input1 = getTextInput1();
	var input2 = getTextInput2();
	
	onReset();
	
	contractInstance.getPrice.call(input1, input2, {"from": acc}, function(err, res) {
		if (!err) {
			document.getElementById("input1").value = web3.fromWei(res, 'ether') + " ether(s)";
		} else {
			displayMessage("Something went wrong.");
			console.error(err);
		}
	});
}

function onBuyProduct() {
	updateAccount();

	var input1 = getTextInput1();
	var input2 = getTextInput2();
	var input3 = getTextInput3();
	
	onReset();

	contractInstance.buy(input1, input2, {"from": acc, value: web3.toWei(input3, 'ether')}, function(err, res) {
		if (!err) {
			displayMessage("Success! Transaction hash: " + res.valueOf());
		} else {
			displayMessage("Something went wrong.");
			console.error(err);
		}
	});
}

function onWithdraw() {
	updateAccount();
	onReset();
	
	contractInstance.withdraw({"from": acc}, function(err, res) {
		if (!err) {
			displayMessage("Success! Transaction hash: " + res.valueOf());
		} else {
			displayMessage("Something went wrong.");
			console.error(err);
		}
	});

}

function onReset() {
	displayMessage("Welcome to Marketplace DAPP!");

	document.getElementById("input1").value = "";
	document.getElementById("input2").value = "";
	document.getElementById("input3").value = "";
	document.getElementById("products").innerHTML = "";
}