from web3 import Web3
import asyncio

nodeURL = "https://divine-purple-meme.ethereum-sepolia.quiknode.pro/d16e5f08e165557d51cee73bd8ff9dfe1412a8ee/"

# Connect to the Ethereum node
w3 = Web3(Web3.HTTPProvider(nodeURL))

# Define the contract address and ABI
contract_address = "0x52fE3B326648b37537fC7D0b13517a1051F38773"
contract_abi = '[{"anonymous":false,"inputs":[{"indexed":false,"internalType":"uint256","name":"date","type":"uint256"},{"indexed":false,"internalType":"string","name":"fielsd","type":"string"},{"indexed":false,"internalType":"string","name":"name","type":"string"},{"indexed":false,"internalType":"address","name":"owner","type":"address"},{"indexed":false,"internalType":"string","name":"requestType","type":"string"}],"name":"addData","type":"event"},{"inputs":[],"name":"emitevent","outputs":[],"stateMutability":"nonpayable","type":"function"},{"inputs":[],"name":"emitMultiple","outputs":[],"stateMutability":"nonpayable","type":"function"},{"inputs":[],"name":"emitSingle","outputs":[],"stateMutability":"nonpayable","type":"function"},{"anonymous":false,"inputs":[{"indexed":false,"internalType":"string","name":"a","type":"string"},{"indexed":false,"internalType":"int256","name":"b","type":"int256"},{"indexed":false,"internalType":"address","name":"c","type":"address"}],"name":"pokrenuto","type":"event"}]'
# Create a contract object
contract = w3.eth.contract(address=contract_address, abi=contract_abi)

# Define the event filter
event_filter = contract.events.addData.create_filter(fromBlock='latest')

conn = http.client.HTTPConnection("178.79.181.117:80")


async def add_data_to_database(event):

    # parse event
    args = event['args']

    date = args['date']
    fiels = args['field']
    blocName = args['name']
    ownerName = args['owner']
    requestType = args['requestType']

    # upload data to database
    payload = f'''
    {{
      "Datum_i_vrijeme": "{date}",
      "Ime": "{ownerName}",
      "fielsd": {{"key": "{fiels}"}},
      "Ime_osobe_koja_unosi_podatke": "{ownerName}",
      "vsrta_unosa": "{requestType}"
    }}
    '''
    headers = {
        'Content-Type': "application/json",
    }

    conn.request("POST", "/api/collections/bloc/records", payload, headers)

    res = conn.getresponse()
    data = res.read()

    print(data.decode("utf-8"))


async def log_loop(event_filter, poll_interval):
    while True:
        for event in event_filter.get_new_entries():
            await add_data_to_database(event)
        await asyncio.sleep(poll_interval)

# Run the event listener
loop = asyncio.get_event_loop()
loop.run_until_complete(asyncio.gather(log_loop(event_filter, 2)))
loop.close()
