%lang starknet

from starkware.cairo.common.dict_access import DictAccess
from starkware.cairo.common.cairo_builtins import HashBuiltin
from starkware.cairo.common.dict import (
    dict_write, dict_read, dict_update, dict_squash
)

from contracts.cairo.sl_list import (
    sl_node_create, sl_list_create, sl_list_push
)

@external
func test_sl_list{
    syscall_ptr : felt*,
    pedersen_ptr : HashBuiltin*,
    range_check_ptr
} () {
    alloc_locals;

    // Create an empty singly linked list
    let (sl_list, list_len) = sl_list_create();
    let (head) = dict_read{dict_ptr=sl_list}(key=0);
    let (tail) = dict_read{dict_ptr=sl_list}(key=1);
    let (length) = dict_read{dict_ptr=sl_list}(key=2);

    assert head = -1;
    assert tail = -1;
    assert length = 0;
    // assert cast(head, felt) = -1;

    // Create a new node
    let (node) = sl_node_create(1);
    let (val) = dict_read{dict_ptr=node}(key=0);
    let (next) = dict_read{dict_ptr=node}(key=1);
    assert val = 1;
    assert next = -1;

    // Insert node to list
    sl_list_push{sl_list=sl_list}(3);
    let (head_loc) = dict_read{dict_ptr=sl_list}(key=0);
    let head_dict = cast(head_loc, DictAccess*);
    let (retrieved_val) = dict_read{dict_ptr=head_dict}(key=0);
    assert retrieved_val = 3;

    return ();
}

