//
//  RunnerMainThread.swift
//  GigyaSwift
//
//  Created by Shmuel, Sagi on 02/06/2019.
//  Copyright © 2019 Gigya. All rights reserved.
//

import Foundation

internal func main(work: @escaping () -> ()) {
    DispatchQueue.main.async {
        work()
    }
}
