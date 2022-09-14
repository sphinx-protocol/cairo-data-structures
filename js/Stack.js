class Node {
    constructor(val) {
        this.val = val
        this.next = null
    }
}

class Stack {
    constructor() {
        this.head = null
        this.tail = null
        this.length = 0
    }

    // Insert item to the head of the list
    push(val) {
        // Create new node, initialised with value val
        let newNode = new Node(val)
        // If list is empty, set head and tail to new node
        if (this.length === 0) {
            this.head = newNode
            this.tail = newNode
        }
        // Otherwise, add node to list
        else {
            newNode.next = this.head
            this.head = newNode
        }
        // Return length counter
        return this.length++
    }

    // Remove item from the head of the list
    pop() {
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

    // Print list
    print() {
        let arr = []
        let current = this.head
        while (current) {
            arr.push(current.val)
            current = current.next
        }
        console.log(arr)
    }
}
