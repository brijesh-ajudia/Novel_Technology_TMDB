//
//  Reachability.swift
//  Movie Explorer
//
//  Created by Brijesh Ajudia on 09/08/25.
//

import Foundation
import SystemConfiguration

func isConnectedToNetwork() -> Bool {
    var zeroAddress = sockaddr_in()
    zeroAddress.sin_len = UInt8(MemoryLayout<sockaddr_in>.size)
    zeroAddress.sin_family = sa_family_t(AF_INET)
    guard let defaultRouteReachability = withUnsafePointer(to: &zeroAddress, {
        $0.withMemoryRebound(to: sockaddr.self, capacity: 1) { zeroSockAddress in
            SCNetworkReachabilityCreateWithAddress(nil, zeroSockAddress)
        }
    }) else { return false }
    var flags = SCNetworkReachabilityFlags()
    if !SCNetworkReachabilityGetFlags(defaultRouteReachability, &flags) { return false }
    let isReachable = flags.contains(.reachable)
    let needsConnection = flags.contains(.connectionRequired)
    return (isReachable && !needsConnection)
}
