%lang starknet

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


// Create an empty bid order book (bob).
// @dev Empty dict entries are initialised at -1.
// @return bob_prices : Pointer to empty dictionary containing order prices.
// @return bob_dts : Pointer to empty dictionary containing order datetime.
// @return bob_ids : Pointer to empty dictionary containing order IDs.
// @return bob_len : Pointer to empty dictionary containing length of bob at index 0.
func bob_create{range_check_ptr} () -> (
        bob_prices : DictAccess*,
        bob_dts : DictAccess*,
        bob_ids : DictAccess*,
        bob_len : DictAccess*
    ) {
    alloc_locals;

    let (local bob_prices) = default_dict_new(default_value=-1);
    let (local bob_dts) = default_dict_new(default_value=-1);
    let (local bob_ids) = default_dict_new(default_value=-1);
    let (local bob_len) = default_dict_new(default_value=-1);
    dict_write{dict_ptr=bob_len}(key=0, new_value=0);

    return (bob_prices=bob_prices, bob_dts=bob_dts, bob_ids=bob_ids, bob_len=bob_len);
}

// Insert new trade to bid order book (bob).
// @dev bob_prices, bob_dts, bob_ids, bob_len must be passed as implicit arguments
// @param order_price : Order price
// @param order_dt : Order datetime
// @param order_id : Order ID
func bob_insert{
        range_check_ptr,
        bob_prices : DictAccess*,
        bob_dts : DictAccess*,
        bob_ids : DictAccess*,
        bob_len : DictAccess*
    } (order_price : felt, order_dt : felt, order_id: felt) {
    alloc_locals;

    let (len) = dict_read{dict_ptr=bob_len}(key=0);
    dict_write{dict_ptr=bob_prices}(key=len, new_value=order_price);
    dict_write{dict_ptr=bob_dts}(key=len, new_value=order_dt);
    dict_write{dict_ptr=bob_ids}(key=len, new_value=order_id);
    dict_write{dict_ptr=bob_len}(key=0, new_value=len+1);

    bob_bubble_up(idx=len);   

    return ();
}

