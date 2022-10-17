%lang starknet

from starkware.cairo.common.cairo_builtins import HashBuiltin
from src.singly_linked_list import (
    sl_list, sl_list_head, sl_list_tail, sl_list_push, sl_list_pop, sl_list_shift, sl_list_unshift, sl_list_get, sl_list_set, sl_list_insert, sl_list_remove
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

    let (success) = sl_list_set(2, 1);
    let (node) = sl_list_get(head_id, 2);
    assert node.val = 1;
    let (insert_success_1) = sl_list_insert(2, 5);
    assert insert_success_1 = 1;
    let (insert_success_2) = sl_list_insert(5, 5);
    assert insert_success_2 = 0;

    let (pop_1) = sl_list_pop();
    let (tail_1_loc) = sl_list_tail.read();
    let (tail_1) = sl_list.read(tail_1_loc);
    assert tail_1.val = 1;
    let (pop_2) = sl_list_pop();
    let (tail_2_loc) = sl_list_tail.read();
    let (tail_2) = sl_list.read(tail_2_loc);
    assert tail_2.val = 5;
    let (removed) = sl_list_remove(1);
    let (tail_3_loc) = sl_list_tail.read();
    let (tail_3) = sl_list.read(tail_3_loc);
    assert tail_3.val = 5;
    let (shift_1) = sl_list_shift();
    let (tail_4_loc) = sl_list_tail.read();
    let (tail_4) = sl_list.read(tail_4_loc);
    assert tail_4.val = 5;
    let (shift_2) = sl_list_shift();

    assert pop_1.val = 6;
    assert pop_2.val = 1;
    assert removed.val = 4;
    assert shift_1.val = 3;
    assert shift_2.val = 5;

    let (new_head_id) = sl_list_head.read();
    let (new_tail_id) = sl_list_tail.read();
    assert new_head_id = -1;
    assert new_tail_id = -1;
    
    return ();
}

