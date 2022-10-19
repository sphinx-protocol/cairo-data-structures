%lang starknet

from starkware.cairo.common.cairo_builtins import HashBuiltin
from starkware.cairo.common.alloc import alloc
from starkware.cairo.common.math_cmp import is_le

// Data structure representing a node in a binary search tree.
struct Node {
    id : felt,
    val : felt,
    left_id : felt,
    right_id : felt,
}

// Stores nodes in binary search tree (BST).
@storage_var
func bst(idx : felt) -> (node : Node) {
}

// Stores root of binary search tree.
@storage_var
func bst_root() -> (id : felt) {
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
    tempvar empty_node: Node* = new Node(id=-1, val=-1, left_id=-1, right_id=-1);
    bst.write(-1, [empty_node]);
    bst_root.write(-1);
    curr_item_id.write(1);
    return ();
}

// Create new node for binary search tree.
// @param val : new value
// @param next_id : id of next value
// @return new_node : node representation of new value
func bst_node_create{
    syscall_ptr: felt*,
    pedersen_ptr: HashBuiltin*,
    range_check_ptr,
} (val : felt, left_id : felt, right_id : felt) -> (new_node : Node) {
    alloc_locals;

    let (id) = curr_item_id.read();
    tempvar new_node: Node* = new Node(id=id, val=val, left_id=left_id, right_id=right_id);
    bst.write(id, [new_node]);
    curr_item_id.write(id + 1);

    return (new_node=[new_node]);
}

// Insert new node into BST.
// @param val : new value to be inserted
// @return success : 1 if insertion was successful, 0 otherwise
func bst_insert{
    syscall_ptr: felt*,
    pedersen_ptr: HashBuiltin*,
    range_check_ptr,
} (val : felt) -> (success : felt) {
    alloc_locals;

    let (new_node) = bst_node_create(val, -1, -1);
    let (root_id) = bst_root.read();
    if (root_id == -1) {
        bst_root.write(new_node.id);

        // Diagnostics
        let (new_root) = bst.read(root_id);
        print_dfs_in_order(new_root, 1);

        return (success=1);
    }
    let (root) = bst.read(root_id);
    let (success) = find_position_and_insert(val, root, new_node.id);

    // Diagnostics
    let (new_root) = bst.read(root_id);
    print_dfs_in_order(new_root, 1);

    return (success=success);
}

// Recursively finds correct position for new node in BST and inserts it. 
// @param val : new value to be inserted
// @param curr : current node in traversal of the BST
// @param new_node_id : id of new node to be inserted into the BST
// @return success : 1 if insertion was successful, 0 otherwise
func find_position_and_insert{
    syscall_ptr: felt*,
    pedersen_ptr: HashBuiltin*,
    range_check_ptr,
} (val : felt, curr : Node, new_node_id : felt) -> (success : felt) {
    alloc_locals;
    let (root_id) = bst_root.read();
    let (root) = bst.read(root_id);

    let greater_than = is_le(curr.val, val - 1);
    let less_than = is_le(val, curr.val - 1);

    if (greater_than == 1) {
        if (curr.right_id == -1) {
            tempvar new_curr: Node* = new Node(id=curr.id, val=curr.val, left_id=curr.left_id, right_id=new_node_id);
            bst.write(curr.id, [new_curr]);
            handle_revoked_refs();
            return (success=1);
        } else {
            let (curr_right) = bst.read(curr.right_id);
            handle_revoked_refs();
            return find_position_and_insert(val, curr_right, new_node_id);
        }
    } else {
        if (less_than == 1) {
             if (curr.left_id == -1) {
                tempvar new_curr: Node* = new Node(id=curr.id, val=curr.val, left_id=new_node_id, right_id=curr.right_id);
                bst.write(curr.id, [new_curr]);
                handle_revoked_refs();
                return (success=1);
            } else {
                let (curr_left) = bst.read(curr.left_id);
                handle_revoked_refs();
                return find_position_and_insert(val, curr_left, new_node_id);
            }
        } else {
            handle_revoked_refs(); 
            return (success=0);
        }
    }
}

// Find a node in binary search tree.
// @param val : value to be found
// @return node : retrieved node (or empty node if not found)
func bst_find{
    syscall_ptr: felt*,
    pedersen_ptr: HashBuiltin*,
    range_check_ptr,
} (val : felt) -> (node : Node, parent : Node) {
    let (root_id) = bst_root.read();
    let (root) = bst.read(root_id);
    tempvar empty_node: Node* = new Node(id=-1, val=-1, left_id=-1, right_id=-1);
    if (root_id == -1) {
        return (node=[empty_node], parent=[empty_node]);
    }
    return find_helper(val=val, curr=root, parent=[empty_node]);
}

