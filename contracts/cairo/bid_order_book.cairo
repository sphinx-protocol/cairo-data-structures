%lang starknet

from starkware.cairo.common.cairo_builtins import HashBuiltin
from starkware.cairo.common.dict_access import DictAccess
from starkware.cairo.common.default_dict import (
    default_dict_new, default_dict_finalize
)
from starkware.cairo.common.dict import (
    dict_write, dict_read, dict_update
)
from starkware.cairo.common.alloc import alloc
from starkware.cairo.common.math import unsigned_div_rem
from starkware.cairo.common.math_cmp import is_le

// Data structure representing a single limit order.
struct Order {
    id : felt,
    price : felt,
    dt : felt,
}

// Data structure representing additional details for an order.
// @dev OrderDetails linked to Order by unique identifer id
struct OrderDetails {
    id : felt,
    dt : felt,
    owner : felt,
    pair : felt,
    chain_id : felt,
    price : felt,
    size : felt,
}

// Stores current state of order book, represented as a binary heap.
@storage_var
func bid_order_book(idx : felt) -> (order: Order) {
}

// Stores length of order book.
@storage_var
func bob_length() -> (res : felt) {
}

// Stores order details as mapping of id to order details.
@storage_var
func order_details(id : felt) -> (details: OrderDetails) {
}

// Insert new order to bid order book (bob).
// @param order_price : Order price
// @param order_dt : Order datetime
// @param order_id : Order ID
func bob_insert{
    syscall_ptr: felt*,
    pedersen_ptr: HashBuiltin*,
    range_check_ptr,
} (order_price : felt, order_dt : felt, order_id: felt) {
    alloc_locals;

    let (len) = bob_length.read();
    tempvar new_order: Order* = new Order(
        id=order_id, price=order_price, dt=order_dt
    );
    bid_order_book.write(len, [new_order]);
    bob_bubble_up(idx=len);   
    bob_length.write(len+1);

    return ();
}

// Recursively find correct position of new order within buy order book.
// @param idx : Node of heap being checked in current run of function
func bob_bubble_up{
    syscall_ptr: felt*,
    pedersen_ptr: HashBuiltin*,
    range_check_ptr,
} (idx : felt) {
    alloc_locals;

    if (idx == 0) {
        return ();
    }
    
    let (parent_idx, _) = unsigned_div_rem(idx - 1, 2);
    let (order) = bid_order_book.read(idx=idx);
    let (parent_order) = bid_order_book.read(idx=parent_idx);

    local price_less_than = is_le(order.price, parent_order.price - 1);
    if (price_less_than == 1) {
        return ();
    }

    local datetime_greater_or_equal = is_le(parent_order.dt, order.dt);
    if (order.price == parent_order.price) {
        if (datetime_greater_or_equal == 1) {
            handle_revoked_refs();
            return ();
        } else {
            bob_swap(idx, parent_idx);
            bob_bubble_up(idx=parent_idx);
            handle_revoked_refs();
        }
    } else {
        bob_swap(idx, parent_idx);
        bob_bubble_up(idx=parent_idx);
        handle_revoked_refs();
    }

    return ();
}

// Delete order from buy order book (bob).
// @param heap_len : Length of heap
// @return root : Root value deleted from heap
func bob_extract{
    syscall_ptr: felt*,
    pedersen_ptr: HashBuiltin*,
    range_check_ptr,
} () -> (root_price : felt, root_dt : felt, root_id : felt) {
    alloc_locals; 

    let (len) = bob_length.read();
    let (root) = bid_order_book.read(0);
    let (last) = bid_order_book.read(len - 1);

    tempvar new_order: Order* = new Order(
        id=0, price=0, dt=0
    );
    bid_order_book.write(len - 1, [new_order]);
    bob_length.write(len - 1);

    let heap_len_pos = is_le(1, len - 1);
    if (heap_len_pos == 1) {
        bid_order_book.write(0, last);
        bob_sink_down(idx=0);
        handle_revoked_refs();
    } else {
        handle_revoked_refs();
    }

    return (root_price=root.price, root_dt=root.dt, root_id=root.id);
}

