//
//  APIManegerCommon.swift
//  FacebookCommon
//
//  Created by 寺田優 on 2019/11/29.
//  Copyright © 2019 寺田優. All rights reserved.
//

import Foundation
import Alamofire

// result タイプのセット
enum Result<T,Error> {
    case success(T)
    case failure(Error)
}

protocol APIMannegerModelInput {
    // multipart/form-data形式 で post request を実行する
    func postByMultipartFormData (
        requestUrl: String,
        params: [String : Any],
        image: UIImage,
        completion: @escaping (Result<DataResponse<Any>, APIManegerError>) -> () )
}

enum APIManegerError : Error {
    case urlError(message: String)
    case parameterError(message: String)
    case imageError(message: String)
    case uploadError(error: Error)
}

final class APIMannegerModel: APIMannegerModelInput {
    
    // multipart/form-data形式 で post request を実行する
    func postByMultipartFormData (
        requestUrl: String,
        params: [String : Any],
        image: UIImage,
        completion: @escaping (Result<DataResponse<Any>, APIManegerError>) -> () ) {
        
        // request url の有効性をチェック
        guard let _ : URL = URL(string: requestUrl) else {
            return completion(.failure(.urlError(message: "有効なURLではありません")))
        }
        
        // paramをJSONArray -> Dataに変換する
        let jsonParams: Data?
        do {
            jsonParams = try JSONSerialization.data(withJSONObject: params, options: .prettyPrinted)
        } catch {
            return completion(.failure(.parameterError(message: "有効なパラメータではありません")))
        }
        
        // imageをDataに変換する
        guard let dataImage : Data = image.jpegData(compressionQuality:1.0) else {
            return completion(.failure(.imageError(message: "有効な画像ではありません")))
        }
        
        // API送信
        Alamofire.upload(
            multipartFormData: { multipartFormData in
                // 送信する値の指定
                multipartFormData.append(dataImage,
                                         withName: "image",
                                         fileName: "hometoke.jpeg",
                                         mimeType: "image/jpeg")
                multipartFormData.append(jsonParams!,
                                         withName: "message")
        },
            to: requestUrl, // 送信先URL
            // API送信の実行
            encodingCompletion: { encodingResult in
                switch encodingResult {
                case .success(let upload, _, _):
                    upload.responseJSON { response in
                        completion(.success(response))
                    }
                case .failure(let encodingError):
                    // 失敗
                    completion(.failure(.uploadError(error: encodingError)))
                }
        }
        )
    }
    
}

