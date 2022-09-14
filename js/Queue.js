class Node {
    constructor(val) {
        this.val = val
        this.next = null
    }
}

class Queue {
    constructor() {
        this.head = null
        this.tail = null
        this.length = 0
    }

    // Insert item at the end of the list
    enqueue(val) {
        // Create new node, initialised with value val
        let newNode = new Node(val)
        // If list is empty, set head and tail to new node
        if (this.length === 0) {
            this.head = newNode
            this.tail = newNode
        }
        // Otherwise, add node to list
        else {
            this.tail.next = newNode
            this.tail = newNode
        }
        // Return incremented length
        return ++this.length
    }

    // Remove item from the head of the list
    dequeue() {
        // If no nodes in the list, return undefined
        if (this.length === 0) return undefined
        // Store current head in variable to be returned later
        let oldHead = this.head
        // Set head property to current head's next property
        this.head = this.head.next
        // Decrement length of list
        this.length -= 1
        // Check for edge case where length = 0
        if (this.length === 0) {
            this.tail = null
        }
        // Return node removed
        return oldHead
    }
}
