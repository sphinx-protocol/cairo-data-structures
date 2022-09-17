%lang starknet

from starkware.cairo.common.dict_access import DictAccess
from starkware.cairo.common.alloc import alloc

from contracts.cairo.dict_linked.dict_access import LinkedDictAccess
from contracts.cairo.dict_linked.default_dict import (
    default_dict_new, default_dict_finalize
)
from contracts.cairo.dict_linked.dict import (
    linked_dict_write, linked_dict_read, linked_dict_update
)

// Returns the value for the specified key in a dictionary.
func create_linked_dict{
        range_check_ptr
    } (initial_value : felt) -> (dict : LinkedDictAccess*) {
    alloc_locals;

    let (local dict) = default_dict_new(default_value=initial_value);

    default_dict_finalize(
        dict_accesses_start=dict,
        dict_accesses_end=dict,
        default_value=initial_value);

    return (dict=dict);
}