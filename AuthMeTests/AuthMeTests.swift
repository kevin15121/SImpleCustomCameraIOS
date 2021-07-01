//
//  AuthMeTests.swift
//  AuthMeTests
//
//  Created by zencher on 2021/6/29.
//

import XCTest
import RxTest
import RxSwift
import RxCocoa

@testable import AuthMe

class AuthMeTests: XCTestCase {
    var scheduler: TestScheduler!
    var disposeBag: DisposeBag!
    override func setUpWithError() throws {
        scheduler = TestScheduler(initialClock: 0)
        disposeBag = DisposeBag()
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }

    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }

    func testTakePhoto() throws {
    }
    

    func testPerformanceExample() throws {
        // This is an example of a performance test case.
        self.measure {
            // Put the code you want to measure the time of here.
        }
    }

}
