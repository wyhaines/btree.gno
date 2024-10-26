# Preface

This library started as an attempt to port/fix a btree implementation for Go that an acquaintance shared with me. It was somewhat minimal and broken, and after fixing it and working to expand its capabilities, I discovered that what I was given was a stripped down, minimal rendition of an old version of the BTree published by Google. I have worked to make the API mostly match the complete orginal Google version, and while the implementation differs quite a lot in the small details -- my version has a lot of code rewritten from scratch to be clearer and easier to understand, with pretty complete comment coverage -- I have tried to match the big details to the original Google version. Accordingly, the Google Apache2 license is credited in the LICENSE file.

# B-Tree Library in Gno

This library provides a B-Tree implementation in Gno. A B-Tree is an ordered data structure optimized for efficient inserts, deletions, and lookups. The B-Tree implementation supports user-defined data types by leveraging a flexible interface. This README will walk you through the library features, the B-Tree structure, and how to use it with examples.

## Table of Contents

1. [Overview](#overview)
2. [Installation](#installation)
3. [Usage](#usage)
    - [Basic Operations](#basic-operations)
    - [Iterating Over the Tree](#iterating-over-the-tree)
4. [Understanding the B-Tree](#understanding-the-b-tree)
5. [Performance Considerations](#performance-considerations)
6. [Testing](#testing)

## Overview

The B-Tree is a self-balancing tree data structure that maintains sorted data and allows efficient searches, sequential access, insertions, and deletions. In this implementation:

- **Records** are the basic units that the tree stores.
- **Copy-on-Write** semantics are used to allow efficient cloning and concurrent read operations.
- The implementation supports **custom Record types** by implementing a `Less()` function to allow record comparison.

This package is designed to be flexible, allowing users to define their own data types and integrate them into the B-Tree seamlessly.

## Installation

To use the B-Tree library, simply clone this repository and import the `btree` package in your Gno project:

```go
import "btree"
```

## Usage

### Defining a Record Type

To insert custom data types into the B-Tree, define a type that implements the `Record` interface. As a very simple example:

```go
type Content struct {
    Key   interface{}
    Value interface{}
}

func (c Content) Less(than btree.Record) bool {
    other := than.(Content)
    return c.Key < other.Key // Simple comparison based on Key
}
```

This example supports mixed int and string keys, where int keys are always less than string keys.

```go
// Content represents a key-value pair where the Key can be either an int or string
// and the Value can be any type.
type Content struct {
        Key   interface{}
        Value interface{}
}

// Less compares two Content records by their Keys.
// The Key must be either an int or a string.
func (c Content) Less(than Record) bool {
        other, ok := than.(Content)
        if !ok {
                panic("cannot compare: incompatible types")
        }

        switch key := c.Key.(type) {
        case int:
                switch otherKey := other.Key.(type) {
                case int:
                        return key < otherKey
                case string:
                        return true // ints are always less than strings
                default:
                        panic("unsupported key type: must be int or string")
                }
        case string:
                switch otherKey := other.Key.(type) {
                case int:
                        return false // strings are always greater than ints
                case string:
                        return key < otherKey
                default:
                        panic("unsupported key type: must be int or string")
                }
        default:
                panic("unsupported key type: must be int or string")
        }
}
```

### Basic Operations

```go
// Create a new B-Tree with a degree of 13
tree := btree.New(13)

// Insert some records
tree.Insert(Content{Key: 1, Value: "First"})
tree.Insert(Content{Key: 2, Value: "Second"})
tree.Insert(Content{Key: 3, Value: "Third"})

// Get a record by key
result := tree.Get(Content{Key: 2})
fmt.Printf("Found record: %v\n", result) // Output: Found record: {2 Second}

// Delete a record
deleted := tree.Delete(Content{Key: 2})
fmt.Printf("Deleted record: %v\n", deleted) // Output: Deleted record: {2 Second}
```

### Iterating Over the Tree

The B-Tree library supports several iteration patterns:

```go
// Ascend from the smallest to the largest key
tree.Ascend(func(record btree.Record) bool {
    fmt.Printf("Key: %v, Value: %v
", record.(Content).Key, record.(Content).Value)
    return true
})

// Descend from the largest to the smallest key
tree.Descend(func(record btree.Record) bool {
    fmt.Printf("Key: %v, Value: %v
", record.(Content).Key, record.(Content).Value)
    return true
})
```

## Understanding the B-Tree

The B-Tree structure consists of nodes containing keys and values. Each node has a maximum and minimum number of records, and child nodes are split or merged as necessary to maintain these constraints. This implementation follows these rules:

- **Nodes contain between `Degree-1` and `2*Degree-1` records**, except for the root, which can have fewer records.
- **Copy-on-Write (COW)** semantics allow multiple trees to share nodes safely by creating copies when modifications are needed.
- **Iterators** enable flexible traversal of the tree in both ascending and descending orders.

### Copy-on-Write Semantics

The B-Tree uses a `copyOnWriteContext` to manage node ownership and ensure that cloned trees remain isolated. This technique allows for efficient cloning and concurrent read operations while maintaining data integrity during write operations. After cloning, early writes may be somewhat slower than a write on an uncloned tree, but this penalty is temporary, and amortized over time, a clone will have the same performance characteristics as an uncloned tree.

## Performance Considerations

B-Trees provide efficient performance for search, insert, and delete operations. This implementation leverages a "flatter" tree structure, reducing memory usage and potentially improving cache locality compared to red-black or other binary trees.

**Time complexities** for standard operations:
- **Search**: O(log N)
- **Insertion**: O(log N)
- **Deletion**: O(log N)

## Testing

The library includes a comprehensive set of tests in `btree_test.gno`. To run the tests:

```
gno run -v btree_test.gno
```

The tests cover edge cases, large datasets, and concurrent usage scenarios.

## License

This project is licensed under the Apache 2.0 License. See the LICENSE file for more details.