// Recursively find correct position of new order within buy order book.
// @dev bob_prices, bob_dts, bob_ids, bob_len must be passed as implicit arguments
// @dev tempvars used to handle revoked references
// @param idx : Node of heap being checked in current run of function
func bob_bubble_up{
        range_check_ptr,
        bob_prices : DictAccess*,
        bob_dts : DictAccess*,
        bob_ids : DictAccess*,
        bob_len : DictAccess*
    } (idx : felt) {
    alloc_locals;

    if (idx == 0) {
        return ();
    }
    
    let (parent_idx, _) = unsigned_div_rem(idx - 1, 2);
    let (elem_price) = dict_read{dict_ptr=bob_prices}(key=idx);
    let (elem_dt) = dict_read{dict_ptr=bob_dts}(key=idx);
    let (parent_elem_price) = dict_read{dict_ptr=bob_prices}(key=parent_idx);
    let (parent_elem_dt) = dict_read{dict_ptr=bob_dts}(key=parent_idx);

    local price_less_than = is_le(elem_price, parent_elem_price - 1);
    if (price_less_than == 1) {
        return ();
    }

    local datetime_greater_or_equal = is_le(parent_elem_dt, elem_dt);
    if (elem_price == parent_elem_price) {
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

// Swaps locations of two entries in buy order book.
// @dev bob_prices, bob_dts, bob_ids must be passed as implicit arguments
// @param idx_a : Index of first order being swapped
// @param idx_b : Index of second order being swapped
func bob_swap{
        range_check_ptr,
        bob_prices : DictAccess*,
        bob_dts : DictAccess*,
        bob_ids : DictAccess*,
    } (idx_a : felt, idx_b : felt) {
    alloc_locals;

    let (elem_a_price) = dict_read{dict_ptr=bob_prices}(key=idx_a);
    let (elem_a_dt) = dict_read{dict_ptr=bob_dts}(key=idx_a);
    let (elem_a_id) = dict_read{dict_ptr=bob_ids}(key=idx_a);
    let (elem_b_price) = dict_read{dict_ptr=bob_prices}(key=idx_b);
    let (elem_b_dt) = dict_read{dict_ptr=bob_dts}(key=idx_b);
    let (elem_b_id) = dict_read{dict_ptr=bob_ids}(key=idx_b);

    dict_update{dict_ptr=bob_prices}(key=idx_a, prev_value=elem_a_price, new_value=elem_b_price);
    dict_update{dict_ptr=bob_prices}(key=idx_b, prev_value=elem_b_price, new_value=elem_a_price);
    dict_update{dict_ptr=bob_dts}(key=idx_a, prev_value=elem_a_dt, new_value=elem_b_dt);
    dict_update{dict_ptr=bob_dts}(key=idx_b, prev_value=elem_b_dt, new_value=elem_a_dt);
    dict_update{dict_ptr=bob_ids}(key=idx_a, prev_value=elem_a_id, new_value=elem_b_id);
    dict_update{dict_ptr=bob_ids}(key=idx_b, prev_value=elem_b_id, new_value=elem_a_id);

    return ();
}

// Delete order from buy order book (bob).
// @dev bob_prices, bob_dts, bob_ids, bob_len must be passed as implicit arguments
// @dev tempvars used to handle revoked references for implicit args
// @param heap_len : Length of heap
// @return root : Root value deleted from heap
func bob_extract{
        range_check_ptr,
        bob_prices : DictAccess*,
        bob_dts : DictAccess*,
        bob_ids : DictAccess*,
        bob_len : DictAccess*
    } () -> (root_price : felt, root_dt : felt, root_id : felt) {
    alloc_locals; 

    let (len) = dict_read{dict_ptr=bob_len}(key=0);
    let (root_price) = dict_read{dict_ptr=bob_prices}(key=0);
    let (root_dt) = dict_read{dict_ptr=bob_dts}(key=0);
    let (root_id) = dict_read{dict_ptr=bob_ids}(key=0);
    let (last_price) = dict_read{dict_ptr=bob_prices}(key=len-1);
    let (last_dt) = dict_read{dict_ptr=bob_dts}(key=len-1);
    let (last_id) = dict_read{dict_ptr=bob_ids}(key=len-1);

    dict_update{dict_ptr=bob_prices}(key=len-1, prev_value=last_price, new_value=-1);
    dict_update{dict_ptr=bob_dts}(key=len-1, prev_value=last_dt, new_value=-1);
    dict_update{dict_ptr=bob_ids}(key=len-1, prev_value=last_id, new_value=-1);
    dict_update{dict_ptr=bob_len}(key=0, prev_value=len, new_value=len-1);

    let heap_len_pos = is_le(2, len);
    if (heap_len_pos == 1) {
        dict_update{dict_ptr=bob_prices}(key=0, prev_value=root_price, new_value=last_price);
        dict_update{dict_ptr=bob_dts}(key=0, prev_value=root_dt, new_value=last_dt);
        dict_update{dict_ptr=bob_ids}(key=0, prev_value=root_id, new_value=last_id);
        bob_sink_down(idx=0);
        handle_revoked_refs();
    } else {
        handle_revoked_refs();
    }

    return (root_price=root_price, root_dt=root_dt, root_id=root_id);
}

// Recursively find correct position of new root value within order book.
// @dev bob_prices, bob_dts, bob_ids, bob_len must be passed as implicit arguments
// @dev tempvars used to handle revoked references for implicit args
// @param idx : Node of heap being checked in current run of function
func bob_sink_down{
        range_check_ptr,
        bob_prices : DictAccess*,
        bob_dts : DictAccess*,
        bob_ids : DictAccess*,
        bob_len : DictAccess*
    } (idx : felt) {
    alloc_locals;

    local left_idx = 2 * idx + 1;
    local right_idx = 2 * idx + 2;

    let (node_price) = dict_read{dict_ptr=bob_prices}(key=idx);
    let (left_price) = dict_read{dict_ptr=bob_prices}(key=left_idx);
    let (right_price) = dict_read{dict_ptr=bob_prices}(key=right_idx);
    let (node_dt) = dict_read{dict_ptr=bob_dts}(key=idx);
    let (left_dt) = dict_read{dict_ptr=bob_dts}(key=left_idx);
    let (right_dt) = dict_read{dict_ptr=bob_dts}(key=right_idx);

    let left_exists = is_le(1, left_price); 
    let right_exists = is_le(1, right_price);
    let price_less_than_left = is_le(node_price, left_price - 1);
    let price_less_than_right = is_le(node_price, right_price - 1);
    let dt_greater_than_left = is_le(left_dt, node_dt - 1);
    let dt_greater_than_right = is_le(right_dt, node_dt - 1);
    let right_price_larger = is_le(left_price, right_price - 1);
    let right_dt_smaller = is_le(right_dt, left_dt - 1);

    if (left_exists == 0) {
        if (right_exists == 1) {
            if (price_less_than_right == 1) {
                bob_swap(idx, right_idx);
                bob_sink_down(right_idx);
                handle_revoked_refs();
            } else {
                if (node_price == right_price) {
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
                if (node_price == left_price) {
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
                    if (node_price == left_price) {
                        if (node_price == right_price) {
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
                        if (node_price == right_price) {
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

func handle_revoked_refs{
        range_check_ptr,
        bob_prices : DictAccess*,
        bob_dts : DictAccess*,
        bob_ids : DictAccess*,
        bob_len : DictAccess*
    } () {
    tempvar range_check_ptr=range_check_ptr;
    tempvar bob_prices=bob_prices;
    tempvar bob_dts=bob_dts;
    tempvar bob_ids=bob_ids;
    tempvar bob_len=bob_len;
    return ();
}

