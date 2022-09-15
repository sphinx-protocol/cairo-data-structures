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
        return curr
    }

    // Breadth-First Search (BFS)
    // Returns nodes, prioritising all sibling nodes at same level before
    // moving down the tree.
    BFS() {
        // Queue keeps track of nodes to visit
        let queue = []
        // Visited nodes
        let visited = []
        let node = this.root
        queue.push(node)
        while (queue.length) {
            // Move element from queue to visited and add its child nodes to queue
            node = queue.shift()
            visited.push(node)
            if (node.left) queue.push(node.left)
            if (node.right) queue.push(node.right)
        }
        return visited
    }

    // Depth-First Search (DFS) PreOrder
    // Prioritises visiting all children in one branch before continuing.
    // Traverses entire left side of each node before completing right side.
    DFSPreOrder() {
        // Visited nodes
        let visited = []
        const traverse = (node) => {
            visited.push(node)
            if (node.left) traverse(node.left)
            if (node.right) traverse(node.right)
        }
        traverse(this.root)
        return visited
    }

    // Depth-First Search (DFS) PostOrder
    // Prioritises visiting all children in one branch before continuing.
    // Visit all child nodes first before adding parent nodes.
    DFSPostOrder() {
        // Visited nodes
        let visited = []
        const traverse = (node) => {
            if (node.left) traverse(node.left)
            if (node.right) traverse(node.right)
            visited.push(node)
        }
        traverse(this.root)
        return visited
    }

    // Depth-First Search (DFS) InOrder
    // First traverse left side of tree, prioritising child nodes first,
    // before traversing right side (left to right).
    DFSInOrder() {
        // Visited nodes
        let visited = []
        const traverse = (node) => {
            if (node.left) traverse(node.left)
            visited.push(node)
            if (node.right) traverse(node.right)
        }
        traverse(this.root)
        return visited
    }
}
