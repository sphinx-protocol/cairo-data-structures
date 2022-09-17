%lang starknet

from starkware.cairo.common.dict_access import DictAccess
from starkware.cairo.common.default_dict import (
    default_dict_new, default_dict_finalize
)
from starkware.cairo.common.dict import (
    dict_write, dict_read, dict_update, dict_squash
)
from starkware.cairo.common.alloc import alloc
from starkware.cairo.common.math import unsigned_div_rem
from starkware.cairo.common.math_cmp import is_le


// Create an empty binary heap.
// @dev : Empty dict entries are initialised at -1.
// @return heap : Pointer to empty dictionary containing heap
// @return heap_len : Length of heap
func heap_create{range_check_ptr} () -> (
        heap : DictAccess*,
        heap_len : felt
    ) {
    alloc_locals;

    let (local heap) = default_dict_new(default_value=-1);
    default_dict_finalize(
        dict_accesses_start=heap,
        dict_accesses_end=heap,
        default_value=0);

    return (heap, 0);
}

// Insert new value to max heap.
// @dev : Heap must be passed as an implicit argument
// @param heap_len : Length of heap
// @param val : New value to insert into heap
// @return new_len : New length of heap
func max_heap_insert{
        range_check_ptr,
        heap : DictAccess*, 
    } (heap_len : felt, val : felt) -> (new_len : felt) {
    alloc_locals;

    dict_write{dict_ptr=heap}(key=heap_len, new_value=val);
    max_heap_bubble_up(idx=heap_len);
    return (new_len=heap_len + 1);
}

// Recursively find correct position of new value within max heap.
// @dev : Heap must be passed as an implicit argument
// @param idx : Node of tree being checked in current run of function
func max_heap_bubble_up{
        range_check_ptr,
        heap : DictAccess*
    } (idx : felt) {
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

    max_heap_bubble_up(idx=parent_idx);

    return ();
}

// Delete root value from max heap.
// @dev : Heap must be passed as an implicit argument
// @dev : tempvars used to handle revoked references for implicit args
// @param heap_len : Length of heap
// @return root : Root value deleted from tree
func max_heap_extract{
        range_check_ptr,
        heap : DictAccess*
    } (heap_len : felt) -> (root : felt) {
    alloc_locals; 

    let (root) = dict_read{dict_ptr=heap}(key=0);
    let (end) = dict_read{dict_ptr=heap}(key=heap_len-1);
    dict_update{dict_ptr=heap}(key=heap_len-1, prev_value=end, new_value=-1);

    let heap_len_pos = is_le(2, heap_len);
    if (heap_len_pos == 1) {
        dict_update{dict_ptr=heap}(key=0, prev_value=root, new_value=end);
        max_heap_sink_down(idx=0);
        tempvar range_check_ptr=range_check_ptr;
        tempvar heap=heap;
    } else {
        tempvar range_check_ptr=range_check_ptr;
        tempvar heap=heap;
    }

    return (root=root);
}

// Recursively find correct position of new root value within max heap.
// @dev : Heap must be passed as an implicit argument
// @dev : tempvars used to handle revoked references for implicit args
// @param idx : Node of tree being checked in current run of function
func max_heap_sink_down{
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
                max_heap_sink_down(right_idx);
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
                max_heap_sink_down(left_idx);
                tempvar range_check_ptr=range_check_ptr;
                tempvar heap=heap;
            } else {
                tempvar range_check_ptr=range_check_ptr;
                tempvar heap=heap;
            }
        } else {
            if (right_larger == 1) {
                swap(idx, right_idx);
                max_heap_sink_down(right_idx);
                tempvar range_check_ptr=range_check_ptr;
                tempvar heap=heap;
            } else {
                swap(idx, left_idx);
                max_heap_sink_down(left_idx);
                tempvar range_check_ptr=range_check_ptr;
                tempvar heap=heap;
            }
        }
    }
    return ();
}

// Swap dictionary entries at two indices.
// @dev : Heap must be passed as an implicit argument
// @param idx_a : Index of first dictionary entry to be swapped
// @param idx_b : Index of second dictionary entry to be swapped
func swap{heap : DictAccess*} (idx_a : felt, idx_b : felt) {
    let (elem_a) = dict_read{dict_ptr=heap}(key=idx_a);
    let (elem_b) = dict_read{dict_ptr=heap}(key=idx_b);
    dict_update{dict_ptr=heap}(key=idx_a, prev_value=elem_a, new_value=elem_b);
    dict_update{dict_ptr=heap}(key=idx_b, prev_value=elem_b, new_value=elem_a);
    return ();
}

// Squash heap dictionary and assert correctness of write logs.
// @dev : Heap must be passed as an implicit argument
// @param heap_start : Pointer to start of heap dictionary object
// @param heap_len : Length of heap
// @param squashed_dict : Pointer to squashed heap dictionary
func heap_squash{
        range_check_ptr,
        heap : DictAccess*, 
    } (heap_start : DictAccess*, heap_len : felt) -> (
        squashed_dict : DictAccess* 
    ) {
    let (_, squashed_dict) = dict_squash(heap_start, heap);
    return (squashed_dict=squashed_dict);
}