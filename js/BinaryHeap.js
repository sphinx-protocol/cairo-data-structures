class MaxBinaryHeap {
    constructor() {
        this.values = []
    }

    // Insert a value into the heap
    insert(val) {
        // Add val to heap
        this.values.push(val)
        this.bubbleUp()
        return this.values
    }

    // Bubble up - find correct position of newly added value within heap
    bubbleUp() {
        // idx tracks position of val
        let idx = this.values.length - 1
        // parentIdx tracks position of parent
        let parentIdx = null,
            temp = null
        // Bubble up
        while (idx > 0) {
            parentIdx = Math.floor((idx - 1) / 2)
            if (this.values[idx] <= this.values[parentIdx]) break
            // If value is greater than parent, swap
            temp = this.values[idx]
            this.values[idx] = this.values[parentIdx]
            this.values[parentIdx] = temp
            // Set idx to parent and compare again
            idx = parentIdx
        }
    }

    // Delete root value from the tree
    extractMax() {
        const root = this.values[0]
        const end = this.values.pop()
        // Handle edge case where length = 1
        if (this.values.length > 0) {
            // Swap first value with last one
            this.values[0] = end
            // Remove root from tree
            this.sinkDown()
        }
        return root
    }

    // Sink down - find correct position of newly inserted root
    sinkDown() {
        // idx tracks position of val
        let idx = 0
        // Track positions of left and right child
        let leftIdx = 2 * idx + 1
        let rightIdx = 2 * idx + 2

        if (!this.values[leftIdx] && !this.values[rightIdx]) return

        // Utility function for swapping two values at index and setting
        // idx to swapped value
        const swap = (idxA, idxB) => {
            const temp = this.values[idxA]
            this.values[idxA] = this.values[idxB]
            this.values[idxB] = temp
            idx = idxB
            leftIdx = 2 * idx + 1
            rightIdx = 2 * idx + 2
        }

        while (true) {
            let node = this.values[idx],
                left = this.values[leftIdx],
                right = this.values[rightIdx]
            // If node is less than both left and right childs, swap with
            // larger of the two. Otherwise, swap with the child that is larger.
            if (left && right && node <= left && node <= right) {
                if (left > right) swap(idx, leftIdx)
                else swap(idx, rightIdx)
            } else if (left && node <= left) swap(idx, leftIdx)
            else if (right && node <= right) swap(idx, rightIdx)
            else break
        }
        return
    }
}
