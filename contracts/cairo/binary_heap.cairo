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
    // All keys will be set to value of -1.
    let (local heap) = default_dict_new(default_value=-1);
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
        heap : DictAccess*
    } (heap_len : felt, idx : felt) {
    alloc_locals;

    if (idx == 0) {
        return ();
    }
    
    let (parent_idx, _) = unsigned_div_rem(idx - 1, 2);
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

// Delete root value from tree
func extract_max{
        range_check_ptr,
        heap : DictAccess*
    } (heap_len : felt) -> felt {
    alloc_locals; 

    let (root) = dict_read{dict_ptr=heap}(key=0);
    let (end) = dict_read{dict_ptr=heap}(key=heap_len-1);
    dict_update{dict_ptr=heap}(key=heap_len-1, prev_value=end, new_value=-1);

    let heap_len_pos = is_le(2, heap_len);
    if (heap_len_pos == 1) {
        dict_update{dict_ptr=heap}(key=0, prev_value=root, new_value=end);
        sink_down(idx=0);
        tempvar range_check_ptr=range_check_ptr;
        tempvar heap=heap;
    } else {
        tempvar range_check_ptr=range_check_ptr;
        tempvar heap=heap;
    }

    return (root);
}

// Find correct position of newly inserted root
func sink_down{
        range_check_ptr,
        heap : DictAccess*
    } (idx : felt) {
    alloc_locals;

    let (node) = dict_read{dict_ptr=heap}(key=idx);
    local left_idx = 2 * idx + 1;
    local right_idx = 2 * idx + 2;
    let (left) = dict_read{dict_ptr=heap}(key=left_idx);
    let (right) = dict_read{dict_ptr=heap}(key=right_idx);

    let left_exists = is_le(1, left); 
    let right_exists = is_le(1, right);
    let less_than_left = is_le(node, left);
    let less_than_right = is_le(node, right);
    let right_larger = is_le(left, right - 1);

    if (left_exists == 0) {
        if (right_exists == 1) {
            if (less_than_right == 1) {
                swap(idx, right_idx);
                sink_down(right_idx);
                tempvar range_check_ptr=range_check_ptr;
                tempvar heap=heap;
            } else {
                tempvar range_check_ptr=range_check_ptr;
                tempvar heap=heap;
            }
        } else {
            tempvar range_check_ptr=range_check_ptr;
            tempvar heap=heap;
        }
    } else {
        if (right_exists == 0) {
            if (less_than_left == 1) {
                swap(idx, left_idx);
                sink_down(left_idx);
                tempvar range_check_ptr=range_check_ptr;
                tempvar heap=heap;
            } else {
                tempvar range_check_ptr=range_check_ptr;
                tempvar heap=heap;
            }
        } else {
            if (right_larger == 1) {
                swap(idx, right_idx);
                sink_down(right_idx);
                tempvar range_check_ptr=range_check_ptr;
                tempvar heap=heap;
            } else {
                swap(idx, left_idx);
                sink_down(left_idx);
                tempvar range_check_ptr=range_check_ptr;
                tempvar heap=heap;
            }
        }
    }
    return ();
}

// Swap dict entries at two indices
func swap{heap : DictAccess*} (idx_a : felt, idx_b : felt) {
    let (elem_a) = dict_read{dict_ptr=heap}(key=idx_a);
    let (elem_b) = dict_read{dict_ptr=heap}(key=idx_b);
    dict_update{dict_ptr=heap}(key=idx_a, prev_value=elem_a, new_value=elem_b);
    dict_update{dict_ptr=heap}(key=idx_b, prev_value=elem_b, new_value=elem_a);
    return ();
}

// TODO - Squash dict to array and return pointer to it
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