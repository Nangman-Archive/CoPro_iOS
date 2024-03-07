//
//  ImageUploader.swift
//  CoPro
//
//  Created by 문인호 on 2/16/24.
//

import Foundation
import UIKit

class ImageUploader: NSObject {
    private var session: URLSession!
    private var uploadTasks: [URLSessionTask] = []
    
    func uploadImages(images: [UIImage]) {
        let configuration = URLSessionConfiguration.default
        session = URLSession(configuration: configuration, delegate: self, delegateQueue: nil)
        
        for image in images {
            guard let imageData = image.jpegData(compressionQuality: 0.8) else {
                print("Failed to convert image to data")
                continue
            }
            
            let url = URL(string: Config.baseURL)!
            var request = URLRequest(url: url.appendingPathComponent("/api/v1/images"))
            request.httpMethod = "POST"
            
            let task = session.uploadTask(with: request, from: imageData)
            task.delegate = self
            uploadTasks.append(task)
            
            task.resume()
        }
    }
}

extension ImageUploader: URLSessionTaskDelegate {
    func urlSession(_ session: URLSession, task: URLSessionTask, didSendBodyData bytesSent: Int64, totalBytesSent: Int64, totalBytesExpectedToSend: Int64) {
        guard let index = uploadTasks.firstIndex(of: task) else { return }
        let progress = Double(totalBytesExpectedToSend) / Double(totalBytesSent)
        print("image \(index + 1): \(progress)")
    }
}
