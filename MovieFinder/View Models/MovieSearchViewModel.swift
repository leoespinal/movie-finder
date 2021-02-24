//
//  MovieSearchViewModel.swift
//  MovieFinder
//
//  Created by Leo Espinal on 2/23/21.
//

import Foundation
import RxSwift
import RxCocoa

struct MovieSearchViewModel {
	struct Input {
		let movieTitle: AnyObserver<String?>
	}
	
	struct Output {
		let movie: Driver<Movie?>
		let errorMessage: Driver<String?>
		let shouldShowMessage: Observable<Bool>
		let movieRating: Driver<String?>
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
					.map { result -> Movie? in
						switch result {
						case .success(let movie):
							// Some movie titles would appear without ratings or a poster image
							// Filtering these out to provide a better user experience
							// TODO: Come back to this
							//guard movie.posterURL != nil, movie.rating != nil else { return nil }
							return movie
						case .failure:
							return nil
						}
					}
			}
			.asDriver(onErrorJustReturn: nil)
		
		let movieRating = movie
			.map { movie -> String? in
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
			}
		
		let emptyStateMessage = movieTitleSubject
			.map { title -> String? in
				guard
					let title = title,
					title.isEmpty
				else { return nil }
				return "Start searching for some movies"
			}
		
		let errorMessage = movie
			.map { movie -> String? in
				guard let movie = movie else { return nil }
				return movie.errorMessage
			}
		
		let message = Observable.merge(emptyStateMessage, errorMessage.asObservable())
		
		let shouldShowMessage = Observable.combineLatest(message, movie.asObservable())
			.map { message, movie -> Bool in
				return (movie == nil || movie?.errorMessage != nil) && message != nil
			}
		
		output = Output(movie: movie,
						errorMessage: message.startWith("Start searching for some movies").asDriver(onErrorJustReturn: nil),
						shouldShowMessage: shouldShowMessage.startWith(true),
						movieRating: movieRating)
	}
}
