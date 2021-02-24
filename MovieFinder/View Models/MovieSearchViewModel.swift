//
//  MovieSearchViewModel.swift
//  MovieFinder
//
//  Created by Leo Espinal on 2/23/21.
//

import Foundation
import RxSwift
import RxCocoa

struct MovieSearchViewModel: ViewModel {
	struct Input {
		let movieTitle: AnyObserver<String?>
	}
	
	struct Output {
		let movie: Driver<Movie?>
		let errorMessage: Driver<String>
		let shouldShowMessage: Observable<Bool>
		let movieRating: Observable<String>
	}
	
	let input: Input
	let output: Output
	
	private let movieTitleSubject: PublishSubject<String?> = PublishSubject<String?>()
	private let disposeBag = DisposeBag()
	
	init(movieService: MovieFetchable = MovieRequestService.shared) {
		input = Input(movieTitle: movieTitleSubject.asObserver())
		
		let movie = movieTitleSubject
			.flatMap { movieTitle -> Observable<Movie?> in
				guard
					let movieTitle = movieTitle,
					!movieTitle.isEmpty
				else { return .just(nil) }
				return movieService.searchMovies(for: movieTitle)
					.map { $0.successValue }
			}
			.asDriver(onErrorJustReturn: nil)
		
		let movieRating = movie
			.compactMap { movie -> String? in
				guard
					let rating = movie?.rating,
					let ratingValue = Double(rating)
				else { return nil }
				let scaledRating = Int((ratingValue / 10) * 5)
				
				var starRating = ""
				
				for _ in 1...scaledRating {
					starRating += "⭐️"
				}
				return starRating
			}.asObservable()
		
		let emptyStateMessage = movieTitleSubject
			.compactMap { title -> String? in
				guard
					let title = title,
					title.isEmpty
				else { return nil }
				return "Start searching for some movies"
			}
		
		let errorMessage = movie
			.compactMap { movie -> String? in
				guard let movie = movie else { return nil }
				return movie.errorMessage
			}
		
		let message = Observable.merge(emptyStateMessage, errorMessage.asObservable())
			.asDriver(onErrorJustReturn: "")
		
		let shouldShowMessage = movie
			.map { movie -> Bool in
				return movie == nil || movie?.errorMessage != nil
			}.asObservable()
		
		output = Output(movie: movie,
						errorMessage: message,
						shouldShowMessage: shouldShowMessage.startWith(true),
						movieRating: movieRating)
	}
}
