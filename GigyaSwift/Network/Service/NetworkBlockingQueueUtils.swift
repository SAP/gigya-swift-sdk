//
//  NetworkBlockingQueueUtils.swift
//  Gigya
//
//  Created by Shmuel, Sagi on 29/10/2019.
//  Copyright © 2019 Gigya. All rights reserved.
//

import Foundation

struct NetworkBlockingQueueUtils {

    let queue = OperationQueue()

    private var blockingQueue: [BlockOperation] = []

    private var blockingState = false

    mutating func add(block: BlockOperation) {
        if blockingState {
            blockingQueue.append(block)
        } else {
            queue.addOperation(block)
        }
    }

    mutating func release() {
        blockingState = false
        queue.addOperations(blockingQueue, waitUntilFinished: false)
        blockingQueue.removeAll()
    }

    mutating func lock() {
        blockingState = true
    }
    
}
