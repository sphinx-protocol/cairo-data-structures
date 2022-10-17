%lang starknet

from starkware.cairo.common.cairo_builtins import HashBuiltin
from src.binary_heap import (
    heap, heap_length, heap_insert, heap_extract_max
)

@external
func test_heap{
    syscall_ptr : felt*,
    pedersen_ptr : HashBuiltin*,
    range_check_ptr
} () {
    alloc_locals;

    heap_insert(3);
    heap_insert(10);
    heap_insert(6);
    heap_insert(4);
    heap_insert(5);
    heap_insert(11);
    heap_insert(2);

    let (heap_0) = heap.read(0);
    assert heap_0 = 11;
    let (heap_1) = heap.read(1);
    assert heap_1 = 5;
    let (heap_2) = heap.read(2);
    assert heap_2 = 10;
    let (heap_3) = heap.read(3);
    assert heap_3 = 3;
    let (heap_4) = heap.read(4);
    assert heap_4 = 4;
    let (heap_5) = heap.read(5);
    assert heap_5 = 6;
    let (heap_6) = heap.read(6);
    assert heap_6 = 2;

    let (extract_1) = heap_extract_max();
    assert extract_1 = 11;

    let (new_heap_0) = heap.read(0);
    assert new_heap_0 = 10;
    let (new_heap_2) = heap.read(2);
    assert new_heap_2 = 6;
    let (new_heap_5) = heap.read(5);
    assert new_heap_5 = 2;

    return ();
}