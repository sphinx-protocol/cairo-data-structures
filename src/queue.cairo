%lang starknet

from starkware.cairo.common.cairo_builtins import HashBuiltin
from starkware.cairo.common.alloc import alloc
from starkware.cairo.common.math_cmp import is_le

// Data structure representing a node in a queue.
struct Node {
    id : felt,
    val : felt,
    next_id : felt,
}

// Stores current nodes in queue.
@storage_var
func queue(id : felt) -> (node : Node) {
}

// Stores head of queue.
@storage_var
func queue_head() -> (id : felt) {
}

// Stores tail of queue.
@storage_var
func queue_tail() -> (id : felt) {
}

// Stores length of queue.
@storage_var
func queue_len() -> (len : felt) {
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

// Create new node for queue.
// @param val : new value
// @param next_id : id of next value
// @return new_node : node representation of new value
func queue_node_create{
    syscall_ptr: felt*,
    pedersen_ptr: HashBuiltin*,
    range_check_ptr,
} (val : felt, next_id : felt) -> (new_node : Node) {
    alloc_locals;

    let (id) = curr_item_id.read();
    tempvar new_node: Node* = new Node(id=id, val=val, next_id=next_id);
    queue.write(id, [new_node]);
    curr_item_id.write(id + 1);

    return (new_node=[new_node]);
}

// Insert item at end of the list.
// @param val : new value to be added to queue
func queue_enqueue{
    syscall_ptr: felt*,
    pedersen_ptr: HashBuiltin*,
    range_check_ptr,
} (val : felt) -> (new_len : felt) {
    alloc_locals;

    let (new_node) = queue_node_create(val=val, next_id=-1);
    let (length) = queue_len.read();

    if (length == 0) {
        queue_head.write(new_node.id);
        queue_tail.write(new_node.id);
        handle_revoked_refs();
    } else {
        let (tail_id) = queue_tail.read();
        let (tail) = queue.read(tail_id);
        tempvar new_tail: Node* = new Node(id=tail.id, val=tail.val, next_id=new_node.id);
        queue.write(tail_id, [new_tail]);
        queue_tail.write(new_node.id);
        handle_revoked_refs();
    }

    queue_len.write(length + 1);

    return (new_len=length + 1);
}

// Remove item from the head of the queue.
// @return del : old head deleted from queue
func queue_dequeue{
    syscall_ptr: felt*,
    pedersen_ptr: HashBuiltin*,
    range_check_ptr,
} () -> (del : Node) {
    alloc_locals;

    let (length) = queue_len.read();
    tempvar empty_node: Node* = new Node(id=-1, val=-1, next_id=-1);
    if (length == 0) {
        return (del=[empty_node]);
    }

    let (old_head_id) = queue_head.read();
    let (old_head) = queue.read(old_head_id);
    let (head_next) = queue.read(old_head.next_id);
    queue_head.write(head_next.id);
    queue.write(old_head_id, [empty_node]);
    queue_len.write(length - 1);

    if (length - 1 == 0) {
        let (tail_id) = queue_tail.read();
        queue.write(tail_id, [empty_node]);
        queue_head.write(-1);
        queue_tail.write(-1);
        handle_revoked_refs();
    } else {
        handle_revoked_refs();
    }

    return (del=old_head);
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