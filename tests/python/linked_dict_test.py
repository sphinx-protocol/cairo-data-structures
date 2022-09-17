import os
import pytest

from starkware.starknet.testing.starknet import Starknet

# The path to the contract source code.
CONTRACT_FILE = os.path.join(
    os.path.dirname(__file__), "..", "cairo/test_linked_dict.cairo")

@pytest.mark.asyncio
async def test_create_root():
    # Create the local Starknet network
    starknet = await Starknet.empty()

    # Deploy the contract
    contract = await starknet.deploy(CONTRACT_FILE)

    await contract.test_linked_dict().call()
    
