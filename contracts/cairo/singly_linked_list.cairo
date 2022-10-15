%lang starknet

from starkware.cairo.common.cairo_builtins import HashBuiltin
from starkware.cairo.common.alloc import alloc

// Data structure representing a node in a singly linked list.
struct Node {
    id : felt,
    val : felt,
    next_id : felt,
}

// Stores current nodes in singly linked list.
@storage_var
func sl_list(id : felt) -> (node : Node) {
}

// Stores head of singly linked list.
@storage_var
func sl_list_head() -> (id : felt) {
}

// Stores tail of singly linked list.
@storage_var
func sl_list_tail() -> (id : felt) {
}

// Stores length of singly linked list.
@storage_var
func sl_list_len() -> (len : felt) {
}

// Stores latest order id.
@storage_var
func curr_order_id() -> (id : felt) {
}

@constructor
func constructor{
    syscall_ptr: felt*,
    pedersen_ptr: HashBuiltin*,
    range_check_ptr,
} () {
    curr_order_id.write(1);
}

// Create new node for singly linked list.
func sl_node_create{
    syscall_ptr: felt*,
    pedersen_ptr: HashBuiltin*,
    range_check_ptr,
} (val : felt) -> (new_node : Node) {
    alloc_locals;

    let (id) = curr_order_id.read();
    tempvar new_node: Node* = new Node(id=id, val=val, next_id=0);
    sl_list.write(id, [new_node]);
    curr_order_id.write(id + 1);

    return (new_node=[new_node]);
}

// Insert item at the end of a singly linked list.
func sl_list_push{
    syscall_ptr: felt*,
    pedersen_ptr: HashBuiltin*,
    range_check_ptr,
} (val : felt) -> () {
    alloc_locals;

    let (new_node) = sl_node_create(val);
    let (length) = sl_list_len.read();

    if (length == 0) {
        sl_list_head.write(new_node.id);
        sl_list_tail.write(new_node.id);
        handle_revoked_refs();
    } else {
        let (tail_id) = sl_list_tail.read();
        let (tail) = sl_list.read(tail_id);
        tempvar new_tail: Node* = new Node(id=tail.id, val=tail.val, next_id=new_node.id);
        sl_list.write(tail_id, [new_tail]);
        sl_list_tail.write(new_node.id);
        handle_revoked_refs();
    }

    sl_list_len.write(length + 1);    

    return ();
}

// Remove item from the end of the singly linked list.
func sl_list_pop{
    syscall_ptr: felt*,
    pedersen_ptr: HashBuiltin*,
    range_check_ptr,
} () -> (del : Node) {
    alloc_locals;
    
    let (length) = sl_list_len.read();
    tempvar empty_node: Node* = new Node(id=0, val=0, next_id=0);

    if (length == 0) {
        return (del=[empty_node]);
    }

    let (head_id) = sl_list_head.read();
    let (head) = sl_list.read(head_id);
    let (second_last, last) = find_second_last_elem(head, [empty_node]);

    tempvar new_second_last: Node* = new Node(id=second_last.id, val=second_last.val, next_id=0);
    sl_list.write(second_last.id, [new_second_last]);
    sl_list_tail.write(second_last.id);
    sl_list_len.write(length - 1);

    if (length - 1 == 0) {
        sl_list.write(head_id, [empty_node]);
        sl_list.write(second_last.id, [empty_node]);
        sl_list_head.write(0);
        sl_list_tail.write(0);
        handle_revoked_refs();
    } else {
        handle_revoked_refs();
    }

    return (del=last);
}

// Utility function to find second last element of linked list.
func find_second_last_elem{
    syscall_ptr: felt*,
    pedersen_ptr: HashBuiltin*,
    range_check_ptr,
} (prev : Node, curr : Node) -> (second_last : Node, last : Node) {
    alloc_locals;

    if (curr.next_id == 0) {
        return (second_last=prev, last=curr);
    }

    let (next) = sl_list.read(curr.next_id);
    return find_second_last_elem(prev=curr, curr=next);
}


// Utility function to handle revoked implicit references.
// @dev bob_prices, bob_dts, bob_ids, bob_len must be passed as implicit arguments
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