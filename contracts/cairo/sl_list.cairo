%lang starknet

from starkware.cairo.common.dict_access import DictAccess
from starkware.cairo.common.default_dict import (
    default_dict_new, default_dict_finalize
)
from starkware.cairo.common.dict import (
    dict_write, dict_read, dict_update, dict_squash
)

// Create a new empty linked list.
// Singly Linked List : DictAccess*
//   [0] head : cast(DictAccess*, felt)
//   [1] tail : cast(DictAccess*, felt)
//   [2] length : felt
func sl_list_create{range_check_ptr} () -> (
        sl_list : DictAccess*,
        list_len : felt
    ) {
    alloc_locals;

    let (local sl_list) = default_dict_new(default_value=-1);
    default_dict_finalize(
        dict_accesses_start=sl_list,
        dict_accesses_end=sl_list,
        default_value=-1);
    
    dict_write{dict_ptr=sl_list}(key=0, new_value=-1);
    dict_write{dict_ptr=sl_list}(key=1, new_value=-1);
    dict_write{dict_ptr=sl_list}(key=2, new_value=0);

    return (sl_list=sl_list, list_len=0);
}

// Create a new node for a singly linked list.
// Node : DictAccess*
//   [0] val : felt
//   [1] next : cast(DictAccess*, felt)
func sl_node_create{range_check_ptr} (val : felt) -> (node : DictAccess*) {
    alloc_locals;

    let (local node) = default_dict_new(default_value=-1);
    default_dict_finalize(
        dict_accesses_start=node,
        dict_accesses_end=node,
        default_value=-1);
    
    dict_write{dict_ptr=node}(key=0, new_value=val);
    dict_write{dict_ptr=node}(key=1, new_value=-1);

    return (node=node);
}

// Insert item at the end of a singly linked list.
func sl_list_push{range_check_ptr, sl_list : DictAccess*}(val : felt) {
    alloc_locals;

    let (new_node) = sl_node_create(val);
    // let (head) = dict_read{dict_ptr=sl_list}(key=0);
    // let (tail) = dict_read{dict_ptr=sl_list}(key=1);
    let (length) = dict_read{dict_ptr=sl_list}(key=2);

    if (length == 0) {
        dict_update{dict_ptr=sl_list}(key=0, prev_value=-1, new_value=cast(new_node, felt));
        dict_update{dict_ptr=sl_list}(key=1, prev_value=-1, new_value=cast(new_node, felt));
        tempvar sl_list=sl_list;
    } else {
        tempvar sl_list=sl_list;
    }

    return ();
}