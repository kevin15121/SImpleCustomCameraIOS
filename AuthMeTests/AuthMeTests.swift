//
//  AuthMeTests.swift
//  AuthMeTests
//
//  Created by zencher on 2021/6/29.
//

import XCTest
//import RxTest
import RxSwift
//import RxCocoa

@testable import AuthMe

class AuthMeTests: XCTestCase {
    override func setUpWithError() throws {

        // Put setup code here. This method is called before the invocation of each test method in the class.
    }

    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }

    func testTakePhotoSuccess() throws {
        let disposeBag = DisposeBag()
        let mockCameraController = createTakePhotoSuccessMock()
        let expect = expectation(description: #function)
        var expectedUIImage:UIImage? = nil
        let viewModel = PreviewViewModel(cameraController: mockCameraController)
        viewModel.image.subscribe(onNext:{
            image in
            expectedUIImage = image
            expect.fulfill()
        }).disposed(by: disposeBag)
        viewModel.takePhoto()
        waitForExpectations(timeout: 1.0) { error in
          guard error == nil else {
            XCTFail(error!.localizedDescription)
            return
          }
        }
        XCTAssertNotNil(expectedUIImage)
        
    }
    
    
    func createTakePhotoSuccessMock()->CameraProtocol{
        class Mock:CameraProtocol{
            func takePhoto() -> Observable<UIImage> {
                return Observable<UIImage>.create { (observable) -> Disposable in
                    observable.onNext(UIImage())
                    return Disposables.create()
                }
            }
            func prepare() -> Single<Void> {
                return Single<Void>.create { (single) -> Disposable in
                    return Disposables.create()
                }
            }
            
            func getPreviewLayer(frame: CGRect) -> Single<CALayer> {
                return Single<CALayer>.create { (single) -> Disposable in
                    return Disposables.create()
                }
            }
        }
        return Mock()
    }

    func testTakePhotoFailure() throws {
        let disposeBag = DisposeBag()
        let mockCameraController = createTakePhotoFailureMock()
        let expect = expectation(description: #function)
        var expectedError:CameraControllerError? = nil
        let viewModel = PreviewViewModel(cameraController: mockCameraController)
        viewModel.viewStatus.subscribe(onNext:{
            status in
            if case let .captureError(error) = status{
                expectedError = error as? CameraControllerError
                expect.fulfill()
            }
           
        }).disposed(by: disposeBag)
        viewModel.takePhoto()
        waitForExpectations(timeout: 1.0) { error in
          guard error == nil else {
            XCTFail(error!.localizedDescription)
            return
          }
        }
        XCTAssertEqual(expectedError, CameraControllerError.captureSessionIsMissing)
        
    }
    
    
    func createTakePhotoFailureMock()->CameraProtocol{
        class Mock:CameraProtocol{
            func takePhoto() -> Observable<UIImage> {
                return Observable<UIImage>.create { (observable) -> Disposable in
                    observable.onError(CameraControllerError.captureSessionIsMissing)
                    return Disposables.create()
                }
            }
            func prepare() -> Single<Void> {
                return Single<Void>.create { (single) -> Disposable in
                    return Disposables.create()
                }
            }
            
            func getPreviewLayer(frame: CGRect) -> Single<CALayer> {
                return Single<CALayer>.create { (single) -> Disposable in
                    return Disposables.create()
                }
            }
        }
        return Mock()
    }

}
