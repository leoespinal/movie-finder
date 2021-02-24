//
//  Movie.swift
//  MovieFinder
//
//  Created by Leo Espinal on 2/23/21.
//

import Foundation

struct Movie: Decodable {
	let title: String?
	let posterURL: String?
	let rating: String?
	let errorMessage: String?
	
	enum MovieCodingKeys: String, CodingKey {
		case title = "Title"
		case poster = "Poster"
		case rating = "imdbRating"
		case error = "Error"
	}
	
	init(from decoder: Decoder) throws {
		let container = try decoder.container(keyedBy: MovieCodingKeys.self)
		title = try container.decodeIfPresent(String.self, forKey: .title)
		posterURL = try container.decodeIfPresent(String.self, forKey: .poster)
		rating = try container.decodeIfPresent(String.self, forKey: .rating)
		errorMessage = try container.decodeIfPresent(String.self, forKey: .error)
	}
}
