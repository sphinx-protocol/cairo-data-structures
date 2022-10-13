%lang starknet

from starkware.cairo.common.dict_access import DictAccess
from starkware.cairo.common.cairo_builtins import HashBuiltin
from starkware.cairo.common.dict import (
    dict_write, dict_read, dict_update, dict_squash
)

from contracts.cairo.singly_linked_list import (
    sl_node_create, sl_list_create, sl_list_push
)

@external
func test_singly_linked_list{
    syscall_ptr : felt*,
    pedersen_ptr : HashBuiltin*,
    range_check_ptr
} () {
    alloc_locals;

    // Create an empty singly linked list
    let (sl_list) = sl_list_create();

    let (head) = dict_read{dict_ptr=sl_list}(key=0);
    let (tail) = dict_read{dict_ptr=sl_list}(key=1);
    let (length) = dict_read{dict_ptr=sl_list}(key=2);

    assert head = -1;
    assert tail = -1;
    assert length = 0;

    // Create a new node
    let (node) = sl_node_create(1);
    let (val) = dict_read{dict_ptr=node}(key=0);
    let (next) = dict_read{dict_ptr=node}(key=1);
    assert val = 1;
    assert next = -1;

    // Insert node to list
    sl_list_push{sl_list=sl_list}(3);
    sl_list_push{sl_list=sl_list}(4);
    sl_list_push{sl_list=sl_list}(5);
    sl_list_push{sl_list=sl_list}(6);
    
    // Read nodes
    // TO SOLVE: note every time you read a node it increases its location by 3
    let (head_loc) = dict_read{dict_ptr=sl_list}(key=0);
    let head_dict : DictAccess*  = cast(head_loc, DictAccess*);
    let (head_val) = dict_read{dict_ptr=head_dict}(key=0);
    assert head_val = 3;
    
    let (second_loc) = dict_read{dict_ptr=head_dict}(key=1);
    let second_dict : DictAccess* = cast(second_loc + 6, DictAccess*);
    let (second_val) = dict_read{dict_ptr=second_dict}(key=0);
    assert second_val = 4;
    
    let (third_loc) = dict_read{dict_ptr=second_dict}(key=1);
    let third_dict : DictAccess* = cast(third_loc + 6, DictAccess*);
    let (third_val) = dict_read{dict_ptr=third_dict}(key=0);
    assert third_val = 5;

    let (tail_loc) = dict_read{dict_ptr=sl_list}(key=1);
    let tail_dict = cast(tail_loc, DictAccess*);
    let (tail_val) = dict_read{dict_ptr=tail_dict}(key=0);
    assert tail_val = 6;

    return ();
}

