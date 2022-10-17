%lang starknet

from starkware.cairo.common.cairo_builtins import HashBuiltin
from src.queue import (
    queue, queue_head, queue_tail, queue_len, queue_enqueue, queue_dequeue
)

@external
func test_queue{
    syscall_ptr : felt*,
    pedersen_ptr : HashBuiltin*,
    range_check_ptr
} () {
    alloc_locals;

    let (len_1) = queue_enqueue(3);
    assert len_1 = 1;
    let (len_2) = queue_enqueue(4);
    assert len_2 = 2;
    let (len_3) = queue_enqueue(5);
    assert len_3 = 3;
    let (len_4) = queue_enqueue(6);
    assert len_4 = 4;

    let (del_1) = queue_dequeue();
    assert del_1.val = 3;
    let (del_2) = queue_dequeue();
    assert del_2.val = 4;
    let (del_3) = queue_dequeue();
    assert del_3.val = 5;
    let (del_4) = queue_dequeue();
    assert del_4.val = 6;
    
    return ();
}

