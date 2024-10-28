package btreebench

import (
	"fmt"
	"strconv"

	"../../btree.gno/gno.land/p/btree"
	"gno.land/p/demo/math/rand/xorshiftr128plus"
)

func main() {
	recordCount := 100000

	baseTree := btree.New(10)
	rand := xorshiftr128plus.New()

	fmt.Printf("Populate %d random records\n", recordCount)

	for i := 0; i < recordCount; i++ {
		baseTree.Insert(Content{Key: strconv.FormatUint(rand.Uint64(), 10), Value: i})
	}

	fmt.Printf("Populated %d records.\n", recordCount)
}
