from web3 import Web3
import asyncio

nodeURL = "https://divine-purple-meme.ethereum-sepolia.quiknode.pro/d16e5f08e165557d51cee73bd8ff9dfe1412a8ee/"

# Connect to the Ethereum node
w3 = Web3(Web3.HTTPProvider(nodeURL))

# Define the contract address and ABI
contract_address = "0x056FD16941FAF2076D86E0d94400ac68F996d58d"
contract_abi = '[{"inputs":[],"name":"emitevent","outputs":[],"stateMutability":"nonpayable","type":"function"},{"anonymous":false,"inputs":[{"indexed":false,"internalType":"string","name":"a","type":"string"},{"indexed":false,"internalType":"int256","name":"b","type":"int256"},{"indexed":false,"internalType":"address","name":"c","type":"address"}],"name":"pokrenuto","type":"event"}]'
# Create a contract object
contract = w3.eth.contract(address=contract_address, abi=contract_abi)

# Define the event filter
event_filter = contract.events.pokrenuto.create_filter(fromBlock='latest')

# Define the async function to listen for events


async def log_loop(event_filter, poll_interval):
    while True:
        for event in event_filter.get_new_entries():
            print(event)
        await asyncio.sleep(poll_interval)

# Run the event listener
loop = asyncio.get_event_loop()
loop.run_until_complete(asyncio.gather(log_loop(event_filter, 2)))
loop.close()
