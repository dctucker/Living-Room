//
//  SessionDelegate.swift
//  Living Room WatchKit Extension
//
//  Created by Douglas Casey Tucker on 1/17/18.
//  Copyright © 2018 Douglas Casey Tucker. All rights reserved.
//

import Foundation

typealias CompleteHandlerBlock = () -> ()

class SessionDelegate : NSObject, URLSessionDelegate {
    static let sharedInstance = SessionDelegate()
    var handlerQueue = [String : CompleteHandlerBlock]()
    
    //MARK: session delegate
    func urlSession(_ session: URLSession, didBecomeInvalidWithError error: Error?) {
        print("session error: \(String(describing: error?.localizedDescription)).")
    }
    
    func URLSession(session: URLSession, downloadTask: URLSessionDownloadTask, didFinishDownloadingToURL location: NSURL) {
        print("session \(session) has finished the download task \(downloadTask) of URL \(location).")
    }
    
    func URLSession(session: URLSession, downloadTask: URLSessionDownloadTask, didWriteData bytesWritten: Int64, totalBytesWritten: Int64, totalBytesExpectedToWrite: Int64) {
        print("session \(session) download task \(downloadTask) wrote an additional \(bytesWritten) bytes (total \(totalBytesWritten) bytes) out of an expected \(totalBytesExpectedToWrite) bytes.")
    }
    
    func URLSession(session: URLSession, downloadTask: URLSessionDownloadTask, didResumeAtOffset fileOffset: Int64, expectedTotalBytes: Int64) {
        print("session \(session) download task \(downloadTask) resumed at offset \(fileOffset) bytes out of an expected \(expectedTotalBytes) bytes.")
    }
    
    func URLSession(session: URLSession, task: URLSessionTask, didCompleteWithError error: NSError?) {
        if error == nil {
            print("session \(session) download completed")
        } else {
            print("session \(session) download failed with error \(error?.localizedDescription ?? "")")
        }
    }
    
    private func URLSessionDidFinishEventsForBackgroundURLSession(session: URLSession) {
        print("background session \(session) finished events.")
        
        if !session.configuration.identifier!.isEmpty {
            callCompletionHandlerForSession(identifier: session.configuration.identifier)
        }
    }
    
    //MARK: completion handler
    func addCompletionHandler(handler: @escaping CompleteHandlerBlock, identifier: String) {
        handlerQueue[identifier] = handler
    }
    
    func callCompletionHandlerForSession(identifier: String!) {
        let handler : CompleteHandlerBlock = handlerQueue[identifier]!
        handlerQueue.removeValue(forKey: identifier)
        handler()
    }
}
