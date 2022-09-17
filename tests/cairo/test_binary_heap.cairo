%lang starknet

from starkware.cairo.common.cairo_builtins import HashBuiltin

from contracts.cairo.binary_heap import (
    create_heap, insert_to_heap, extract_max, squash_heap
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
    let (heap, heap_len) = create_heap();
    let heap_start = heap;

    // Insert values to heap
    insert_to_heap{heap=heap}(heap_len=0, val=3);
    insert_to_heap{heap=heap}(heap_len=1, val=4);
    insert_to_heap{heap=heap}(heap_len=2, val=7);
    let (elem1) = dict_read{dict_ptr=heap}(key=0);
    assert elem1 = 7;
    let (elem2) = dict_read{dict_ptr=heap}(key=1);
    assert elem2 = 3;
    let (elem3) = dict_read{dict_ptr=heap}(key=2);
    assert elem3 = 4;
    let (elem4) = dict_read{dict_ptr=heap}(key=3);
    assert elem4 = -1;

    // Extract max
    extract_max{heap=heap}(heap_len=3);
    let (elem1_updated) = dict_read{dict_ptr=heap}(key=0);
    assert elem1_updated = 4;
    let (elem2_updated) = dict_read{dict_ptr=heap}(key=1);
    assert elem2_updated = 3;
    let (elem3_updated) = dict_read{dict_ptr=heap}(key=2);
    assert elem3_updated = -1;

    // Squash heap
    let (squashed_dict_start, squashed_dict_end) = squash_heap{heap=heap}(heap_start, 2);
    let (squash_1) = dict_read{dict_ptr=squashed_dict_end}(key=0);
    assert squash_1 = 4;
    let (squash_2) = dict_read{dict_ptr=squashed_dict_end}(key=1);
    assert squash_2 = 3;
    let (squash_3) = dict_read{dict_ptr=squashed_dict_end}(key=2);
    assert squash_3 = -1;

    return ();
}

