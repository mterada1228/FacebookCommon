//
//  MessangerShareModel.swift
//  FacebookCommon
//
//  Created by 寺田優 on 2019/11/29.
//  Copyright © 2019 寺田優. All rights reserved.
//

import Foundation
import FBSDKShareKit

protocol MessangerShareModelInput {
    
    // MessangerでmediaTempleteを使用してShareする
    func sendMediaTempleteContent (
        attachmentId: String, // 必須
        pageID: String, // 必須
        url: String?,
        urlBtnTitle: String?,
        completion: @escaping (Result<String, String>) -> ())
    
    // Messanger App の DL ページに遷移する
    func showMessangerAppDLLink (
        openUrl : URL
    )
}

final class MessangerShareModel: MessangerShareModelInput {
    
    // MessangerでmediaTempleteを使用してShareする
       func sendMediaTempleteContent (
           attachmentId: String,
           pageID: String,
           url: String?,
           urlBtnTitle: String?,
           completion: @escaping (Result<String, String>) -> ()) {
           
           // MediaTenpleteのcontentをインスタンス化する
           let content = ShareMessengerMediaTemplateContent(attachmentID: attachmentId)
           // コンテンツのプロパティを設定する
           content.mediaType = ShareMessengerMediaTemplateMediaType.image // 画像を送信するメディアテンプレート
           content.pageID = pageID
           
           // urlButtonを設定する
           if let urlBtnTitleStr: String = urlBtnTitle, let linkUrl: URL = URL(string: url!) {
               let urlButton = ShareMessengerURLActionButton()
               urlButton.title = urlBtnTitleStr
               urlButton.url = linkUrl
               content.button = urlButton
           }
           
           // Message DiaLogを返す
           let dialog = MessageDialog();
           dialog.shareContent = content
           
           DispatchQueue.main.async {
               // メインスレッドでMessangeのシェアを実行する
               if dialog.show() {
                   // 成功ステータスを返す
                   completion(.success("messanger share success"))
               } else {
                   completion(.failure("messanger share failed"))
               }
           }
       }
       
       // Messanger App の DL ページに遷移する
       func showMessangerAppDLLink (openUrl : URL){
           // URLを開けるかをチェックする
           if UIApplication.shared.canOpenURL(openUrl) {
               // URLを開く
               UIApplication.shared.open(openUrl, options: [:]) { success in
                   if success {
                       print("Launching \(openUrl) was successful")
                   }
               }
           }
       }

    
}
