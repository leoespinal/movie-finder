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
@testable import MovieFinder

class MovieSearchViewModelTests: XCTestCase {
	var mockMovieRequestService = MockMovieRequestService.shared
	var viewModel: MovieSearchViewModel!
	var scheduler: TestScheduler!
	var disposeBag: DisposeBag!

	override func setUp() {
		super.setUp()
		viewModel = MovieSearchViewModel(movieService: mockMovieRequestService)
		scheduler = TestScheduler(initialClock: 0)
		disposeBag = DisposeBag()
	}
	
    func testSuccessfulRatingConversion() {
		let movieRating = scheduler.createObserver(String.self)

		viewModel.output.movieRating
			.bind(to: movieRating)
			.disposed(by: disposeBag)

		scheduler.createColdObservable([.next(10, "naruto")])
			.bind(to: viewModel.input.movieTitle)
			.disposed(by: disposeBag)
		
		scheduler.start()
		
		XCTAssertEqual(movieRating.events, [.next(10, "⭐️⭐️⭐️⭐️")])
    }

	func testFailedRatingConversion() {
		
	}
}
