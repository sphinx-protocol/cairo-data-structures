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
    } (heap_len : felt, val : felt) -> felt {
    alloc_locals;

    dict_write{dict_ptr=heap}(key=heap_len, new_value=val);
    bubble_up(heap_len=heap_len, idx=heap_len);
    return (heap_len + 1);
}

// Find correct position of new value within heap
func bubble_up{
        range_check_ptr,
        heap : DictAccess*, 
    } (heap_len : felt, idx : felt) {
    alloc_locals;

    if (idx == 0) {
        return ();
    }
    
    let (parent_idx, _) = unsigned_div_rem(idx, 2);
    let (elem) = dict_read{dict_ptr=heap}(key=idx);
    let (parent_elem) = dict_read{dict_ptr=heap}(key=parent_idx);

    local less_than = is_le(elem, parent_elem);
    if (less_than == 1) {
        return ();
    }

    dict_update{dict_ptr=heap}(key=idx, prev_value=elem, new_value=parent_elem);
    dict_update{dict_ptr=heap}(key=parent_idx, prev_value=parent_elem, new_value=elem);

    bubble_up(heap_len=heap_len, idx=parent_idx);

    return ();
}

// Squash dict to array and return pointer to it
// func squash_heap{
//         range_check_ptr,
//         heap : DictAccess*, 
//         heap_len : felt
//     } (idx : felt) -> DictAccess* {
//     alloc_locals;

//     let dict_end = dict_start + (heap_len - 1) * DictAccess.SIZE;
    
//     let (local squashed_dict_start: DictAccess*) = alloc();
//     let (squashed_dict_end) = squash_dict(
//         heap, 
//         dict_end, 
//         squashed_dict_start
//     );

//     return (squashed_dict_start, );
// }