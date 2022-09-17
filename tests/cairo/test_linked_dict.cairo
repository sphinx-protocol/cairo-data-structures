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

from contracts.cairo.dict.dict_utils import (
    create_dict, add_entries, read_entry, update_entry
)
from contracts.cairo.dict_linked.dict_access import LinkedDictAccess
from contracts.cairo.dict_linked.dict import (
    linked_dict_new, linked_dict_read, linked_dict_write, linked_dict_update    
)
from contracts.cairo.dict_linked.dict_utils import (
    create_linked_dict
)


@external
func test_linked_dict{
    syscall_ptr : felt*,
    pedersen_ptr : HashBuiltin*,
    range_check_ptr
} () {
    alloc_locals;
    let (dict) = create_dict(initial_value=-1);
    let (linked_dict) = create_linked_dict(initial_value=dict);

    return ();
}

