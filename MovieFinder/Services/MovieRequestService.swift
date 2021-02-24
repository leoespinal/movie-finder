//
//  MovieRequestService.swift
//  MovieFinder
//
//  Created by Leo Espinal on 2/23/21.
//

import Foundation
import RxSwift

enum Result<T, Error> {
	case success(T)
	case failure(Error)
}

enum MovieRequestError: Error {
	case invalidURL
	case failedToFetchMovie(Error)
	case noDataFound
	case failedToDecodeMovie(Error)
	case invalidResponse
	
	var description: String {
		switch self {
		case .invalidURL:
			return "An invalid request URL was provided"
		case .failedToFetchMovie(let error):
			return "Failed to fetch movie due to \(error)"
		case .noDataFound:
			return "No search data was found"
		case .failedToDecodeMovie(let error):
			return "Failed to decode movie data due to \(error)"
		case .invalidResponse:
			return "An invalid request response occurred"
		}
	}
}

class MovieRequestService: MovieFetchable {
	static let shared = MovieRequestService()
	
	private init() {}
	
	func searchMovies(for title: String) -> Observable<SearchResult> {
		return Observable.create { observer in
			let task = DispatchWorkItem {
				let baseURL = "https://www.omdbapi.com/?apikey=ee60b1cc"
				let searchQueryParameter = URLQueryItem(name: "t", value: title)
				var urlComponents = URLComponents(string: baseURL)
				urlComponents?.queryItems?.append(searchQueryParameter)
				let searchURL = urlComponents?.url
				
				guard let requestURL = searchURL else {
					observer.onNext(.failure(MovieRequestError.invalidURL))
					return
				}
				
				let request = URLRequest(url: requestURL)
				
				let task = URLSession.shared.dataTask(with: request) { data, response, error in
					if let error = error {
						observer.onNext(.failure(MovieRequestError.failedToFetchMovie(error)))
					}
					
					guard
						let response = response as? HTTPURLResponse,
						response.statusCode == 200 else {
						observer.onNext(.failure(MovieRequestError.invalidResponse))
						return
					}
					
					guard let data = data else {
						observer.onNext(.failure(MovieRequestError.noDataFound))
						return
					}
					
					do {
						let movie = try JSONDecoder().decode(Movie.self, from: data)
						observer.onNext(.success(movie))
					} catch {
						observer.onNext(.failure(MovieRequestError.failedToDecodeMovie(error)))
					}
					observer.onCompleted()
				}
				
				task.resume()
			}
			
			DispatchQueue.main.async(execute: task)
			return Disposables.create { task.cancel() }
		}
	}
}
