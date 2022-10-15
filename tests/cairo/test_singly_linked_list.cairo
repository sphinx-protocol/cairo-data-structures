%lang starknet

from starkware.cairo.common.cairo_builtins import HashBuiltin
from contracts.cairo.singly_linked_list import (
    sl_node_create, sl_list_push, sl_list_pop, sl_list, sl_list_head
)

@external
func test_singly_linked_list{
    syscall_ptr : felt*,
    pedersen_ptr : HashBuiltin*,
    range_check_ptr
} () {
    alloc_locals;

    sl_list_push(3);
    sl_list_push(4);
    sl_list_push(5);
    sl_list_push(6);
    
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
    
    return ();
}

