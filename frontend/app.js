// Initialize web3.js
let web3;
if (window.ethereum) {
    web3 = new Web3(window.ethereum);
    try {
        // Request account access if needed
        window.ethereum.enable();
    } catch (error) {
        // User denied account access
        console.error("User denied account access");
    }
} else if (window.web3) {
    // Legacy dapp browsers
    web3 = new Web3(web3.currentProvider);
} else {
    // Non-dapp browsers
    console.error("Non-Ethereum browser detected. You should consider trying MetaMask!");
}

// Set the contract address and ABI
const contractAddress = "CONTRACT_ADDRESS"; // Replace with your contract address
const contractABI = ""; // Replace with your contract ABI

const etherEscrowContract = new web3.eth.Contract(contractABI, contractAddress);

async function depositEther() {
    const amount = document.getElementById("amount").value;
    const payee = document.getElementById("payee").value;
    const password = document.getElementById("password").value;

    try {
        const accounts = await web3.eth.getAccounts();
        const payer = accounts[0];

        // Convert the amount to Wei (1 Ether = 1e18 Wei)
        const amountInWei = web3.utils.toWei(amount, "ether");

        // Call the depositEther function in the contract
        await etherEscrowContract.methods
            .depositEther(payee, password, true, false)
            .send({ from: payer, value: amountInWei });

        document.getElementById("status").innerHTML = `Successfully deposited ${amount} Ether to the escrow contract.`;
    } catch (error) {
        document.getElementById("status").innerHTML = "Error: " + error.message;
    }
}
