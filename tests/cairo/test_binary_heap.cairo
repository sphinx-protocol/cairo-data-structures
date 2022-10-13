%lang starknet

from starkware.cairo.common.dict_access import DictAccess
from starkware.cairo.common.cairo_builtins import HashBuiltin
from starkware.cairo.common.dict import dict_read

from contracts.cairo.binary_heap import (
    heap_create, max_heap_insert, max_heap_extract
)

@storage_var
func heap_store(idx : felt) -> (val: felt) {
}

@external
func test_heap{
    syscall_ptr : felt*,
    pedersen_ptr : HashBuiltin*,
    range_check_ptr
} () {
    alloc_locals;
    // Create heap
    let (heap, heap_len) = heap_create();
    let heap_start = heap;

    // Insert values to heap
    max_heap_insert{heap=heap}(heap_len=0, val=3);
    max_heap_insert{heap=heap}(heap_len=1, val=4);
    max_heap_insert{heap=heap}(heap_len=2, val=7);
    let (elem1) = dict_read{dict_ptr=heap}(key=0);
    assert elem1 = 7;
    let (elem2) = dict_read{dict_ptr=heap}(key=1);
    assert elem2 = 3;
    let (elem3) = dict_read{dict_ptr=heap}(key=2);
    assert elem3 = 4;
    let (elem4) = dict_read{dict_ptr=heap}(key=3);
    assert elem4 = -1;

    // Extract max
    max_heap_extract{heap=heap}(heap_len=3);
    let (elem1_updated) = dict_read{dict_ptr=heap}(key=0);
    assert elem1_updated = 4;
    let (elem2_updated) = dict_read{dict_ptr=heap}(key=1);
    assert elem2_updated = 3;
    let (elem3_updated) = dict_read{dict_ptr=heap}(key=2);
    assert elem3_updated = -1;

    // Write heap to storage
    write_heap{heap=heap}(heap_len=3);

    // Read heap from storage
    let (val1) = heap_store.read(0);
    let (val2) = heap_store.read(1);
    let (val3) = heap_store.read(2);
    assert val1 = 4;
    assert val2 = 3;
    assert val3 = -1;

    return ();
}

func write_heap{
    syscall_ptr : felt*,
    pedersen_ptr : HashBuiltin*,
    range_check_ptr,
    heap : DictAccess*
} (heap_len : felt) {
    if (heap_len == 0) {
        return ();
    }

    let (val) = dict_read{dict_ptr=heap}(key=heap_len - 1);
    heap_store.write(heap_len - 1, val);
    write_heap(heap_len - 1);

    return ();
}