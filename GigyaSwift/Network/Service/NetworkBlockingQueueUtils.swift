//
//  NetworkBlockingQueueUtils.swift
//  Gigya
//
//  Created by Shmuel, Sagi on 29/10/2019.
//  Copyright © 2019 Gigya. All rights reserved.
//

import Foundation

struct NetworkBlockingQueueUtils {
    private let queue = OperationQueue()

    private var blockingQueue: [BlockOperation] = []

    var blockingState = false

    mutating func add(block: BlockOperation) {
        blockingQueue.append(block)
    }

    func runWith(block: BlockOperation) {
        queue.addOperation(block)
    }

    mutating func release() {
        blockingState = false
        queue.addOperations(blockingQueue, waitUntilFinished: false)
        blockingQueue.removeAll()
    }
    
}
