const express = require('express');
const Web3 = require('web3');
const ethers = require('ethers');

const app = express();
app.use(express.json());

const web3 = new Web3('https://mainnet.infura.io/v3/YOUR_INFURA_PROJECT_ID');

app.post('/verify', async (req, res) => {
    const { address, signature, message } = req.body;

    try {
        const signerAddr = ethers.utils.verifyMessage(message, signature);
        if (signerAddr !== address) throw new Error("Invalid signature.");

        const balance = await web3.eth.getBalance(address);
        res.json({ balance: web3.utils.fromWei(balance, 'ether') });
    } catch (err) {
        res.status(400).json({ error: err.message });
    }
});

app.listen(3000, () => console.log('Server started on port 3000'));