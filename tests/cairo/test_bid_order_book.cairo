%lang starknet

from starkware.cairo.common.dict_access import DictAccess
from starkware.cairo.common.cairo_builtins import HashBuiltin
from starkware.cairo.common.dict import dict_read

from contracts.cairo.bid_order_book import (
    bob_create, bob_insert, bob_extract
)

@external
func test_bid_order_book{
    syscall_ptr : felt*,
    pedersen_ptr : HashBuiltin*,
    range_check_ptr
} () {
    alloc_locals;
    // Create heap
    let (bob_prices, bob_dts, bob_ids, bob_len) = bob_create();

    // Insert values to heap
    bob_insert{bob_prices=bob_prices, bob_dts=bob_dts, bob_ids=bob_ids, bob_len=bob_len}(
        order_price=95, order_dt=9945, order_id=13229139012309
    );
    bob_insert{bob_prices=bob_prices, bob_dts=bob_dts, bob_ids=bob_ids, bob_len=bob_len}(
        order_price=97, order_dt=10045, order_id=81237812478735
    );
    bob_insert{bob_prices=bob_prices, bob_dts=bob_dts, bob_ids=bob_ids, bob_len=bob_len}(
        order_price=78, order_dt=10068, order_id=45734123896432
    );
    bob_insert{bob_prices=bob_prices, bob_dts=bob_dts, bob_ids=bob_ids, bob_len=bob_len}(
        order_price=95, order_dt=8800, order_id=19659623957723
    );

    let (root_price, root_dt, root_id) = bob_extract{bob_prices=bob_prices, bob_dts=bob_dts, bob_ids=bob_ids, bob_len=bob_len}();

    assert root_price = 97;
    assert root_dt = 10045;
    assert root_id = 81237812478735;

    let (elem1_price) = dict_read{dict_ptr=bob_prices}(key=0);
    assert elem1_price = 95;
    let (elem2_price) = dict_read{dict_ptr=bob_prices}(key=1);
    assert elem2_price = 95;
    let (elem3_price) = dict_read{dict_ptr=bob_prices}(key=2);
    assert elem3_price = 78;

    let (elem1_dt) = dict_read{dict_ptr=bob_dts}(key=0);
    assert elem1_dt = 8800;
    let (elem2_dt) = dict_read{dict_ptr=bob_dts}(key=1);
    assert elem2_dt = 9945;
    let (elem3_dt) = dict_read{dict_ptr=bob_dts}(key=2);
    assert elem3_dt = 10068;

    return ();
}