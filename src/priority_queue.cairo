%lang starknet

from starkware.cairo.common.cairo_builtins import HashBuiltin
from starkware.cairo.common.alloc import alloc
from starkware.cairo.common.math import unsigned_div_rem
from starkware.cairo.common.math_cmp import is_le

struct Node {
    id : felt,
    val : felt,
    p : felt,
}

// Stores values in priority queue.
@storage_var
func pq(idx : felt) -> (node : Node) {
}

// Stores length of priority queue.
@storage_var
func pq_length() -> (res : felt) {
}

// Stores latest item id.
@storage_var
func curr_item_id() -> (id : felt) {
}

@constructor
func constructor{
    syscall_ptr: felt*,
    pedersen_ptr: HashBuiltin*,
    range_check_ptr,
} () {
    curr_item_id.write(1);
    return ();
}

// Create new node for priority queue.
// @param val : new value
// @param p : priority of new value
// @return new_node : node representation of new value
func pq_node_create{
    syscall_ptr: felt*,
    pedersen_ptr: HashBuiltin*,
    range_check_ptr,
} (val : felt, p : felt) -> (new_node : Node) {
    alloc_locals;

    let (id) = curr_item_id.read();
    tempvar new_node: Node* = new Node(id=id, val=val, p=p);
    pq.write(id, [new_node]);
    curr_item_id.write(id + 1);

    return (new_node=[new_node]);
}

// Insert new value with priority to queue.
// @param val : New value to be inserted to queue
// @param p : Priority of new value to be inserted to queue
func pq_enqueue{
    syscall_ptr: felt*,
    pedersen_ptr: HashBuiltin*,
    range_check_ptr,
} (val : felt, p : felt) {
    alloc_locals;

    let (len) = pq_length.read();
    let (new_node) = pq_node_create(val, p);
    pq.write(len, new_node);
    pq_bubble_up(idx=len);   
    pq_length.write(len+1);

    return ();
}

// Recursively find correct position of new value within priority queue.
// @param idx : Node of priority queue being checked in current run of function
func pq_bubble_up{
    syscall_ptr: felt*,
    pedersen_ptr: HashBuiltin*,
    range_check_ptr,
} (idx : felt) {
    alloc_locals;

    if (idx == 0) {
        return ();
    }
    
    let (parent_idx, _) = unsigned_div_rem(idx - 1, 2);
    let (node) = pq.read(idx=idx);
    let (parent_node) = pq.read(idx=parent_idx);

    local less_than_or_equals = is_le(node.p, parent_node.p);
    if (less_than_or_equals == 1) {
        return ();
    }
    pq_swap(idx, parent_idx);
    pq_bubble_up(idx=parent_idx);
    handle_revoked_refs();

    return ();
}

// Delete root value from priority queue.
// @return old_root : Root value deleted from queue
func pq_dequeue{
    syscall_ptr: felt*,
    pedersen_ptr: HashBuiltin*,
    range_check_ptr,
} () -> (old_root : Node) {
    alloc_locals; 

    let (len) = pq_length.read();
    let (root) = pq.read(0);
    let (last) = pq.read(len - 1);
    tempvar empty_node: Node* = new Node(id=-1, val=-1, p=-1);
    pq.write(len - 1, [empty_node]);
    pq_length.write(len - 1);

    let pq_len_pos = is_le(1, len - 1);
    if (pq_len_pos == 1) {
        pq.write(0, last);
        pq_sink_down(idx=0);
        handle_revoked_refs();
    } else {
        handle_revoked_refs();
    }

    return (old_root=root);
}

// Recursively find correct position of new root value within queue.
// @param idx : Node of queue being checked in current run of function
func pq_sink_down{
    syscall_ptr: felt*,
    pedersen_ptr: HashBuiltin*,
    range_check_ptr,
} (idx : felt) {
    alloc_locals;

    local left_idx = 2 * idx + 1;
    local right_idx = 2 * idx + 2;

    let (node) = pq.read(idx);
    let (left) = pq.read(left_idx);
    let (right) = pq.read(right_idx);

    let left_exists = is_le(1, left.p); 
    let right_exists = is_le(1, right.p);
    let less_than_left = is_le(node.p, left.p);
    let less_than_right = is_le(node.p, right.p);
    let right_larger = is_le(left.p, right.p - 1);

    if (left_exists == 0) {
        if (right_exists == 1) {
            if (less_than_right == 1) {
                pq_swap(idx, right_idx);
                pq_sink_down(right_idx);
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
                pq_swap(idx, left_idx);
                pq_sink_down(left_idx);
                handle_revoked_refs();
            } else {
                handle_revoked_refs();
            }
        } else {
            if (right_larger == 1) {
                pq_swap(idx, right_idx);
                pq_sink_down(right_idx);
                handle_revoked_refs();
            } else {
                pq_swap(idx, left_idx);
                pq_sink_down(left_idx);
                handle_revoked_refs();
            }
        }
    }
    return ();
}

// Utility function to swap locations of two values in queue.
// @param idx_a : Index of first value being swapped
// @param idx_b : Index of second value being swapped
func pq_swap{
    syscall_ptr: felt*,
    pedersen_ptr: HashBuiltin*,
    range_check_ptr,
} (idx_a : felt, idx_b : felt) {
    alloc_locals;

    let (node_a) = pq.read(idx_a);
    let (node_b) = pq.read(idx_b);
    pq.write(idx_a, node_b);
    pq.write(idx_b, node_a);

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