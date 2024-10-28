package btreebench

import (
	"fmt"
	"strconv"

	"../../btree.gno/gno.land/p/btree"
	"gno.land/p/demo/math/rand/xorshiftr128plus"
)

// Content represents a key-value pair where the Key can be either an int or string
// and the Value can be any type.
type Content struct {
	Key   interface{}
	Value interface{}
}

// Less compares two Content items by their Keys.
// The Key must be either an int or a string.
func (c Content) Less(than btree.Record) bool {
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

type ContentSlice []Content

func (s ContentSlice) Len() int {
	return len(s)
}

func (s ContentSlice) Less(i, j int) bool {
	return s[i].Less(s[j])
}

func (s ContentSlice) Swap(i, j int) {
	s[i], s[j] = s[j], s[i]
}

func (s ContentSlice) Copy() ContentSlice {
	newSlice := make(ContentSlice, len(s))
	copy(newSlice, s)
	return newSlice
}

func main() {
	return

	recordCount := 100000

	trees := []*btree.BTree{}

	baseTree := btree.New(10)

	trees = append(trees, baseTree)

	rand := xorshiftr128plus.New()

	fmt.Printf("Populate %d sequential records\n", recordCount)

	for i := 0; i < recordCount; i++ {
		baseTree.Insert(Content{Key: strconv.FormatUint(rand.Uint64(), 10), Value: i})
	}

	fmt.Printf("Populated %d records.\n", recordCount)

	fmt.Printf("Duplicating tree 10 times.\n")

	trees = append(trees, baseTree.Clone())
	trees = append(trees, baseTree.Clone())
	trees = append(trees, baseTree.Clone())
	trees = append(trees, baseTree.Clone())
	trees = append(trees, baseTree.Clone())
	trees = append(trees, baseTree.Clone())
	trees = append(trees, baseTree.Clone())
	trees = append(trees, baseTree.Clone())
	trees = append(trees, baseTree.Clone())
	trees = append(trees, baseTree.Clone())

	for times := 0; times < 10000; times++ {
		for selector := 0; selector < 11; selector++ {
			trees[selector].Insert(Content{Key: strconv.FormatUint(rand.Uint64(), 10), Value: times})
		}
	}
}
