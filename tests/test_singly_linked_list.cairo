%lang starknet

from starkware.cairo.common.cairo_builtins import HashBuiltin
from src.singly_linked_list import (
    sl_list, sl_list_head, sl_list_tail, sl_node_create, sl_list_push, sl_list_pop, sl_list_shift, sl_list_unshift, sl_list_get
)

@external
func test_singly_linked_list{
    syscall_ptr : felt*,
    pedersen_ptr : HashBuiltin*,
    range_check_ptr
} () {
    alloc_locals;

    sl_list_push(5);
    sl_list_push(6);
    sl_list_unshift(4);
    sl_list_unshift(3);

    // Read nodes
    let (head_id) = sl_list_head.read();
    let (elem_1) = sl_list.read(head_id);
    assert elem_1.val = 3;
    let (elem_2) = sl_list.read(elem_1.next_id);
    assert elem_2.val = 4;
    let (elem_3) = sl_list.read(elem_2.next_id);
    assert elem_3.val = 5;
    let (elem_4) = sl_list.read(elem_3.next_id);
    assert elem_4.val = 6;

    let (val) = sl_list_get(head_id, 2);
    assert val = 5;

    let (pop_1) = sl_list_pop();
    let (tail_1_loc) = sl_list_tail.read();
    let (tail_1) = sl_list.read(tail_1_loc);
    assert tail_1.val = 5;
    let (pop_2) = sl_list_pop();
    let (tail_2_loc) = sl_list_tail.read();
    let (tail_2) = sl_list.read(tail_2_loc);
    assert tail_2.val = 4;
    let (shift_1) = sl_list_shift();
    let (tail_3_loc) = sl_list_tail.read();
    let (tail_3) = sl_list.read(tail_3_loc);
    assert tail_3.val = 4;
    let (shift_2) = sl_list_shift();

    assert pop_1.val = 6;
    assert pop_2.val = 5;
    assert shift_1.val = 3;
    assert shift_2.val = 4;

    let (new_head_id) = sl_list_head.read();
    let (new_tail_id) = sl_list_tail.read();
    assert new_head_id = -1;
    assert new_tail_id = -1;
    
    return ();
}

