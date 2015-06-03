
//
//  Observable+TimeTest.swift
//  Rx
//
//  Created by Krunoslav Zaher on 3/23/15.
//  Copyright (c) 2015 Krunoslav Zaher. All rights reserved.
//

import Foundation
import RxSwift
import XCTest

class ObservableTimeTest : RxTest {
    override func setUp() {
        super.setUp()
    }
    
    override func tearDown() {
        super.tearDown()
    }
}

// throttle

extension ObservableTimeTest {
    func test_ThrottleTimeSpan_AllPass() {
        let scheduler = TestScheduler(initialClock: 0)
        
        let xs = scheduler.createHotObservable([
            next(150, 0),
            next(210, 1),
            next(240, 2),
            next(270, 3),
            next(300, 4),
            completed(400)
            ])
        
        let res = scheduler.start {
            xs >- throttle(20, scheduler)
        }
        
        let correct = [
            next(230, 1),
            next(260, 2),
            next(290, 3),
            next(320, 4),
            completed(400)
        ]
        
        XCTAssertEqual(res.messages, correct)
        
        let subscriptions = [
            Subscription(200, 400)
        ]
        
        XCTAssertEqual(xs.subscriptions, subscriptions)
    }
    
    func test_ThrottleTimeSpan_AllPass_ErrorEnd() {
        let scheduler = TestScheduler(initialClock: 0)
        
        let xs = scheduler.createHotObservable([
            next(150, 0),
            next(210, 1),
            next(240, 2),
            next(270, 3),
            next(300, 4),
            error(400, testError)
            ])
        
        let res = scheduler.start {
            xs >- throttle(20, scheduler)
        }
        
        let correct = [
            next(230, 1),
            next(260, 2),
            next(290, 3),
            next(320, 4),
            error(400, testError)
        ]
        
        XCTAssertEqual(res.messages, correct)
        
        let subscriptions = [
            Subscription(200, 400)
        ]
        
        XCTAssertEqual(xs.subscriptions, subscriptions)
    }
    
    func test_ThrottleTimeSpan_AllDrop() {
        let scheduler = TestScheduler(initialClock: 0)
        
        let xs = scheduler.createHotObservable([
            next(150, 0),
            next(210, 1),
            next(240, 2),
            next(270, 3),
            next(300, 4),
            next(330, 5),
            next(360, 6),
            next(390, 7),
            completed(400)
            ])
        
        let res = scheduler.start {
            xs >- throttle(40, scheduler)
        }
        
        let correct = [
            next(400, 7),
            completed(400)
        ]
        
        XCTAssertEqual(res.messages, correct)
        
        let subscriptions = [
            Subscription(200, 400)
        ]
        
        XCTAssertEqual(xs.subscriptions, subscriptions)
    }
    
    func test_ThrottleTimeSpan_AllDrop_ErrorEnd() {
        let scheduler = TestScheduler(initialClock: 0)
        
        let xs = scheduler.createHotObservable([
            next(150, 0),
            next(210, 1),
            next(240, 2),
            next(270, 3),
            next(300, 4),
            next(330, 5),
            next(360, 6),
            next(390, 7),
            error(400, testError)
            ])
        
        let res = scheduler.start {
            xs >- throttle(40, scheduler)
        }
        
        let correct: [Recorded<Int>] = [
            error(400, testError)
        ]
        
        XCTAssertEqual(res.messages, correct)
        
        let subscriptions = [
            Subscription(200, 400)
        ]
        
        XCTAssertEqual(xs.subscriptions, subscriptions)
    }
    
    func test_ThrottleEmpty() {
        let scheduler = TestScheduler(initialClock: 0)
        
        let xs = scheduler.createHotObservable([
            next(150, 0),
            completed(300)
            ])
        
        let res = scheduler.start {
            xs >- throttle(10, scheduler)
        }
        
        let correct: [Recorded<Int>] = [
            completed(300)
        ]
        
        XCTAssertEqual(res.messages, correct)
        
        let subscriptions = [
            Subscription(200, 300)
        ]
        
        XCTAssertEqual(xs.subscriptions, subscriptions)
    }
    
