class Node {
    constructor(val) {
        this.val = val
        this.next = null
    }
}

class SinglyLinkedList {
    constructor() {
        this.head = null
        this.tail = null
        this.length = 0
    }

    // Insert item at the end of the list
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
            this.tail.next = newNode
            this.tail = newNode
        }
        // Increment length counter
        this.length += 1
        // Return linked list
        return this
    }

    // Remove item from the end of the list
    pop() {
        // If no nodes in the list, return undefined
        if (this.length === 0) return undefined
        // Traverse list to find second to last element
        let curr = this.head
        let prev = null
        while (curr.next) {
            prev = curr
            curr = curr.next
        }
        // Set next property of 2nd to last node to null
        prev.next = null
        // Set tail to 2nd to last node
        this.tail = prev
        // Decrement length of list
        this.length -= 1
        // Check for edge case where length = 0
        if (this.length === 0) {
            this.head = null
            this.tail = null
        }
        // Return node removed
        return curr
    }

    // Remove item from the head of the list
    shift() {
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

    // Insert item to the head of the list
    unshift(val) {
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
        // Increment length counter
        this.length += 1
        return this
    }

    // Retrieve a node by its position in the list
    get(idx) {
        // If the index is less than zero or greater than or equal to
        // the length of the list, return null
        if (idx < 0 || idx >= this.length) return null
        // Loop through list until you reach the index and return node
        let i = idx
        let curr = this.head
        while (i > 0) {
            curr = curr.next
            i--
        }
        return curr
    }

    // Update item at a particular index
    set(idx, val) {
        // Find node with get
        let node = this.get(idx)
        // If node is found, set node to val and return true
        if (node) {
            node.val = val
            return true
        }
        // If node is not found, return false
        return false
    }

    // Insert item at a particular index
    insert(idx, val) {
        // If the index is less than zero or greater than the length
        // of the list, return null
        if (idx < 0 || idx > this.length) return false
        // If index is same as length, push new node at end of list
        if (idx === this.length) return !!this.push(val)
        // If index is 0, unshift a new node to start of list
        if (idx === 0) !!this.unshift(val)
        // Else insert node at index
        let prev = this.get(idx - 1)
        let node = prev.next
        let newNode = new Node(val)
        newNode.next = node
        prev.next = newNode
        this.length += 1
        return true
    }

    // Remove item at a particular index
    remove(idx) {
        // If the index is less than zero or greater than the length
        // of the list, return null
        if (idx < 0 || idx > this.length) return false
        // If index is length - 1, pop
        if (idx === this.length - 1) return this.pop()
        // If index is 0, shift
        if (idx === 0) return this.shift()
        // Otherwise, remove node at index - 1
        let prev = this.get(idx - 1)
        let removed = prev.next
        prev.next = removed.next
        this.length -= 1
        return removed
    }

    // Reverse list in place
    reverse() {
        // Initialise node at head and swap head and tail
        let node = this.head
        this.head = this.tail
        this.tail = node
        // Create next and prev counters
        let next = null
        let prev = null
        // Loop through list and set next
        while (node) {
            // Set next counter to next node
            next = node.next
            // Reverse direction of pointer
            node.next = prev
            // Set prev counter to next node
            prev = node
            // Set node to next
            node = next
        }
        return this
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
