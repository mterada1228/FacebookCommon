//
//  MessengerShareViewController.swift
//  FacebookCommon
//
//  Created by 寺田優 on 2019/11/29.
//  Copyright © 2019 寺田優. All rights reserved.
//

import UIKit

// presenter output
extension MessangerShareViewController: MessengerSharePresenterOutput {
    // Alertの表示
    func showAlert(_ alertController: UIAlertController) {
        present(alertController, animated: true)
    }
}

class MessangerShareViewController: UIViewController {

    // Injecting presenterInput
    private var presenter: MessengerSharePresenterInput!
    
    func inject(presenter: MessengerSharePresenterInput){
        self.presenter = presenter
    }
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        
        // Presenter, Modelのインスタンス化
        let messengerShareModel = MessangerShareModel()
        let apiMannegerModel = APIMannegerModel()
        let messengerSharePresenter = MessengerSharePresenter(view: self,
                                                        messengerShareModel: messengerShareModel,
                                                        apiMannegerModel: apiMannegerModel)
        
        self.inject(presenter: messengerSharePresenter)
    }

    @IBOutlet weak var imageView: UIImageView!
    
    // Messanger Shareを実行
    @IBAction func messengerShareBtn(_ sender: Any) {
        // presenterロジックを呼び出す
        presenter.didTapMessengerShareBtn(image: imageView.image!)
    }
    
}

