//
//  StartViewController.swift
//  AuthMe
//
//  Created by zencher on 2021/7/1.
//

import UIKit
import RxCocoa
import RxSwift
class StartViewController: UIViewController {
    
    @IBOutlet weak var startButton: UIButton!
    @IBOutlet weak var imageView: UIImageView!
    var disposeBag = DisposeBag()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        startButton.rx.tap.subscribe(onNext:{
            _ in
            self.popPreviewUIViewController()
        }).disposed(by: disposeBag)
    }
    
    
    func popPreviewUIViewController(){
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let vc = storyboard.instantiateViewController(withIdentifier: "Preview") as! ViewController
        let viewModel = PreviewViewModel(cameraController: CameraController())
        vc.bindViewModel(viewModel: viewModel)
        viewModel.image.subscribe (onNext: {(image) in
            self.imageView.image = image
            vc.dismiss(animated: true, completion: nil)
        }).disposed(by: disposeBag)

        present(vc, animated: true, completion: nil)
    }
    
}
