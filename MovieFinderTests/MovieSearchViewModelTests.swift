//
//  MovieSearchViewModelTests.swift
//  MovieFinderTests
//
//  Created by Leo Espinal on 2/23/21.
//

import XCTest
import RxTest
import RxSwift
import RxCocoa
import RxBlocking
@testable import MovieFinder

class MovieSearchViewModelTests: XCTestCase {
	var mockMovieRequestService = MockMovieRequestService.shared
	var viewModel: MovieSearchViewModel!
	var scheduler: TestScheduler!
	var disposeBag: DisposeBag!

	override func setUp() {
		super.setUp()
		scheduler = TestScheduler(initialClock: 0)
		viewModel = MovieSearchViewModel(movieService: mockMovieRequestService)
		disposeBag = DisposeBag()
	}
	
    func testSuccessfulRatingConversion() {
		mockMovieRequestService.mockMovie.rating = "8.1"
		let expectation = XCTestExpectation(description: "Movie rating is converted to star rating successfully")
		
		let movieRating = scheduler.createObserver(String.self)

		scheduler.createColdObservable([.next(10, "naruto")])
			.bind(to: viewModel.input.movieTitle)
			.disposed(by: disposeBag)

		viewModel.output.movieRating
			.drive(movieRating)
			.disposed(by: disposeBag)
		
		scheduler.start()
		
		viewModel.output.movieRating
			.drive(onNext: { _ in
				expectation.fulfill()
			})
			.disposed(by: disposeBag)


		wait(for: [expectation], timeout: 10.0)
		XCTAssertRecordedElements(movieRating.events, ["⭐️⭐️⭐️⭐️"])
    }
	
	func testSuccessfulRatingConversion2() {
		mockMovieRequestService.mockMovie.rating = "7.2"
		let expectation = XCTestExpectation(description: "Movie rating is converted to star rating successfully")
		
		let movieRating = scheduler.createObserver(String.self)

		scheduler.createColdObservable([.next(10, "the hunger games")])
			.bind(to: viewModel.input.movieTitle)
			.disposed(by: disposeBag)

		viewModel.output.movieRating
			.drive(movieRating)
			.disposed(by: disposeBag)
		
		scheduler.start()
		
		viewModel.output.movieRating
			.drive(onNext: { _ in
				expectation.fulfill()
			})
			.disposed(by: disposeBag)


		wait(for: [expectation], timeout: 10.0)
		XCTAssertRecordedElements(movieRating.events, ["⭐️⭐️⭐️"])
	}
	
	func testShowMovieNotFoundMessageOnErrorMessage() {
		mockMovieRequestService.mockMovie.errorMessage = "Movie not found!"
		let expectation = XCTestExpectation(description: "Movie not found message is show")
		
		let shouldShowMessage = scheduler.createObserver(Bool.self)

		scheduler.createColdObservable([.next(10, "sgfkljfdfgl")])
			.bind(to: viewModel.input.movieTitle)
			.disposed(by: disposeBag)

		viewModel.output.shouldShowMessage
			.bind(to: shouldShowMessage)
			.disposed(by: disposeBag)
		
		scheduler.start()
		
		viewModel.output.shouldShowMessage
			.subscribe(onNext: { _ in
				expectation.fulfill()
			})
			.disposed(by: disposeBag)


		wait(for: [expectation], timeout: 10.0)
		XCTAssertRecordedElements(shouldShowMessage.events, [true])
	}
}
