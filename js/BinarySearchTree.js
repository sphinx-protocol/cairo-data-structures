class Node {
    constructor(val) {
        this.val = val
        this.left = null
        this.right = null
    }
}

class BinarySearchTree {
    constructor() {
        this.root = null
    }

    // Insert new node into the tree
    insert(val) {
        let newNode = new Node(val)
        // If there is no root, new node becomes root
        if (!this.root) {
            this.root = newNode
            return this
        }
        // Otherwise, check if value is greater than or equal to current
        // node. If less, go down left branch, if more, go down right branch.
        let curr = this.root
        while (true) {
            if (val > curr.val) {
                // If right branch does not exist, make new node the right branch,
                // otherwise proceed down the right branch
                if (!curr.right) {
                    curr.right = newNode
                    return this
                }
                curr = curr.right
            } else if (val < curr.val) {
                // If left branch does not exist, make new node the left branch,
                // otherwise proceed down the left branch
                if (!curr.left) {
                    curr.left = newNode
                    return this
                }
                curr = curr.left
            } else {
                // Handle duplicate entry
                return undefined
            }
        }
    }

    // Find a node in the tree
    find(val) {
        // If there is no root, value doesn't exist
        if (!this.root) return false
        // If there is a root, check it against val
        let curr = this.root
        let found = false
        // If value greater than current node, proceed down right branch,
        // if it is less then proceed down left branch
        while (curr && !found) {
            if (val > curr.val) curr = curr.right
            else if (val < curr.val) curr = curr.left
            else found = true
        }
        // If not found, return undefined
        if (!found) return undefined
        return current
    }
}
