%lang starknet

from starkware.cairo.common.cairo_builtins import HashBuiltin
from src.priority_queue import (
    pq, pq_length, pq_enqueue, pq_dequeue
)

@external
func test_priority_queue{
    syscall_ptr : felt*,
    pedersen_ptr : HashBuiltin*,
    range_check_ptr
} () {
    alloc_locals;

    pq_enqueue(99, 3);
    pq_enqueue(68, 10);
    pq_enqueue(27, 6);
    pq_enqueue(2, 4);
    pq_enqueue(3, 5);
    pq_enqueue(4, 11);
    pq_enqueue(1, 2);

    let (pq_0) = pq.read(0);
    assert pq_0.p = 11;
    let (pq_1) = pq.read(1);
    assert pq_1.p = 5;
    let (pq_2) = pq.read(2);
    assert pq_2.p = 10;
    let (pq_3) = pq.read(3);
    assert pq_3.p = 3;
    let (pq_4) = pq.read(4);
    assert pq_4.p = 4;
    let (pq_5) = pq.read(5);
    assert pq_5.p = 6;
    let (pq_6) = pq.read(6);
    assert pq_6.p = 2;

    let (extract_1) = pq_dequeue();
    assert extract_1.p = 11;

    let (new_pq_0) = pq.read(0);
    assert new_pq_0.p = 10;
    let (new_pq_2) = pq.read(2);
    assert new_pq_2.p = 6;
    let (new_pq_5) = pq.read(5);
    assert new_pq_5.p = 2;

    return ();
}