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
		
		let movieRating = scheduler.createObserver(String.self)

		scheduler.createColdObservable([.next(10, "naruto")]).debug("movieTitle", trimOutput: false)
			.bind(to: viewModel.input.movieTitle)
			.disposed(by: disposeBag)

		viewModel.output.movieRating.debug("movieRating", trimOutput: false)
			.drive(movieRating)
			.disposed(by: disposeBag)
		
		scheduler.start()

		XCTAssertRecordedElements(movieRating.events, ["⭐️⭐️⭐️⭐️"])
    }
}
