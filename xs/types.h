#ifndef __INHERITED_XS_TYPES_H_
#define __INHERITED_XS_TYPES_H_

/*
    av_extend() always gives us at least 4 elements, so don't bother with
    saving memory for need_cb = false version until this struct grows larger
*/

struct shared_keys {
    union {
        SV* hash_key;
        SV* storage;
    };
    union {
        SV* pkg_key;
        SV* lazy_cb;
    };
    SV* read_cb;
    SV* write_cb;
};

enum AccessorType {
    Inherited,
    InheritedCb,
    PrivateClass,
    ObjectOnly,
    Constructor,
    LazyClass,
    InheritedCompat
};

/*
    - must have a value for each AccessorType element
    - '-2' will croak in av_extend() and is used as a guard
*/
const int ALLOC_SIZE[] = {3, 3, 0, 0, -2, 1, 3};

#endif /* __INHERITED_XS_TYPES_H_ */
