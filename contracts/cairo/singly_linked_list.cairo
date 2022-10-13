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
        sl_list : DictAccess*
    ) {
    alloc_locals;

    let (local sl_list) = default_dict_new(default_value=-1);
    
    dict_write{dict_ptr=sl_list}(key=0, new_value=-1);
    dict_write{dict_ptr=sl_list}(key=1, new_value=-1);
    dict_write{dict_ptr=sl_list}(key=2, new_value=0);

    return (sl_list=sl_list);
}

// Create a new node for a singly linked list.
// Node : DictAccess*
//   [0] val : felt
//   [1] next : cast(DictAccess*, felt)
func sl_node_create{range_check_ptr} (val : felt) -> (
        sl_node : DictAccess*
    ) {
    alloc_locals;

    let (local sl_node) = default_dict_new(default_value=-1);
    
    dict_write{dict_ptr=sl_node}(key=0, new_value=val);
    dict_write{dict_ptr=sl_node}(key=1, new_value=-1);

    return (sl_node=sl_node);
}

// Insert item at the end of a singly linked list.
func sl_list_push{range_check_ptr, sl_list : DictAccess*}(val : felt) -> () {
    alloc_locals;

    let (new_node) = sl_node_create(val);
    let (length) = dict_read{dict_ptr=sl_list}(key=2);

    if (length == 0) {
        dict_update{dict_ptr=sl_list}(key=0, prev_value=-1, new_value=cast(new_node, felt));
        dict_update{dict_ptr=sl_list}(key=1, prev_value=-1, new_value=cast(new_node, felt));

        tempvar sl_list=sl_list;
    } else {
        let (tail_loc) = dict_read{dict_ptr=sl_list}(key=1);
        let tail_dict = cast(tail_loc, DictAccess*);
        let (tail_next) = dict_read{dict_ptr=tail_dict}(key=1);
        dict_update{dict_ptr=tail_dict}(key=1, prev_value=tail_next, new_value=cast(new_node, felt));
        
        if (length == 1) {
            dict_update{dict_ptr=sl_list}(key=0, prev_value=tail_loc, new_value=cast(tail_dict, felt));
            tempvar sl_list=sl_list;
        } else {
            tempvar sl_list=sl_list;
        }

        dict_update{dict_ptr=sl_list}(key=1, prev_value=tail_loc, new_value=cast(new_node, felt));
        
        tempvar sl_list=sl_list;
    }

    dict_update{dict_ptr=sl_list}(key=2, prev_value=length, new_value=length+1);

    return ();
}

// Remove item from the end of the singly linked list.
func sl_list_pop{range_check_ptr, sl_list : DictAccess*}() -> (del : DictAccess*) {
    alloc_locals;
    
    let (length) = dict_read{dict_ptr=sl_list}(key=2);
    
    if (length == 0) {
        let (empty_node) = sl_node_create(-1);
        return (empty_node);
    }

    let (curr_loc) = dict_read{dict_ptr=sl_list}(key=0);
    let curr_dict : DictAccess*  = cast(curr_loc, DictAccess*);
    find_second_last_elem{curr_dict=curr_dict, prev_dict=curr_dict}();

}

func find_second_last_elem{
        range_check_ptr, 
        curr_dict : DictAccess*, 
        prev_dict : DictAccess*, 
    } () -> () {
    alloc_locals;
    
    let (next_loc) = dict_read{dict_ptr=sl_list}(key=1);
    let (next_loc) = dict_read{dict_ptr=sl_list}(key=1);
    if (next == -1) {

    }

    return find_second_last_elem(next
}
