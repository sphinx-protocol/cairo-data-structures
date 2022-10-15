%lang starknet

from starkware.cairo.common.dict_access import DictAccess
from starkware.cairo.common.cairo_builtins import HashBuiltin
from starkware.cairo.common.dict import dict_read

from contracts.cairo.bid_order_book import (
    bob_insert, bob_extract, bid_order_book
)

@external
func test_bid_order_book{
    syscall_ptr : felt*,
    pedersen_ptr : HashBuiltin*,
    range_check_ptr
} () {
    alloc_locals;

    // Insert values to heap
    bob_insert(order_price=78, order_dt=9952, order_id=3693265); 
    bob_insert(order_price=95, order_dt=9956, order_id=19075640); 
    bob_insert(order_price=95, order_dt=8000, order_id=466); 
    bob_insert(order_price=48, order_dt=8870, order_id=9544525); 
    bob_insert(order_price=96, order_dt=9955, order_id=98374127); 
    bob_insert(order_price=96, order_dt=9952, order_id=7547619); 
    bob_insert(order_price=48, order_dt=8278, order_id=35533); 
    bob_insert(order_price=48, order_dt=8870, order_id=25011021); 

    // Test insertion has been done correctly
    let (elem1) = bid_order_book.read(idx=0);
    assert elem1.price = 96;
    assert elem1.dt = 9952;
    let (elem2) = bid_order_book.read(idx=1);
    assert elem2.price = 95;
    assert elem2.dt = 8000;
    let (elem3) = bid_order_book.read(idx=2);
    assert elem3.price = 96;
    assert elem3.dt = 9955;
    let (elem4) = bid_order_book.read(idx=3);
    assert elem4.price = 48;
    let (elem5) = bid_order_book.read(idx=4);
    assert elem5.price = 78;
    let (elem6) = bid_order_book.read(idx=5);
    assert elem6.price = 95;
    let (elem7) = bid_order_book.read(idx=6);
    assert elem7.price = 48;
    let (elem8) = bid_order_book.read(idx=7);
    assert elem8.price = 48;

    // Delete root value
    let (root_price, root_dt, root_id) = bob_extract();

    // Check sink down executed correctly
    assert root_price = 96;
    assert root_dt = 9952;
    assert root_id = 7547619;

    let (updated_elem1) = bid_order_book.read(idx=0);
    assert updated_elem1.price = 96;
    assert updated_elem1.dt = 9955;
    let (updated_elem3) = bid_order_book.read(idx=2);
    assert updated_elem3.price = 95;
    assert updated_elem3.dt = 9956;
    let (updated_elem6) = bid_order_book.read(idx=5);
    assert updated_elem6.price = 48;
    assert updated_elem6.dt = 8870;

    return ();
}