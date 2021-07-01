//
//  CameraController.swift
//  AuthMe
//
//  Created by zencher on 2021/6/30.
//

import Foundation
import UIKit
import AVFoundation
import RxCocoa
import RxSwift
protocol CameraProtocol {
    func takePhoto()->Observable<UIImage>
    func prepare()->Single<Void>
    func getPreviewLayer(frame:CGRect)->Single<CALayer>
}
enum CameraControllerError:LocalizedError, Error {
    case captureSessionAlreadyRunning
    case captureSessionIsMissing
    case inputsAreInvalid
    case invalidOperation
    case noCamerasAvailable
    case noPreview
    case unknown
    public var errorDescription: String? {
       switch self {
       case .captureSessionAlreadyRunning: return "Session Already Running"
       case .captureSessionIsMissing:return "Session Is Missing"
       case .inputsAreInvalid:return "Inputs Are Invalid"
       case .invalidOperation:return "Invalid Operation"
       case .noCamerasAvailable:return "No Cameras Available"
       case .noPreview:return "No Preview"
       case .unknown:return "unknown"
     }
   }
}
class CameraController: NSObject {
    private let previewLayerRelay = PublishSubject<CALayer>()
    private(set) lazy var previewLayerObservable = previewLayerRelay.asObservable()
    
    private let imageSubject = PublishSubject<UIImage>()
    public enum CameraPosition {
        case front
        case rear
    }
  
    var captureSession: AVCaptureSession?
    var frontCamera: AVCaptureDevice?
    var rearCamera: AVCaptureDevice?
    var currentCameraPosition: CameraPosition?
    var frontCameraInput: AVCaptureDeviceInput?
    var rearCameraInput: AVCaptureDeviceInput?
    var photoOutput: AVCapturePhotoOutput?
    var previewLayer: AVCaptureVideoPreviewLayer?
}
extension CameraController: AVCapturePhotoCaptureDelegate {
    func photoOutput(_ output: AVCapturePhotoOutput, didFinishProcessingPhoto photo: AVCapturePhoto, error: Error?) {
        
        if let imageData = photo.fileDataRepresentation(), let image = UIImage(data: imageData) {
            imageSubject.onNext(image)
        }
    }
}

extension CameraController:CameraProtocol{
    func prepare() -> Single<Void> {
        return Single<Void>.create{
            single -> Disposable in
            func createCaptureSession() {
                self.captureSession = AVCaptureSession()
            }
            
            func configureCaptureDevices() throws {
                let session = AVCaptureDevice.DiscoverySession(deviceTypes: [.builtInTrueDepthCamera, .builtInDualCamera, .builtInWideAngleCamera], mediaType: AVMediaType.video, position: .unspecified)
                let cameras = session.devices.compactMap { $0 }
                
                guard !cameras.isEmpty else { throw CameraControllerError.noCamerasAvailable }
                for camera in cameras {
                    if camera.position == .front {
                        self.frontCamera = camera
                    }
                    
                    if camera.position == .back {
                        self.rearCamera = camera
                        
                        try camera.lockForConfiguration()
                        camera.focusMode = .continuousAutoFocus
                        camera.unlockForConfiguration()
                    }
                }
            }
            func configureDeviceInputs() throws {
                guard let captureSession = self.captureSession else { throw CameraControllerError.captureSessionIsMissing }
                if let rearCamera = self.rearCamera {
                    self.rearCameraInput = try AVCaptureDeviceInput(device: rearCamera)
                    
                    if captureSession.canAddInput(self.rearCameraInput!) { captureSession.addInput(self.rearCameraInput!) }
                    
                    self.currentCameraPosition = .rear
                }
                
                else if let frontCamera = self.frontCamera {
                    self.frontCameraInput = try AVCaptureDeviceInput(device: frontCamera)
                    
                    if captureSession.canAddInput(self.frontCameraInput!) { captureSession.addInput(self.frontCameraInput!) }
                    else { throw CameraControllerError.inputsAreInvalid }
                    
                    self.currentCameraPosition = .front
                }
                
                else { throw CameraControllerError.noCamerasAvailable }
            }
            func configurePhotoOutput() throws {
                guard let captureSession = self.captureSession else { throw CameraControllerError.captureSessionIsMissing }
                
                self.photoOutput = AVCapturePhotoOutput()
                self.photoOutput!.setPreparedPhotoSettingsArray([AVCapturePhotoSettings(format: [AVVideoCodecKey : AVVideoCodecType.jpeg])], completionHandler: nil)
                self.photoOutput?.connection(with: .video)?.videoOrientation = .portrait
                
                if captureSession.canAddOutput(self.photoOutput!) { captureSession.addOutput(self.photoOutput!) }
                
                captureSession.startRunning()
            }
            
            DispatchQueue(label: "prepare").async {
                do {
                    createCaptureSession()
                    try configureCaptureDevices()
                    try configureDeviceInputs()
                    try configurePhotoOutput()
                    
                }
                
                catch {
                    DispatchQueue.main.async {
                        single(.failure(error))
                    }
                    
                    return
                }
                
                DispatchQueue.main.async {
                    single(.success(()))
                }
            }
            
            return Disposables.create()
        }
    }
    
    func getPreviewLayer(frame:CGRect) -> Single<CALayer> {
        return Single<CALayer>.create{
            single in
            let disposable = Disposables.create()
            guard let captureSession = self.captureSession, captureSession.isRunning else {
                single(.failure( CameraControllerError.captureSessionIsMissing))
                return disposable
            }
            
            self.previewLayer = AVCaptureVideoPreviewLayer(session: captureSession)
            self.previewLayer?.videoGravity = .resizeAspect
            self.previewLayer?.frame = frame
            self.previewLayer?.connection?.videoOrientation = .portrait
            if let layer = self.previewLayer{
                single(.success(layer))
            }else{
                single(.failure(CameraControllerError.noPreview))
            }
            return disposable
        }
    }
    
    
    func takePhoto()->Observable<UIImage>{
        guard let captureSession = captureSession, captureSession.isRunning else {
            return .error(CameraControllerError.captureSessionIsMissing)
        }
        let settings = AVCapturePhotoSettings()
        self.photoOutput?.capturePhoto(with: settings, delegate: self)
        return imageSubject.asObservable()
    }
}
