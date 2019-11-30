//
//  MessengerSharePresenter.swift
//  FacebookCommon
//
//  Created by 寺田優 on 2019/11/29.
//  Copyright © 2019 寺田優. All rights reserved.
//

import Foundation
import UIKit

protocol MessengerSharePresenterInput {
    func didTapMessengerShareBtn(image: UIImage?)
}

protocol MessengerSharePresenterOutput: AnyObject {
    func showAlert(_ alertController: UIAlertController)
}

final class MessengerSharePresenter: MessengerSharePresenterInput {
    
    private weak var view : MessengerSharePresenterOutput!
    private var messengerShareModel: MessangerShareModelInput!
    private var apiMannegerModel: APIMannegerModelInput!
    
    // TODO アプリごとに設定する値
    private let accessToken = "<facebookページのアクセストークンを設定する>"
    private let pageID = "<facebookページのIDを設定する>"
    private let urlBtnTitle = "<シェアするURLボタンのタイトルを設定>"
    private let urlString = "<シェアするURLボタンのURLをStringで設定>"
    
    // attachment upload APIのレスポンスを変換するためにCodableを定義
    struct AttachmentId: Codable {
        let attachment_id: String
    }
    
    // initialize
    init(view: MessengerSharePresenterOutput,
         messengerShareModel: MessangerShareModelInput,
         apiMannegerModel: APIMannegerModelInput) {
        self.view = view
        self.messengerShareModel = messengerShareModel
        self.apiMannegerModel = apiMannegerModel
    }
    
    // Messanger Share Btn 押下時の処理
    func didTapMessengerShareBtn(image: UIImage?) {
        
        // attachment apload api 関連の定数を設定
        // アクセストークン (ホメトケfacebook pageのアクセストークン)
        let accessToken = self.accessToken
        // リクエストURL（attachment upload API）
        let requestUrl = "https://graph.facebook.com/v2.6/me/message_attachments?access_token=\(accessToken)"
        // リクエストパラメータ
        let params:[String:Any] = [
            "attachment":[
                "type":"image",
                "payload":[
                    "is_reusable": true
                ]
            ]
        ]
        
        // 入力値のunwrap
        guard let unwrappedImage: UIImage = image else {
            // TODO エラーハンドリングは別途検討する
            print("入力として利用できる型ではありません")
            return
        }
        
        apiMannegerModel.postByMultipartFormData(requestUrl: requestUrl,
                                                 params: params,
                                                 image: unwrappedImage){ result in
                                                    switch result {
                                                    // Upload API成功時
                                                    case .success(let responce):
                                                        // attachment IDを取得する
                                                        if let data = responce.data {
                                                            
                                                            // responceをAttachmentIdに変換する。
                                                            let responceDataJson: AttachmentId
                                                            do {
                                                                responceDataJson = try JSONDecoder().decode(AttachmentId.self, from: data)
                                                            } catch {
                                                                // TODO エラーハンドリングは別途検討する
                                                                print("Json Decode error")
                                                                return
                                                            }
                                                            
                                                            // attachmentIdを取得する
                                                            let attachmentID: String = responceDataJson.attachment_id
                                                            
                                                            // Messanger Share 関連の定数を設定
                                                            // ページID（ホメトケfacebook page）
                                                            let pageID = self.pageID
                                                            // URL buttonに表示する名前を設定
                                                            let urlBtnTitle = self.urlBtnTitle
                                                            // URL button tap時のリンク先（App Storeのダウンロードリンク）
                                                            let urlString = self.urlString
                                                            // 日本語を含むとURLに変換できない。パーセントエンコーディングする。
                                                            let encodeUrlString: String = urlString.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)!
                                                            
                                                            // QRコードを添付してMessangerにShareする
                                                            self.messengerShareModel.sendMediaTempleteContent(attachmentId: attachmentID,
                                                                                                             pageID: pageID,
                                                                                                             url: encodeUrlString,
                                                                                                             urlBtnTitle: urlBtnTitle) { [weak self] result in
                                                                                                                switch result {
                                                                                                                case .success(let message):
                                                                                                                    // 成功時の処理
                                                                                                                    print(message)
                                                                                                                case .failure(let message):
                                                                                                                    // 失敗時の処理 -> Alertを表示してMessangerのDLLinkに遷移する
                                                                                                                    let alertController = UIAlertController(title: "エラー",
                                                                                                                                                            message: "Messangerアプリがインストールされていないか、最新版ではありません。アプリのダウンロードページに移動します",
                                                                                                                                                            preferredStyle: .alert)
                                                                                                                    alertController.addAction(UIAlertAction(title: "OK",
                                                                                                                                                            style: .default,
                                                                                                                                                            handler: {
                                                                                                                                                                (action: UIAlertAction!) -> Void in
                                                                                                                                                                self?.messengerShareModel.showMessangerAppDLLink(openUrl: URL(string: "https://apps.apple.com/jp/app/messenger/id454638411")!)
                                                                                                                    }))
                                                                                                                    self?.view.showAlert(alertController)
                                                                                                                }
                                                            }
                                                        }
                                                    case .failure(let error):
                                                        // TODO エラーハンドリングは別途検討する
                                                        print(error)
                                                    }
        }
    }
}
