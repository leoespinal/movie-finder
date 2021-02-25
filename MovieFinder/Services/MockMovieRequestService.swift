//
//  MockMovieRequestService.swift
//  MovieFinder
//
//  Created by Leo Espinal on 2/24/21.
//

import Foundation
import RxSwift

class MockMovieRequestService: MovieFetchable {
	typealias SearchResult = Result<Movie, Error>
	
	static let shared = MockMovieRequestService()
	
	var mockMovie: Movie
	
	private init() {
		mockMovie = Movie(title: nil,
						  posterURL: nil,
						  rating: nil,
						  errorMessage: nil)
	}
	
	func searchMovies(for title: String) -> Observable<SearchResult> {
		return Observable.create { observer in
			let task = DispatchWorkItem {
				self.mockMovie.title = title
				observer.onNext(.success(self.mockMovie))
				observer.onCompleted()
			}
			
			DispatchQueue.main.async(execute: task)
			return Disposables.create { task.cancel() }
		}
	}
}
