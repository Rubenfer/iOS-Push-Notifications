import Foundation
import NIO
import NIOAPNS

let p8FilePath = "/Users/rubenfernandez/Documents/AuthKey_5G55Q66UY2.p8"
let keyIdentifier = "5G55Q66UY2"
let teamIdentifier = "M92GJ8T2S2"
let apiUrl = "http://192.168.1.66:8080/api/token/"

print("---- Send push notifications ----")

print("Select environment: ")
print("1. production")
print("2. sandbox")

var envOption = Console.readInt(min: 1, max: 2)
var env = APNSConfiguration.Environment.sandbox

if envOption == 1 {
    env = .production
}

let tokens = Token.getTokens(from: apiUrl)

var bundles: [String] = []

tokens.forEach( { token in
    if !(bundles.contains(token.appIdentifier)) {
        bundles.append(token.appIdentifier)
    }
} )

guard bundles.count > 0 else { exit(1) }

print("-------------")
for i in 1...bundles.count {
    print("\(i). " + bundles[i-1])
}
print("-- Select Bundle ID number --")

let bundle = bundles[Console.readInt(min: 1, max: bundles.count)-1]

let group = MultiThreadedEventLoopGroup(numberOfThreads: 1)
let signer = try! APNSSigner(filePath: p8FilePath)
let apnsConfig = APNSConfiguration(keyIdentifier: keyIdentifier,
                                       teamIdentifier: teamIdentifier,
                                       signer: signer,
                                       topic: bundle,
                                       environment: env)

let apns = try APNSConnection.connect(configuration: apnsConfig, on: group.next()).wait()

print("Title: ")
let title = Console.readString()
print("Subtitle: ")
let subtitle = Console.readString()
print("Body: ")
let body = Console.readString()
print("Badge: ")
let badge = Console.readInt()

let alert = APSPayload.APSAlert(title: title, subtitle: subtitle, body: body)
let aps = APSPayload(alert: alert, badge: badge)

var notification = AcmeNotification(acme2: [], aps: aps)

print("Custom key? ('y' / 'n')")
if Console.readString() == "y" {
    print("Key: ")
    let key = Console.readString()
    print("Value: ")
    let value = Console.readString()
    notification = AcmeNotification(acme2: [key, value], aps: aps)
}

for token in tokens {
    if (token.debug && env == .sandbox) || (!token.debug && env == .production) {
        do {
            try apns.send(notification, to: token.token).wait()
        } catch {
            token.remove(from: apiUrl)
        }
    }
}

try apns.close().wait()
try group.syncShutdownGracefully()
