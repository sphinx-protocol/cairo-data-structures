%lang starknet

from starkware.cairo.common.cairo_builtins import HashBuiltin
from starkware.cairo.common.alloc import alloc
from starkware.cairo.common.math_cmp import is_le

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
    return ();
}

// Create new node for singly linked list.
// @param val : new value
// @param next_id : id of next value
// @return new_node : node representation of new value
func sl_node_create{
    syscall_ptr: felt*,
    pedersen_ptr: HashBuiltin*,
    range_check_ptr,
} (val : felt, next_id : felt) -> (new_node : Node) {
    alloc_locals;

    let (id) = curr_order_id.read();
    tempvar new_node: Node* = new Node(id=id, val=val, next_id=next_id);
    sl_list.write(id, [new_node]);
    curr_order_id.write(id + 1);

    return (new_node=[new_node]);
}

// Insert item at end of the list.
// @param val : new value to be added to list
func sl_list_push{
    syscall_ptr: felt*,
    pedersen_ptr: HashBuiltin*,
    range_check_ptr,
} (val : felt) {
    alloc_locals;

    let (new_node) = sl_node_create(val=val, next_id=-1);
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
    // print_sl_list(new_node.id, length + 1);
    // print_diagnostics();

    return ();
}


// Remove item from the end of the list.
// @return del : node deleted from list
func sl_list_pop{
    syscall_ptr: felt*,
    pedersen_ptr: HashBuiltin*,
    range_check_ptr,
} () -> (del : Node) {
    alloc_locals;
    
    let (length) = sl_list_len.read();
    tempvar empty_node: Node* = new Node(id=-1, val=-1, next_id=-1);

    if (length == 0) {
        return (del=[empty_node]);
    }

    let (head_id) = sl_list_head.read();
    let (head) = sl_list.read(head_id);
    let (second_last, last) = find_second_last_elem(prev=[empty_node], curr=head);

    tempvar new_second_last: Node* = new Node(id=second_last.id, val=second_last.val, next_id=-1);
    sl_list.write(second_last.id, [new_second_last]);
    sl_list_tail.write(second_last.id);
    sl_list.write(last.id, [empty_node]);
    sl_list_len.write(length - 1);

    if (length - 1 == 0) {
        sl_list.write(head_id, [empty_node]);
        sl_list.write(second_last.id, [empty_node]);
        sl_list_head.write(-1);
        sl_list_tail.write(-1);
        handle_revoked_refs();
    } else {
        handle_revoked_refs();
    }

    let (new_head_id) = sl_list_head.read();
    // print_sl_list(new_head_id, length - 1);
    // print_diagnostics();

    return (del=last);
}

// Utility function to find second last element of singly linked list.
// @param prev : node immediately preceding current node
// @param curr : current node in this iteration of the function
// @return second_last : second last node in the singly linked list
// @return last : last node in the singly linked list
func find_second_last_elem{
    syscall_ptr: felt*,
    pedersen_ptr: HashBuiltin*,
    range_check_ptr,
} (prev : Node, curr : Node) -> (second_last : Node, last : Node) {
    alloc_locals;
    
    if (curr.next_id == -1) {
        return (second_last=prev, last=curr);
    }

    let (next) = sl_list.read(curr.next_id);
    return find_second_last_elem(prev=curr, curr=next);
}

// Remove item from the head of the singly linked list.
// @return del : old head deleted from singly linked list
func sl_list_shift{
    syscall_ptr: felt*,
    pedersen_ptr: HashBuiltin*,
    range_check_ptr,
} () -> (del : Node) {
    alloc_locals;

    let (length) = sl_list_len.read();
    tempvar empty_node: Node* = new Node(id=-1, val=-1, next_id=-1);
    if (length == 0) {
        return (del=[empty_node]);
    }

    let (old_head_id) = sl_list_head.read();
    let (old_head) = sl_list.read(old_head_id);
    let (head_next) = sl_list.read(old_head.next_id);
    sl_list_head.write(head_next.id);
    sl_list.write(old_head_id, [empty_node]);
    sl_list_len.write(length - 1);

    if (length - 1 == 0) {
        let (tail_id) = sl_list_tail.read();
        sl_list.write(tail_id, [empty_node]);
        sl_list_head.write(-1);
        sl_list_tail.write(-1);
        handle_revoked_refs();
    } else {
        handle_revoked_refs();
    }

    // let (head_id) = sl_list_head.read();
    // print_sl_list(head_id, length - 1);
    // print_diagnostics();

    return (del=old_head);
}

// Insert item to the head of the list.
// @param val : new value inserted to list
func sl_list_unshift{
    syscall_ptr: felt*,
    pedersen_ptr: HashBuiltin*,
    range_check_ptr,
} (val : felt) {
    alloc_locals;

    let (head_id) = sl_list_head.read();
    let (new_node) = sl_node_create(val=val, next_id=head_id);
    let (length) = sl_list_len.read();

    if (length == 0) {
        sl_list_head.write(new_node.id);
        sl_list_tail.write(new_node.id);
        handle_revoked_refs();
    } else {
        sl_list_head.write(new_node.id);
        handle_revoked_refs();
    }

    sl_list_len.write(length + 1);  
    // print_sl_list(new_node.id, length + 1);
    // print_diagnostics();
      
    return ();
}

