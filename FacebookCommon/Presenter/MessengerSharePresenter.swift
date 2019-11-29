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
}

final class MessengerSharePresenter: MessengerSharePresenterInput {
    
    private weak var view : MessengerSharePresenterOutput!
    private var messengerShareModel: MessangerShareModelInput!
    private var apiMannegerModel: APIMannegerModelInput!
    
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
    }
    
}