    func test_ThrottleError() {
        let scheduler = TestScheduler(initialClock: 0)
        
        let xs = scheduler.createHotObservable([
            next(150, 0),
            error(300, testError)
            ])
        
        let res = scheduler.start {
            xs >- throttle(10, scheduler)
        }
        
        let correct: [Recorded<Int>] = [
            error(300, testError)
        ]
        
        XCTAssertEqual(res.messages, correct)
        
        let subscriptions = [
            Subscription(200, 300)
        ]
        
        XCTAssertEqual(xs.subscriptions, subscriptions)
    }
    
    func test_ThrottleNever() {
        let scheduler = TestScheduler(initialClock: 0)
        
        let xs = scheduler.createHotObservable([
            next(150, 0),
            ])
        
        let res = scheduler.start {
            xs >- throttle(10, scheduler)
        }
        
        let correct: [Recorded<Int>] = [
        ]
        
        XCTAssertEqual(res.messages, correct)
        
        let subscriptions = [
            Subscription(200, 1000)
        ]
        
        XCTAssertEqual(xs.subscriptions, subscriptions)
    }
    
    func test_ThrottleSimple() {
        let scheduler = TestScheduler(initialClock: 0)
       
        let xs = scheduler.createHotObservable([
            next(150, 0),
            next(210, 1),
            next(240, 2),
            next(250, 3),
            next(280, 4),
            completed(300)
            ])
        
        let res = scheduler.start {
            xs >- throttle(20, scheduler)
        }
        
        let correct: [Recorded<Int>] = [
            next(230, 1),
            next(270, 3),
            next(300, 4),
            completed(300)
        ]
        
        XCTAssertEqual(res.messages, correct)
        
        let subscriptions = [
            Subscription(200, 300)
        ]
        
        XCTAssertEqual(xs.subscriptions, subscriptions)
    }
}

// sample

extension ObservableTimeTest {
    func testSample_Sampler_SamplerThrows() {
        let scheduler = TestScheduler(initialClock: 0)
        
        let xs = scheduler.createHotObservable([
            next(150, 1),
            next(220, 2),
            next(240, 3),
            next(290, 4),
            next(300, 5),
            next(310, 6),
            completed(400)
            ])
        
        let ys = scheduler.createHotObservable([
            next(150, ""),
            next(210, "bar"),
            next(250, "foo"),
            next(260, "qux"),
            error(320, testError)
            ])
        
        let res = scheduler.start {
            xs >- sample(ys)
        }
        
        let correct: [Recorded<Int>] = [
            next(250, 3),
            error(320, testError)
        ]
        
        XCTAssertEqual(res.messages, correct)
        
        XCTAssertEqual(xs.subscriptions, [
            Subscription(200, 320)
        ])

        XCTAssertEqual(ys.subscriptions, [
            Subscription(200, 320)
        ])
    }
    
    func testSample_Sampler_Simple1() {
        let scheduler = TestScheduler(initialClock: 0)
        
        let xs = scheduler.createHotObservable([
            next(150, 1),
            next(220, 2),
            next(240, 3),
            next(290, 4),
            next(300, 5),
            next(310, 6),
            completed(400)
            ])
        
        let ys = scheduler.createHotObservable([
            next(150, ""),
            next(210, "bar"),
            next(250, "foo"),
            next(260, "qux"),
            next(320, "baz"),
            completed(500)
            ])
        
        let res = scheduler.start {
            xs >- sample(ys)
        }
        
        let correct: [Recorded<Int>] = [
            next(250, 3),
            next(320, 6),
            completed(500)
        ]
        
        XCTAssertEqual(res.messages, correct)
        
        XCTAssertEqual(xs.subscriptions, [
            Subscription(200, 400)
            ])
        
        XCTAssertEqual(ys.subscriptions, [
            Subscription(200, 500)
            ])
    }
    