// Recursively find correct position of new root value within order book.
// @param idx : Node of heap being checked in current run of function
func bob_sink_down{
    syscall_ptr: felt*,
    pedersen_ptr: HashBuiltin*,
    range_check_ptr,
} (idx : felt) {
    alloc_locals;

    local left_idx = 2 * idx + 1;
    local right_idx = 2 * idx + 2;

    let (node) = bid_order_book.read(idx);
    let (left) = bid_order_book.read(left_idx);
    let (right) = bid_order_book.read(right_idx);

    let left_exists = is_le(1, left.price); 
    let right_exists = is_le(1, right.price);
    let price_less_than_left = is_le(node.price, left.price - 1);
    let price_less_than_right = is_le(node.price, right.price - 1);
    let dt_greater_than_left = is_le(left.dt, node.dt - 1);
    let dt_greater_than_right = is_le(right.dt, node.dt - 1);
    let right_price_larger = is_le(left.price, right.price - 1);
    let right_dt_smaller = is_le(right.dt, left.dt - 1);

    if (left_exists == 0) {
        if (right_exists == 1) {
            if (price_less_than_right == 1) {
                bob_swap(idx, right_idx);
                bob_sink_down(right_idx);
                handle_revoked_refs();
            } else {
                if (node.price == right.price) {
                    if (dt_greater_than_right == 1) {
                        bob_swap(idx, right_idx);
                        bob_sink_down(right_idx);
                        handle_revoked_refs();
                    } else {
                        handle_revoked_refs();
                    }
                } else {
                    handle_revoked_refs();
                }
            }            
        } else {
            handle_revoked_refs();
        }
    } else {
        if (right_exists == 0) {
            if (price_less_than_left == 1) {
                bob_swap(idx, left_idx);
                bob_sink_down(left_idx);
                handle_revoked_refs();
            } else {
                if (node.price == left.price) {
                    if (dt_greater_than_left == 1) {
                        bob_swap(idx, left_idx);
                        bob_sink_down(left_idx);
                        handle_revoked_refs();
                    } else {
                        handle_revoked_refs();
                    }
                } else {
                    handle_revoked_refs();
                }
            }  
        } else {
            if (price_less_than_left == 1) {
                if (price_less_than_right == 1) {
                    if (right_price_larger == 1) {
                        bob_swap(idx, right_idx);
                        bob_sink_down(right_idx);
                        handle_revoked_refs();
                    } else {
                        bob_swap(idx, left_idx);
                        bob_sink_down(left_idx);
                        handle_revoked_refs();
                    }
                } else {
                    bob_swap(idx, left_idx);
                    bob_sink_down(left_idx);
                    handle_revoked_refs();
                }
            } else {
                if (price_less_than_right == 1) {
                    bob_swap(idx, right_idx);
                    bob_sink_down(right_idx);
                    handle_revoked_refs();
                } else {
                    if (node.price == left.price) {
                        if (node.price == right.price) {
                            if (right_dt_smaller == 1) {
                                bob_swap(idx, right_idx);
                                bob_sink_down(right_idx);
                                handle_revoked_refs();
                            } else {
                                bob_swap(idx, left_idx);
                                bob_sink_down(left_idx);
                                handle_revoked_refs();
                            }
                        } else {
                            if (dt_greater_than_left == 1) {
                                bob_swap(idx, left_idx);
                                bob_sink_down(left_idx);
                                handle_revoked_refs();
                            } else {
                                handle_revoked_refs();
                            }
                        }
                    } else {
                        if (node.price == right.price) {
                            if (dt_greater_than_right == 1) {
                                bob_swap(idx, right_idx);
                                bob_sink_down(right_idx);
                                handle_revoked_refs();
                            } else {
                                handle_revoked_refs();
                            }
                        } else {
                            handle_revoked_refs();
                        }
                    }
                }
            }
        }
    }
    return ();
}

// Utility function to swap location of two entries in buy order book.
// @param idx_a : Index of first order being swapped
// @param idx_b : Index of second order being swapped
func bob_swap{
    syscall_ptr: felt*,
    pedersen_ptr: HashBuiltin*,
    range_check_ptr,
} (idx_a : felt, idx_b : felt) {
    alloc_locals;

    let (order_a) = bid_order_book.read(idx_a);
    let (order_b) = bid_order_book.read(idx_b);
    bid_order_book.write(idx_a, order_b);
    bid_order_book.write(idx_b, order_a);

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