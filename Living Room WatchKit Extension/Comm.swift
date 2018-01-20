//
//  Comm.swift
//  Living Room WatchKit Extension
//
//  Created by Douglas Casey Tucker on 1/19/18.
//  Copyright © 2018 Douglas Casey Tucker. All rights reserved.
//

import Foundation

typealias SimpleCallback = (String) -> Void

public extension String {
    public func capturedGroups(withRegex pattern: String) -> [String] {
        var results = [String]()
        
        var regex: NSRegularExpression
        do {
            regex = try NSRegularExpression(pattern: pattern, options: [])
        } catch {
            return results
        }
        let matches = regex.matches(in: self, options: [], range: NSRange(location:0, length: self.count))
        
        guard let match = matches.first else { return results }
        
        let lastRangeIndex = match.numberOfRanges - 1
        guard lastRangeIndex >= 1 else { return results }
        
        for i in 1...lastRangeIndex {
            let capturedGroupIndex = match.range(at: i)
            let matchedString = (self as NSString).substring(with: capturedGroupIndex)
            results.append(matchedString)
        }
        
        return results
    }
}


class Comm {
    static let sharedInstance = Comm()
    
    var urlSessionConfig : URLSessionConfiguration!
    var urlSession : URLSession!

    init() {
        urlSessionConfig = URLSessionConfiguration.ephemeral
        urlSessionConfig.requestCachePolicy = URLRequest.CachePolicy.reloadIgnoringLocalAndRemoteCacheData
        urlSessionConfig.httpShouldUsePipelining = true
        urlSessionConfig.allowsCellularAccess = false
        urlSessionConfig.timeoutIntervalForRequest = 3
        urlSessionConfig.httpShouldSetCookies = false
        
        urlSession = URLSession(configuration: urlSessionConfig, delegate: SessionDelegate.sharedInstance, delegateQueue: nil)
    }

    var asyncCounter: Int = 0
    var nextInQueue: String? = nil
    func httpGet(request: URLRequest!, callback: @escaping (String, String?) -> Void) {
        if urlSession != nil {
            let task = urlSession.dataTask(with: request){
                (data, response, error) -> Void in
                if error != nil {
                    callback("", error?.localizedDescription)
                } else {
                    let result = String(data: data!, encoding:
                        String.Encoding.utf8 )!
                    callback(result, nil)
                }
            }
            task.resume()
        }
    }
    
    func httpUpload(_ request: URLRequest!, _ body: String, _ callback: @escaping (String, String?) -> Void) {
        if urlSession != nil {
            let task = urlSession.uploadTask(with: request, from: body.data(using: .utf8)){
                (data, response, error) -> Void in
                if error != nil {
                    callback("", error?.localizedDescription)
                } else {
                    let result = String(data: data!, encoding:
                        String.Encoding.utf8 )!
                    callback(result, nil)
                }
            }
            task.countOfBytesClientExpectsToSend = Int64(255 + request.url!.absoluteString.maximumLengthOfBytes(using: .utf8) + body.maximumLengthOfBytes(using: .utf8))
            task.priority = 0.99
            task.resume()
        }
    }
    
    func putReceiver(_ body: String, _ success: @escaping SimpleCallback = {_ in } ) {
        self.asyncCounter += 1
        var request = URLRequest(url: URL(string: "http://192.168.0.22/YamahaRemoteControl/ctrl")!)
        //request.httpBody = body.data(using: .utf8)
        request.httpMethod = "POST"
        httpUpload(request, body){
            (data, error) -> Void in
            if error != nil {
                print("error")
                print(error!)
            } else {
                print("data")
                //let level = data.capturedGroups(withRegex: "<Volume><Lvl><Val>([0-9-]+)</Val>")
                //self.myValue = Int(level[0])!
                print(data)
            }
            if self.nextInQueue != nil {
                let nextBody = self.nextInQueue!
                self.nextInQueue = nil
                self.putReceiver(nextBody, success)
            }
            self.asyncCounter -= 1
            
            success(data)
        }
    }
    
    func queueReceiver(body: String, success: @escaping SimpleCallback = {_ in } ) {
        if asyncCounter == 0 {
            putReceiver(body, success)
        } else {
            nextInQueue = body
        }
    }

}

extension Comm {

    static func xmlVolumeChange(_ volume : Int) -> String {
        return "<YAMAHA_AV cmd=\"PUT\"><Main_Zone><Volume><Lvl><Val>\(volume)</Val><Exp>1</Exp><Unit>dB</Unit></Lvl></Volume></Main_Zone></YAMAHA_AV>"
    }
    
    func getReceiverVolume(_ success : @escaping (Int) -> () ) {
        var request = URLRequest(url: URL(string: "http://192.168.0.22/YamahaRemoteControl/ctrl")!)
        request.httpBody = "<YAMAHA_AV cmd=\"GET\"><Main_Zone><Volume><Lvl>GetParam</Lvl></Volume></Main_Zone></YAMAHA_AV>".data(using: .utf8)
        request.httpMethod = "POST"
        
        let comm = Comm.sharedInstance
        comm.httpGet(request: request){
            (data, error) -> Void in
            if error != nil {
                print("error")
                print(error!)
            } else {
                print("data")
                let level = data.capturedGroups(withRegex: "<Volume><Lvl><Val>([0-9-]+)</Val>")
                print(data)
                return success( Int(level[0])! )
            }
        }
    }
}

extension Comm {
    func sendCode(_ code: String) {
        Comm.sharedInstance.putReceiver("<YAMAHA_AV cmd=\"PUT\"><System><Misc><Remote_Signal><Receive><Code>\(code)</Code></Receive></Remote_Signal></Misc></System></YAMAHA_AV>")
    }
    
    func sendUp() {
        sendCode("7A859D62")
    }
    func sendDown() {
        sendCode("7A859C63")
    }
    func sendLeft() {
        sendCode("7A859F60")
    }
    func sendRight() {
        sendCode("7A859E61")
    }
    func sendBack() {
        sendCode("7A85AA55")
    }
    func sendEnter() {
        sendCode("7A85DE21")
    }

}
