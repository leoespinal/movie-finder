//
//  Result+Extensions.swift
//  MovieFinder
//
//  Created by Leo Espinal on 2/24/21.
//

import Foundation

extension Result {
	var successValue: T? {
		guard case .success(let value) = self else { return nil }
		return value
	}
	
	var failureValue: Error? {
		guard case .failure(let error) = self else { return nil }
		return error
	}
}
