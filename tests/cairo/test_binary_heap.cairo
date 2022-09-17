%lang starknet

from starkware.cairo.common.cairo_builtins import HashBuiltin

from contracts.cairo.binary_heap import (
    heap_create, max_heap_insert, max_heap_extract, heap_squash
)
from starkware.cairo.common.dict import dict_read

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

    // Squash heap
    let (squashed_dict) = heap_squash{heap=heap}(heap_start, 2);
    let (squash_1) = dict_read{dict_ptr=squashed_dict}(key=0);
    assert squash_1 = 4;
    let (squash_2) = dict_read{dict_ptr=squashed_dict}(key=1);
    assert squash_2 = 3;
    let (squash_3) = dict_read{dict_ptr=squashed_dict}(key=2);
    assert squash_3 = -1;

    return ();
}

