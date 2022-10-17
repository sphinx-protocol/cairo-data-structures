%lang starknet

from starkware.cairo.common.cairo_builtins import HashBuiltin
from src.doubly_linked_list import (
    dl_list, dl_list_head, dl_list_tail, dl_list_push, dl_list_pop, dl_list_shift, dl_list_unshift, dl_list_get, dl_list_set, dl_list_insert, dl_list_remove, curr_item_id, Node
)

@external
func test_doubly_linked_list{
    syscall_ptr : felt*,
    pedersen_ptr : HashBuiltin*,
    range_check_ptr
} () {
    alloc_locals;

    // Constructor
    curr_item_id.write(1);
    tempvar empty_node: Node* = new Node(id=-1, val=-1, next_id=-1, prev_id=-1);
    dl_list.write(-1, [empty_node]);

    dl_list_push(5);
    dl_list_push(6);
    dl_list_unshift(4);
    dl_list_unshift(3);

    // Read nodes
    let (head_id) = dl_list_head.read();
    let (elem_1) = dl_list.read(head_id);
    assert elem_1.val = 3;
    let (elem_2) = dl_list.read(elem_1.next_id);
    assert elem_2.val = 4;
    let (elem_3) = dl_list.read(elem_2.next_id);
    assert elem_3.val = 5;
    let (elem_4) = dl_list.read(elem_3.next_id);
    assert elem_4.val = 6;

    let (success) = dl_list_set(2, 1);
    let (node) = dl_list_get(2);
    assert node.val = 1;
    let (insert_success_1) = dl_list_insert(2, 5); 
    assert insert_success_1 = 1;
    let (insert_success_2) = dl_list_insert(5, 5);
    assert insert_success_2 = 0;

    let (pop_1) = dl_list_pop();
    let (tail_1_loc) = dl_list_tail.read();
    let (tail_1) = dl_list.read(tail_1_loc);
    assert tail_1.val = 1;
    let (pop_2) = dl_list_pop();
    let (tail_2_loc) = dl_list_tail.read();
    let (tail_2) = dl_list.read(tail_2_loc);
    assert tail_2.val = 5;
    let (removed) = dl_list_remove(1);
    let (tail_3_loc) = dl_list_tail.read();
    let (tail_3) = dl_list.read(tail_3_loc);
    assert tail_3.val = 5;
    let (shift_1) = dl_list_shift();
    let (tail_4_loc) = dl_list_tail.read();
    let (tail_4) = dl_list.read(tail_4_loc);
    assert tail_4.val = 5;
    let (shift_2) = dl_list_shift();

    assert pop_1.val = 6;
    assert pop_2.val = 1;
    assert removed.val = 4;
    assert shift_1.val = 3;
    assert shift_2.val = 5;

    let (new_head_id) = dl_list_head.read();
    let (new_tail_id) = dl_list_tail.read();
    assert new_head_id = -1;
    assert new_tail_id = -1;
    
    return ();
}

