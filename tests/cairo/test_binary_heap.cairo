%lang starknet

from starkware.cairo.common.cairo_builtins import HashBuiltin

from contracts.cairo.binary_heap import (
    create_heap, insert_to_heap,
)
from starkware.cairo.common.dict import dict_read


@external
func test_create_heap{
    syscall_ptr : felt*,
    pedersen_ptr : HashBuiltin*,
    range_check_ptr,
} () -> () {
    alloc_locals;
    let (heap, heap_len) = create_heap();
    return ();
}

@external
func test_insert_to_heap{
    syscall_ptr : felt*,
    pedersen_ptr : HashBuiltin*,
    range_check_ptr,
}() -> () {
    alloc_locals;
    let (heap, heap_len) = create_heap();
    let heap_len_1 = insert_to_heap{heap=heap}(heap_len=heap_len, val=3);
    let heap_len_2 = insert_to_heap{heap=heap}(heap_len=heap_len_1, val=4);
    let heap_len_3 = insert_to_heap{heap=heap}(heap_len=heap_len_2, val=7);
    let (elem1) = dict_read{dict_ptr=heap}(key=0);
    assert elem1 = 7;
    let (elem2) = dict_read{dict_ptr=heap}(key=1);
    assert elem2 = 4;
    let (elem3) = dict_read{dict_ptr=heap}(key=2);
    assert elem3 = 3;
    return ();
}