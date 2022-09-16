%lang starknet

from starkware.cairo.common.dict_access import DictAccess
from starkware.cairo.common.default_dict import (
    default_dict_new, default_dict_finalize
)
from starkware.cairo.common.dict import (
    dict_write, dict_read, dict_update
)
from starkware.cairo.common.alloc import alloc
from starkware.cairo.common.math import unsigned_div_rem
from starkware.cairo.common.math_cmp import is_le


// Create an empty heap.
func create_heap{range_check_ptr} () -> (
        heap : DictAccess*,
        heap_len : felt
    ) {
    alloc_locals;
    // Create an empty dictionary and finalise it.
    // All keys will be set to value of 0.
    let (local heap) = default_dict_new(default_value=0);
    default_dict_finalize(
        dict_accesses_start=heap,
        dict_accesses_end=heap,
        default_value=0);

    return (heap, 0);
}

// Insert a value to the heap
func insert_to_heap{
        range_check_ptr,
        heap : DictAccess*, 
        heap_len : felt
    } (val : res) {
    alloc_locals;

    dict_write{dict_ptr=heap}(keys=heap_len, new_value=val)
    bubble_up(idx=heap_len - 1)
    return()
}

// Find correct position of new value within heap
func bubble_up{
        range_check_ptr,
        heap : DictAccess*, 
        heap_len : felt
    } (idx : felt) {
    alloc_locals;

    if (idx == 0) {
        return ();
    }
    
    let (parent_idx, _) = unsigned_div_rem(idx, 2);
    let (elem) = dict_read{dict_ptr=heap}(key=idx)
    let (parent_elem) = dict_read{dict_ptr=heap}(key=parent_idx)

    if (is_le(elem, parent_elem) == 1) {
        return ()
    }

    dict_write{dict_ptr=heap}(keys=idx, new_value=parent_elem)
    dict_write{dict_ptr=heap}(keys=parent_idx, new_value=elem)

    bubble_up(idx=parent_idx)

    return ()
}

// Squash dict to array and return pointer to it
func read_dict