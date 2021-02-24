//
//  MovieFetchable.swift
//  MovieFinder
//
//  Created by Leo Espinal on 2/23/21.
//

import Foundation
import RxSwift

protocol MovieFetchable {
	typealias SearchResult = Result<Movie, Error>
	func searchMovies(for title: String) -> Observable<SearchResult>
}