// Recursively traverses BST to find node.
// @param val : value to be found
// @param curr : current node in traversal of the BST
// @param parent : parent of current node in traversal of the BST
// @return node : retrieved node (or empty node if not found)
// @return parent : parent of retrieved node (or empty node if not found)
func find_helper{
    syscall_ptr: felt*,
    pedersen_ptr: HashBuiltin*,
    range_check_ptr,
} (val : felt, curr : Node, parent : Node) -> (node : Node, parent : Node) {
    alloc_locals;

    if (curr.id == -1) {
        tempvar empty_node: Node* = new Node(id=-1, val=-1, left_id=-1, right_id=-1);
        handle_revoked_refs();
        return (node=[empty_node], parent=[empty_node]);
    } else {
        handle_revoked_refs();
    }    

    let greater_than = is_le(curr.val, val - 1);
    let less_than = is_le(val, curr.val - 1);
    if (greater_than == 1) {
        let (curr_right) = bst.read(curr.right_id);
        handle_revoked_refs();
        return find_helper(val, curr_right, curr);
    } else {
        if (less_than == 1) {
            let (curr_left) = bst.read(curr.left_id);
            handle_revoked_refs();
            return find_helper(val, curr_left, curr);
        } else {
            handle_revoked_refs();
            return (node=curr, parent=parent);
        }
    }
}

// Deletes node from BST
// @param val : value to be deleted
// @return del : deleted node
func bst_delete{
    syscall_ptr: felt*,
    pedersen_ptr: HashBuiltin*,
    range_check_ptr,
} (val : felt) -> (del : Node) {
    alloc_locals;

    let (node, parent) = bst_find(val);
    if (parent.id == -1) {
        bst_root.write(-1);
        handle_revoked_refs();
    } else {
        handle_revoked_refs();
    }
    
    if (node.left_id == -1) {
        if (node.right_id == -1) {
            update_parent(parent=parent, node=node, new_id=-1);
            handle_revoked_refs();
        } else {
            update_parent(parent=parent, node=node, new_id=node.right_id);
            handle_revoked_refs();
        }
    } else {
        if (node.right_id == -1) {
            update_parent(parent=parent, node=node, new_id=node.left_id);
            handle_revoked_refs();
        } else {
            let (right) = bst.read(node.right_id);
            let (successor) = find_min(right);
            bst_delete(successor.val);
            update_parent(parent=parent, node=node, new_id=successor.id);
            handle_revoked_refs();
        }
    }

    // Diagnostics
    let (root_id) = bst_root.read();
    let (root) = bst.read(root_id);
    print_dfs_in_order(root, 1);

    return (del=node);
}

// Helper function to update left or right child of parent.
// @param parent : parent node to update
// @param node : current node to be replaced
// @param new_id : id of new node parent should point to
func update_parent{
    syscall_ptr: felt*,
    pedersen_ptr: HashBuiltin*,
    range_check_ptr,
} (parent : Node, node : Node, new_id : felt) {
    alloc_locals;

    if (parent.left_id == node.id) {
        tempvar new_parent: Node* = new Node(
            id=parent.id, val=parent.val, left_id=new_id, right_id=parent.right_id
        );
        bst.write(parent.id, [new_parent]);
        handle_revoked_refs();
        return ();
    } else {
        if (parent.right_id == node.id) {
            tempvar new_parent: Node* = new Node(
                id=parent.id, val=parent.val, left_id=parent.left_id, right_id=new_id
            );
            bst.write(parent.id, [new_parent]);
            handle_revoked_refs();
            return ();
        } else {
            handle_revoked_refs();
            return ();
        }
    }
}

// Helper function to find the minimum value within a tree
// @param root : root of tree to be searched
// @return min : node representation of minimum value
func find_min{
    syscall_ptr: felt*,
    pedersen_ptr: HashBuiltin*,
    range_check_ptr,
} (root : Node) -> (min : Node) {
    if (root.left_id == -1) {
        return (min=root);
    }
    let (left) = bst.read(root.left_id);
    return find_min(left);
}

func print_dfs_in_order{
    syscall_ptr: felt*,
    pedersen_ptr: HashBuiltin*,
    range_check_ptr,
} (root : Node, iter : felt) {
    alloc_locals;
    if (iter == 1) {
        %{ print("Tree (DFS In Order):") %}
        tempvar temp;
    }

    let left_exists = is_le(0, root.left_id);
    let right_exists = is_le(0, root.right_id);
    
    if (left_exists == 1) {
        let (left) = bst.read(root.left_id);
        print_dfs_in_order(left, 0);
    } else {
        handle_revoked_refs();
    }
    %{ 
        print("    ", end="")
        print("id: {}, val: {}, left_id: {}, right_id: {}".format(ids.root.id, ids.root.val, ids.root.left_id, ids.root.right_id)) 
    %}
    if (right_exists == 1) {
        let (right) = bst.read(root.right_id);
        print_dfs_in_order(right, 0);
        handle_revoked_refs();
    } else {
        handle_revoked_refs();
    }
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