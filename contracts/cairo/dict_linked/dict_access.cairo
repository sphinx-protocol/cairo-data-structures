from starkware.cairo.common.dict_access import DictAccess

// Modified version of official DictAccess struct to add support 
// for dictionaries that contain DictAccess* pointers as entries. 
struct LinkedDictAccess {
    key: felt,
    prev_value: DictAccess*,
    new_value: DictAccess*,
}