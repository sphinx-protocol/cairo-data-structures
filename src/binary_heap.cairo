%lang starknet

from starkware.cairo.common.cairo_builtins import HashBuiltin
from starkware.cairo.common.alloc import alloc
from starkware.cairo.common.math import unsigned_div_rem
from starkware.cairo.common.math_cmp import is_le

// Stores values in binary heap.
@storage_var
func heap(idx : felt) -> (val : felt) {
}

// Stores length of binary heap.
@storage_var
func heap_length() -> (res : felt) {
}

// Insert new value to binary heap.
// @param val : New value to be inserted to heap
func heap_insert{
    syscall_ptr: felt*,
    pedersen_ptr: HashBuiltin*,
    range_check_ptr,
} (val : felt) {
    alloc_locals;

    let (len) = heap_length.read();
    heap.write(len, val);
    heap_bubble_up(idx=len);   
    heap_length.write(len+1);

    return ();
}

// Recursively find correct position of new value within heap.
// @param idx : Node of heap being checked in current run of function
func heap_bubble_up{
    syscall_ptr: felt*,
    pedersen_ptr: HashBuiltin*,
    range_check_ptr,
} (idx : felt) {
    alloc_locals;

    if (idx == 0) {
        return ();
    }
    
    let (parent_idx, _) = unsigned_div_rem(idx - 1, 2);
    let (val) = heap.read(idx=idx);
    let (parent_val) = heap.read(idx=parent_idx);

    local less_than_or_equals = is_le(val, parent_val);
    if (less_than_or_equals == 1) {
        return ();
    }
    heap_swap(idx, parent_idx);
    heap_bubble_up(idx=parent_idx);
    handle_revoked_refs();

    return ();
}

// Delete root value from binary heap.
// @return old_root : Root value deleted from heap
func heap_extract_max{
    syscall_ptr: felt*,
    pedersen_ptr: HashBuiltin*,
    range_check_ptr,
} () -> (old_root : felt) {
    alloc_locals; 

    let (len) = heap_length.read();
    let (root) = heap.read(0);
    let (last) = heap.read(len - 1);
    heap.write(len - 1, 0);
    heap_length.write(len - 1);

    let heap_len_pos = is_le(1, len - 1);
    if (heap_len_pos == 1) {
        heap.write(0, last);
        heap_sink_down(idx=0);
        handle_revoked_refs();
    } else {
        handle_revoked_refs();
    }

    return (old_root=root);
}

// Recursively find correct position of new root value within heap.
// @param idx : Node of heap being checked in current run of function
func heap_sink_down{
    syscall_ptr: felt*,
    pedersen_ptr: HashBuiltin*,
    range_check_ptr,
} (idx : felt) {
    alloc_locals;

    local left_idx = 2 * idx + 1;
    local right_idx = 2 * idx + 2;

    let (node) = heap.read(idx);
    let (left) = heap.read(left_idx);
    let (right) = heap.read(right_idx);

    let left_exists = is_le(1, left); 
    let right_exists = is_le(1, right);
    let less_than_left = is_le(node, left);
    let less_than_right = is_le(node, right);
    let right_larger = is_le(left, right - 1);

    if (left_exists == 0) {
        if (right_exists == 1) {
            if (less_than_right == 1) {
                heap_swap(idx, right_idx);
                heap_sink_down(right_idx);
                handle_revoked_refs();
            } else {
                handle_revoked_refs();
            }
        } else {
            handle_revoked_refs();
        }
    } else {
        if (right_exists == 0) {
            if (less_than_left == 1) {
                heap_swap(idx, left_idx);
                heap_sink_down(left_idx);
                handle_revoked_refs();
            } else {
                handle_revoked_refs();
            }
        } else {
            if (right_larger == 1) {
                heap_swap(idx, right_idx);
                heap_sink_down(right_idx);
                handle_revoked_refs();
            } else {
                heap_swap(idx, left_idx);
                heap_sink_down(left_idx);
                handle_revoked_refs();
            }
        }
    }
    return ();
}

// Utility function to swap locations of two values in heap.
// @param idx_a : Index of first value being swapped
// @param idx_b : Index of second value being swapped
func heap_swap{
    syscall_ptr: felt*,
    pedersen_ptr: HashBuiltin*,
    range_check_ptr,
} (idx_a : felt, idx_b : felt) {
    alloc_locals;

    let (val_a) = heap.read(idx_a);
    let (val_b) = heap.read(idx_b);
    heap.write(idx_a, val_b);
    heap.write(idx_b, val_a);

    return ();
}

// Utility function to handle revoked implicit references.
// @dev tempvars used to handle revoked implict references
func handle_revoked_refs{
    syscall_ptr: felt*,
    pedersen_ptr: HashBuiltin*,
    range_check_ptr,
} () {
    tempvar syscall_ptr=syscall_ptr;
    tempvar pedersen_ptr=pedersen_ptr;
    tempvar range_check_ptr=range_check_ptr;
    return ();
}