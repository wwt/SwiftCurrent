//https://gist.github.com/JARinteractive/7fb33b6b0043f365ddfd#file-waituntil-swift

import Foundation

func waitUntil(_ checkSuccess: @autoclosure () -> Bool) {
    return waitUntil(3.0, checkSuccess())
}

func waitUntil(_ timeout: Double, _ checkSuccess: @autoclosure () -> Bool) {
    let startDate = NSDate()
    var success = false
    while !success && abs(startDate.timeIntervalSinceNow) < timeout {
        RunLoop.current.run(until: Date(timeIntervalSinceNow: 0.01))
        success = checkSuccess()
    }
}