    func testSample_Sampler_Simple2() {
        let scheduler = TestScheduler(initialClock: 0)
        
        let xs = scheduler.createHotObservable([
            next(150, 1),
            next(220, 2),
            next(240, 3),
            next(290, 4),
            next(300, 5),
            next(310, 6),
            next(360, 7),
            completed(400)
            ])
        
        let ys = scheduler.createHotObservable([
            next(150, ""),
            next(210, "bar"),
            next(250, "foo"),
            next(260, "qux"),
            next(320, "baz"),
            completed(500)
            ])
        
        let res = scheduler.start {
            xs >- sample(ys)
        }
        
        let correct: [Recorded<Int>] = [
            next(250, 3),
            next(320, 6),
            next(500, 7),
            completed(500)
        ]
        
        XCTAssertEqual(res.messages, correct)
        
        XCTAssertEqual(xs.subscriptions, [
            Subscription(200, 400)
            ])
        
        XCTAssertEqual(ys.subscriptions, [
            Subscription(200, 500)
            ])
    }
    
    func testSample_Sampler_Simple3() {
        let scheduler = TestScheduler(initialClock: 0)
        
        let xs = scheduler.createHotObservable([
            next(150, 1),
            next(220, 2),
            next(240, 3),
            next(290, 4),
            completed(300)
            ])
        
        let ys = scheduler.createHotObservable([
            next(150, ""),
            next(210, "bar"),
            next(250, "foo"),
            next(260, "qux"),
            next(320, "baz"),
            completed(500)
            ])
        
        let res = scheduler.start {
            xs >- sample(ys)
        }
        
        let correct: [Recorded<Int>] = [
            next(250, 3),
            next(320, 4),
            completed(320)
        ]
        
        XCTAssertEqual(res.messages, correct)
        
        XCTAssertEqual(xs.subscriptions, [
            Subscription(200, 300)
            ])
        
        XCTAssertEqual(ys.subscriptions, [
            Subscription(200, 320)
            ])
    }
    
    func testSample_Sampler_SourceThrows() {
        let scheduler = TestScheduler(initialClock: 0)
        
        let xs = scheduler.createHotObservable([
            next(150, 1),
            next(220, 2),
            next(240, 3),
            next(290, 4),
            next(300, 5),
            next(310, 6),
            error(320, testError)
            ])
        
        let ys = scheduler.createHotObservable([
            next(150, ""),
            next(210, "bar"),
            next(250, "foo"),
            next(260, "qux"),
            next(300, "baz"),
            completed(400)
            ])
        
        let res = scheduler.start {
            xs >- sample(ys)
        }
        
        let correct: [Recorded<Int>] = [
            next(250, 3),
            next(300, 5),
            error(320, testError)
        ]
        
        XCTAssertEqual(res.messages, correct)
        
        XCTAssertEqual(xs.subscriptions, [
            Subscription(200, 320)
            ])
        
        XCTAssertEqual(ys.subscriptions, [
            Subscription(200, 320)
            ])
    }
    
    func testSampleLatest_Sampler_SamplerThrows() {
        let scheduler = TestScheduler(initialClock: 0)
        
        let xs = scheduler.createHotObservable([
            next(150, 1),
            next(220, 2),
            next(240, 3),
            next(290, 4),
            next(300, 5),
            next(310, 6),
            completed(400)
            ])
        
        let ys = scheduler.createHotObservable([
            next(150, ""),
            next(210, "bar"),
            next(250, "foo"),
            next(260, "qux"),
            error(320, testError)
            ])
        
        let res = scheduler.start {
            xs >- sampleLatest(ys)
        }
        
        let correct: [Recorded<Int>] = [
            next(250, 3),
            next(260, 3),
            error(320, testError)
        ]
        
        XCTAssertEqual(res.messages, correct)
        
        XCTAssertEqual(xs.subscriptions, [
            Subscription(200, 320)
            ])
        
        XCTAssertEqual(ys.subscriptions, [
            Subscription(200, 320)
            ])
    }
    
