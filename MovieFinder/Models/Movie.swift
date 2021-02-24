//
//  Movie.swift
//  MovieFinder
//
//  Created by Leo Espinal on 2/23/21.
//

import Foundation

struct Movie: Decodable {
	var title: String?
	var posterURL: String?
	var rating: String?
	var errorMessage: String?
	
	enum MovieCodingKeys: String, CodingKey {
		case title = "Title"
		case poster = "Poster"
		case rating = "imdbRating"
		case error = "Error"
	}
	
	init(title: String?, posterURL: String?, rating: String?, errorMessage: String?) {
		self.title = title
		self.posterURL = posterURL
		self.rating = rating
		self.errorMessage = errorMessage
	}
	
	init(from decoder: Decoder) throws {
		let container = try decoder.container(keyedBy: MovieCodingKeys.self)
		title = try container.decodeIfPresent(String.self, forKey: .title)
		posterURL = try container.decodeIfPresent(String.self, forKey: .poster)
		rating = try container.decodeIfPresent(String.self, forKey: .rating)
		errorMessage = try container.decodeIfPresent(String.self, forKey: .error)
	}
}