// Retrieve value at particular position in the list.
// @param node_loc : location of current node in the list
// @param idx : counter for number of traverses of linked list
// @return node : retrieved Node
func sl_list_get{
    syscall_ptr: felt*,
    pedersen_ptr: HashBuiltin*,
    range_check_ptr,
} (node_loc : felt, idx : felt) -> (node : Node) {
    let (node) = sl_list.read(node_loc);
    if (idx == 0) {
        return (node=node);
    }
    return sl_list_get(node.next_id, idx - 1);
}

// Set value at particular position in the list.
// @param idx : element to be updated
// @param val : new value
// @return success : 1 if node was found, 0 otherwise
func sl_list_set{
    syscall_ptr: felt*,
    pedersen_ptr: HashBuiltin*,
    range_check_ptr,
} (idx : felt, val : felt) -> (success : felt) {
    let (in_range) = validate_idx(idx);
    if (in_range == 0) {
        return (success=0);
    }
    let (head_id) = sl_list_head.read();
    let (node) = sl_list_get(head_id, idx);
    tempvar updated_node: Node* = new Node(id=node.id, val=val, next_id=node.next_id);
    sl_list.write(node.id, [updated_node]);

    return (success=1);
}

// Insert value at particular position in the list.
// @param idx : position of list to insert new value
// @param val : new value to insert
// @return success : 1 if insertion was successful, 0 otherwise
func sl_list_insert{
    syscall_ptr: felt*,
    pedersen_ptr: HashBuiltin*,
    range_check_ptr,
} (idx : felt, val : felt) -> (success : felt) {
    alloc_locals;

    let (in_range) = validate_idx(idx + 1);
    if (in_range == 0) {
        return (success=0);
    }
    let (length) = sl_list_len.read();
    if (idx == length) {
        sl_list_push(val);
        return (success=1);
    }
    if (idx == 0) {
        sl_list_unshift(val);
        return (success=1);
    }

    let (head_id) = sl_list_head.read();
    let (prev) = sl_list_get(head_id, idx - 1);
    let (node) = sl_list.read(prev.next_id);
    let (new_node) = sl_node_create(val=val, next_id=node.id);
    tempvar new_prev: Node* = new Node(id=prev.id, val=prev.val, next_id=new_node.id); 
    sl_list.write(prev.id, [new_prev]);

    sl_list_len.write(length + 1);

    return (success=1);
}

// Remove value at particular position in the list.
// @param idx : list item to be deleted
// @return del : deleted Node
func sl_list_remove{
    syscall_ptr: felt*,
    pedersen_ptr: HashBuiltin*,
    range_check_ptr,
} (idx : felt) -> (del : Node) {
    alloc_locals;

    tempvar empty_node: Node* = new Node(id=-1, val=-1, next_id=-1); 
    let (in_range) = validate_idx(idx);
    if (in_range == 0) {
        return (del=[empty_node]);
    }
    let (length) = sl_list_len.read();
    if (idx == length - 1) {
        let (del) = sl_list_pop();
        return (del=del);
    }
    if (idx == 0) {
        let (del) = sl_list_shift();
        return (del=del);
    }

    let (head_id) = sl_list_head.read();
    let (prev) = sl_list_get(head_id, idx - 1);
    let (removed) = sl_list.read(prev.next_id);
    tempvar new_prev: Node* = new Node(id=prev.id, val=prev.val, next_id=removed.next_id); 
    sl_list.write(prev.id, [new_prev]);

    sl_list_len.write(length - 1);

    return (del=removed);

}

// Utility function to check idx is not out of bounds.
// @param idx : index to check
// @return in_range : 1 if idx in range, 0 otherwise
func validate_idx{
    syscall_ptr: felt*,
    pedersen_ptr: HashBuiltin*,
    range_check_ptr,
} (idx : felt) -> (in_range : felt) {
    let (head_id) = sl_list_head.read();
    let (node) = sl_list_get(head_id, idx);
    
    if (node.id == -1) {
        return (in_range=0);
    }
    let idx_negative = is_le(idx, -1);
    if (idx_negative == 1) {
        return (in_range=0);
    }
    let (length) = sl_list_len.read();
    let idx_out_of_bounds = is_le(length, idx);
    if (idx_out_of_bounds == 1) {
        return (in_range=0);
    }

    return (in_range=1);
}

// Utility function for printing singly linked list.
func print_sl_list{
    syscall_ptr: felt*,
    pedersen_ptr: HashBuiltin*,
    range_check_ptr,
} (node_loc : felt, idx: felt) {
    if (idx == 0) {
        %{
            print("")
        %}
        return ();
    }
    let (node) = sl_list.read(node_loc);
    %{
        print(ids.node.val, end="")
    %}
    return print_sl_list(node.next_id, idx - 1);
}

// Utility function for printing storage vars. 
func print_diagnostics{
    syscall_ptr: felt*,
    pedersen_ptr: HashBuiltin*,
    range_check_ptr,
} () {
    let (head_id) = sl_list_head.read();
    let (head) = sl_list.read(head_id);
    let (tail_id) = sl_list_tail.read();
    let (tail) = sl_list.read(tail_id);
    let (len) = sl_list_len.read();
    %{
        print("Head: {} [{}]".format(ids.head.val, ids.head_id))
        print("Tail: {} [{}]".format(ids.tail.val, ids.tail_id))
        print("Length: {}".format(ids.len))
    %}
    return ();
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