%lang starknet

from starkware.cairo.common.cairo_builtins import HashBuiltin
from src.binary_search_tree import (
    bst, bst_root, bst_insert, bst_find, curr_item_id, Node
)

@external
func test_binary_search_tree{
    syscall_ptr : felt*,
    pedersen_ptr : HashBuiltin*,
    range_check_ptr
} () {
    alloc_locals;

    // Constructor
    tempvar empty_node: Node* = new Node(id=-1, val=-1, left_id=-1, right_id=-1);
    bst.write(-1, [empty_node]);
    bst_root.write(-1);
    curr_item_id.write(1);

    bst_insert(3);
    bst_insert(2);
    bst_insert(5);
    let (root_id) = bst_root.read();
    let (root) = bst.read(root_id);
    assert root.val = 3;

    let (find_5) = bst_find(5);
    assert find_5.val = 5;
    let (find_1) = bst_find(1);
    assert find_1.id = -1;
    
    return ();
}

