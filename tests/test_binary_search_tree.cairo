%lang starknet

from starkware.cairo.common.cairo_builtins import HashBuiltin
from src.binary_search_tree import (
    curr_item_id, Node, bst, bst_root, bst_insert, bst_find, bst_delete 
)

// @external
// func test_binary_search_tree{
//     syscall_ptr : felt*,
//     pedersen_ptr : HashBuiltin*,
//     range_check_ptr
// } () {
//     alloc_locals;

//     // Constructor
//     tempvar empty_node: Node* = new Node(id=-1, val=-1, left_id=-1, right_id=-1);
//     bst.write(-1, [empty_node]);
//     bst_root.write(-1);
//     curr_item_id.write(1);

//     bst_insert(4);
//     bst_insert(2);
//     bst_insert(1);
//     bst_insert(2);
//     bst_insert(9);
//     bst_insert(7);
//     bst_insert(10);
//     bst_insert(11);

//     let (find_1, _) = bst_find(1);
//     assert find_1.val = 1;
//     let (find_5, _) = bst_find(5);
//     assert find_5.id = -1;

//     let (del_10) = bst_delete(10);
//     assert del_10.val = 10;
    
//     return ();
// }

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

    bst_insert(95);
    bst_insert(96);
    bst_insert(70);
    bst_insert(71);

    bst_delete(95);
    
    return ();
}

