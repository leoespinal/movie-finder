//
//  ViewModeling.swift
//  MovieFinder
//
//  Created by Leo Espinal on 2/24/21.
//

import Foundation

protocol ViewModel {
	associatedtype Input
	associatedtype Output
	
	var input: Input { get }
	var output: Output { get }
}
