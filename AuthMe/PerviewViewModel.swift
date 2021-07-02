//
//  ViewModel.swift
//  AuthMe
//
//  Created by zencher on 2021/6/29.
//

import Foundation
import UIKit
import RxSwift
import RxCocoa
enum ViewStatus {
    case cameraPreparing
    case cameraReady
    case cameraError(error:Error)
    case captureError(error:Error)
    case processing
    case preview
    case displaying
}
class PreviewViewModel{
    private let viewStatusRelay = BehaviorRelay<ViewStatus>(value: .preview)
    private(set) lazy var viewStatus = viewStatusRelay.asObservable()
    private let imageRelay = PublishSubject<UIImage>()
    private(set) lazy var image = imageRelay.asObservable()
    let cameraController:CameraProtocol!
    var disposeBag = DisposeBag()
    
    init(cameraController:CameraProtocol){
        self.cameraController = cameraController
    }
    func preview(){
        viewStatusRelay.accept(.preview)
    }
    func takePhoto(){
        self.viewStatusRelay.accept(.processing)
        let tackPhotoResult = cameraController.takePhoto()
        tackPhotoResult.subscribe(onNext:{
            image in
            self.imageRelay.onNext(image)
            self.viewStatusRelay.accept(.displaying)
        },onError:{
            error in
            self.viewStatusRelay.accept(.captureError(error:error))
        }).disposed(by: disposeBag)
//        tackPhotoResult.subscribe(onNext:{
//            image in
//        },onError: {
//            error in
//            self.viewStatusRelay.accept(.cameraError(error: error))
//        }).disposed(by: disposeBag)
    }
    func getPreviewCALayer(frame:CGRect)->Single<CALayer>{
        return cameraController.getPreviewLayer(frame: frame)
    }
    func prepareCamera(){
        let prepareResult = cameraController.prepare()
        prepareResult.subscribe(onSuccess: {
            _ in
            self.viewStatusRelay.accept(.cameraReady)
        }, onFailure: {error in
            self.viewStatusRelay.accept(.cameraError(error: error))
        }).disposed(by: disposeBag)
    }
}
