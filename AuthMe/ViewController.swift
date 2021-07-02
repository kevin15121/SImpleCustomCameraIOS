//
//  ViewController.swift
//  AuthMe
//
//  Created by zencher on 2021/6/29.
//

import UIKit
import RxCocoa
import RxSwift
import AVFoundation
import Photos
class ViewController: UIViewController {
    @IBOutlet weak var errorUIView: UIView!
    @IBOutlet weak var errorLabel: UILabel!
    @IBOutlet weak var photoUIView: UIView!
    @IBOutlet weak var indicatorView: UIView!
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var takePhotoButton: UIButton!
    @IBOutlet weak var backToPreviewButton: UIButton!
    @IBOutlet weak var previewUIView: UIView!
    var viewModel:PreviewViewModel!
    var disposeBag = DisposeBag()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        imageView.contentMode = .scaleAspectFit
        viewModel.viewStatus
            .subscribe(onNext:handleDisplayStatus)
            .disposed(by:disposeBag)
        viewModel.prepareCamera()
        setupButtonEvents()
    }
    func bindViewModel(viewModel:PreviewViewModel){
        self.viewModel = viewModel
    }
    func setupButtonEvents(){
        takePhotoButton.rx.tap.subscribe(onNext:{
            self.viewModel.takePhoto()
        }).disposed(by: disposeBag)
        backToPreviewButton.rx.tap.subscribe(onNext:{
            self.viewModel.preview()
        }).disposed(by: disposeBag)
    }
    
    func handleDisplayStatus(status:ViewStatus){
        switch status {
        case .cameraReady:
            requestPreviewCALayerThenInsertToPreviewUIView()
        default:
            let viewShouldDisplay = view(status: status)
            viewShouldDisplay.superview?.bringSubviewToFront(viewShouldDisplay)
        }
    }
    func requestPreviewCALayerThenInsertToPreviewUIView(){
        viewModel.getPreviewCALayer(frame: self.previewUIView.bounds)
            .subscribe(onSuccess:{
            layer in
            DispatchQueue.main.async {
                self.previewUIView.layer.insertSublayer(layer, at: 0)
            }
        }).disposed(by: disposeBag)
    }
}
extension ViewController{
    func view(status:ViewStatus)->UIView{
        switch status {
        case .cameraPreparing,.cameraReady,.processing:
            return indicatorView
        case .cameraError(error: let error):
            errorLabel.text = error.localizedDescription
            return errorUIView
        case .captureError(error: let error):
            let alert = UIAlertController(title: "Error", message:  error.localizedDescription, preferredStyle: .alert)
            present(alert, animated: true, completion: nil)
            return previewUIView
        case .preview:
            return previewUIView
        case .displaying:
            return photoUIView
        }
    }
}
