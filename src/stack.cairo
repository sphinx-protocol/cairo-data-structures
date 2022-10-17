%lang starknet

from starkware.cairo.common.cairo_builtins import HashBuiltin
from starkware.cairo.common.alloc import alloc
from starkware.cairo.common.math_cmp import is_le

// Data structure representing a node in a stack.
struct Node {
    id : felt,
    val : felt,
    next_id : felt,
}

// Stores current nodes in stack.
@storage_var
func stack(id : felt) -> (node : Node) {
}

// Stores head of stack.
@storage_var
func stack_head() -> (id : felt) {
}

// Stores tail of stack.
@storage_var
func stack_tail() -> (id : felt) {
}

// Stores length of stack.
@storage_var
func stack_len() -> (len : felt) {
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

// Create new node for stack.
// @param val : new value
// @param next_id : id of next value
// @return new_node : node representation of new value
func stack_node_create{
    syscall_ptr: felt*,
    pedersen_ptr: HashBuiltin*,
    range_check_ptr,
} (val : felt, next_id : felt) -> (new_node : Node) {
    alloc_locals;

    let (id) = curr_item_id.read();
    tempvar new_node: Node* = new Node(id=id, val=val, next_id=next_id);
    stack.write(id, [new_node]);
    curr_item_id.write(id + 1);

    return (new_node=[new_node]);
}

// Insert item to the head of the stack.
// @param val : new value inserted to stack
func stack_push{
    syscall_ptr: felt*,
    pedersen_ptr: HashBuiltin*,
    range_check_ptr,
} (val : felt) -> (new_len : felt) {
    alloc_locals;

    let (head_id) = stack_head.read();
    let (new_node) = stack_node_create(val=val, next_id=head_id);
    let (length) = stack_len.read();

    if (length == 0) {
        stack_head.write(new_node.id);
        stack_tail.write(new_node.id);
        handle_revoked_refs();
    } else {
        stack_head.write(new_node.id);
        handle_revoked_refs();
    }

    stack_len.write(length + 1);  
      
    return (new_len=length + 1);
}

// Remove item from the head of the stack.
// @return del : old head deleted from stack
func stack_pop{
    syscall_ptr: felt*,
    pedersen_ptr: HashBuiltin*,
    range_check_ptr,
} () -> (del : Node) {
    alloc_locals;

    let (length) = stack_len.read();
    tempvar empty_node: Node* = new Node(id=-1, val=-1, next_id=-1);
    if (length == 0) {
        return (del=[empty_node]);
    }

    let (old_head_id) = stack_head.read();
    let (old_head) = stack.read(old_head_id);
    let (head_next) = stack.read(old_head.next_id);
    stack_head.write(head_next.id);
    stack.write(old_head_id, [empty_node]);
    stack_len.write(length - 1);

    if (length - 1 == 0) {
        let (tail_id) = stack_tail.read();
        stack.write(tail_id, [empty_node]);
        stack_head.write(-1);
        stack_tail.write(-1);
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