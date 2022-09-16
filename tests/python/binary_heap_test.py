import os
import pytest

from starkware.starknet.testing.starknet import Starknet

# The path to the contract source code.
CONTRACT_FILE = os.path.join(
    os.path.dirname(__file__), "..", "cairo/test_binary_heap.cairo")

@pytest.mark.asyncio
async def test_create_root():
    # Create the local Starknet network
    starknet = await Starknet.empty()

    # Deploy the contract
    contract = await starknet.deploy(CONTRACT_FILE)

    await contract.test_create_heap().call()
    await contract.test_insert_to_heap().call()
    await contract.test_extract_max().call()
    
