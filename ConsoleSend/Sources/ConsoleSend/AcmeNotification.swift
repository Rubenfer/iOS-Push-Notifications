import Foundation
import NIO
import NIOAPNS

struct AcmeNotification: APNSNotification {
    
    let acme2: [String]
    let aps: APSPayload
    
    init(acme2: [String], aps: APSPayload) {
        self.acme2 = acme2
        self.aps = aps
    }
    
}
