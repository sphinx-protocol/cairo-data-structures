%lang starknet

from starkware.cairo.common.cairo_builtins import HashBuiltin
from src.stack import (
    stack, stack_head, stack_tail, stack_len, stack_push, stack_pop
)

@external
func test_stack{
    syscall_ptr : felt*,
    pedersen_ptr : HashBuiltin*,
    range_check_ptr
} () {
    alloc_locals;

    let (len_1) = stack_push(3);
    assert len_1 = 1;
    let (len_2) = stack_push(4);
    assert len_2 = 2;
    let (len_3) = stack_push(5);
    assert len_3 = 3;
    let (len_4) = stack_push(6);
    assert len_4 = 4;

    let (del_1) = stack_pop();
    assert del_1.val = 6;
    let (del_2) = stack_pop();
    assert del_2.val = 5;
    let (del_3) = stack_pop();
    assert del_3.val = 4;
    let (del_4) = stack_pop();
    assert del_4.val = 3;
    
    return ();
}