    func testSampleLatest_Sampler_Simple1() {
        let scheduler = TestScheduler(initialClock: 0)
        
        let xs = scheduler.createHotObservable([
            next(150, 1),
            next(220, 2),
            next(240, 3),
            next(290, 4),
            next(300, 5),
            next(310, 6),
            completed(400)
            ])
        
        let ys = scheduler.createHotObservable([
            next(150, ""),
            next(210, "bar"),
            next(250, "foo"),
            next(260, "qux"),
            next(320, "baz"),
            completed(500)
            ])
        
        let res = scheduler.start {
            xs >- sampleLatest(ys)
        }
        
        let correct: [Recorded<Int>] = [
            next(250, 3),
            next(260, 3),
            next(320, 6),
            next(500, 6),
            completed(500)
        ]
        
        XCTAssertEqual(res.messages, correct)
        
        XCTAssertEqual(xs.subscriptions, [
            Subscription(200, 400)
            ])
        
        XCTAssertEqual(ys.subscriptions, [
            Subscription(200, 500)
            ])
    }
    
    func testSampleLatest_Sampler_Simple2() {
        let scheduler = TestScheduler(initialClock: 0)
        
        let xs = scheduler.createHotObservable([
            next(150, 1),
            next(220, 2),
            next(240, 3),
            next(290, 4),
            next(300, 5),
            next(310, 6),
            next(360, 7),
            completed(400)
            ])
        
        let ys = scheduler.createHotObservable([
            next(150, ""),
            next(210, "bar"),
            next(250, "foo"),
            next(260, "qux"),
            next(320, "baz"),
            completed(500)
            ])
        
        let res = scheduler.start {
            xs >- sampleLatest(ys)
        }
        
        let correct: [Recorded<Int>] = [
            next(250, 3),
            next(260, 3),
            next(320, 6),
            next(500, 7),
            completed(500)
        ]
        
        XCTAssertEqual(res.messages, correct)
        
        XCTAssertEqual(xs.subscriptions, [
            Subscription(200, 400)
            ])
        
        XCTAssertEqual(ys.subscriptions, [
            Subscription(200, 500)
            ])
    }
    
    func testSampleLatest_Sampler_Simple3() {
        let scheduler = TestScheduler(initialClock: 0)
        
        let xs = scheduler.createHotObservable([
            next(150, 1),
            next(220, 2),
            next(240, 3),
            next(290, 4),
            completed(300)
            ])
        
        let ys = scheduler.createHotObservable([
            next(150, ""),
            next(210, "bar"),
            next(250, "foo"),
            next(260, "qux"),
            next(320, "baz"),
            completed(500)
            ])
        
        let res = scheduler.start {
            xs >- sampleLatest(ys)
        }
        
        let correct: [Recorded<Int>] = [
            next(250, 3),
            next(260, 3),
            next(320, 4),
            completed(320)
        ]
        
        XCTAssertEqual(res.messages, correct)
        
        XCTAssertEqual(xs.subscriptions, [
            Subscription(200, 300)
            ])
        
        XCTAssertEqual(ys.subscriptions, [
            Subscription(200, 320)
            ])
    }
    
    func testSampleLatest_Sampler_SourceThrows() {
        let scheduler = TestScheduler(initialClock: 0)
        
        let xs = scheduler.createHotObservable([
            next(150, 1),
            next(220, 2),
            next(240, 3),
            next(290, 4),
            next(300, 5),
            next(310, 6),
            error(320, testError)
            ])
        
        let ys = scheduler.createHotObservable([
            next(150, ""),
            next(210, "bar"),
            next(250, "foo"),
            next(260, "qux"),
            next(300, "baz"),
            completed(400)
            ])
        
        let res = scheduler.start {
            xs >- sampleLatest(ys)
        }
        
        let correct: [Recorded<Int>] = [
            next(250, 3),
            next(260, 3),
            next(300, 5),
            error(320, testError)
        ]
        
        XCTAssertEqual(res.messages, correct)
        
        XCTAssertEqual(xs.subscriptions, [
            Subscription(200, 320)
            ])
        
        XCTAssertEqual(ys.subscriptions, [
            Subscription(200, 320)
            ])
    }
}