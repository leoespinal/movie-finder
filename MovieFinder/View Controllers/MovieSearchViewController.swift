//
//  MovieSearchViewController.swift
//  MovieFinder
//
//  Created by Leo Espinal on 2/23/21.
//

import UIKit

import RxSwift
import RxCocoa
import RxGesture
import Kingfisher

class MovieSearchViewController: UIViewController {
	@IBOutlet var searchBar: UISearchBar!
	@IBOutlet var errorMessageLabel: UILabel!
	@IBOutlet var posterImageView: UIImageView!
	@IBOutlet var movieTitleLabel: UILabel!
	@IBOutlet var movieRatingLabel: UILabel!

	private let viewModel = MovieSearchViewModel()
	private let disposeBag = DisposeBag()
	
	// MARK: - View Lifecycle

	override func viewDidLoad() {
		super.viewDidLoad()
		bind()
		setup()
	}
	
	// MARK: - Bindings
	
	private func bind() {
		bindViewModel()
		bindGestures()
	}
	
	private func bindViewModel() {
		searchBar.rx.text
			.bind(to: viewModel.input.movieTitle)
			.disposed(by: disposeBag)
		
		viewModel.output.movie
			.drive { [weak self] movie in
				self?.movieTitleLabel.text = movie?.title
				
				if let posterImageURL = movie?.posterURL {
					let imageURL = URL(string: posterImageURL)
					self?.posterImageView.kf.setImage(with: imageURL)
				}
			}
			.disposed(by: disposeBag)
		
		viewModel.output.movieRating
			.drive(movieRatingLabel.rx.text)
			.disposed(by: disposeBag)
		
		viewModel.output.errorMessage
			.drive(errorMessageLabel.rx.text)
			.disposed(by: disposeBag)
		
		viewModel.output.shouldShowMessage
			.subscribe { [weak self] shouldShow in
				if shouldShow {
					self?.movieTitleLabel.isHidden = true
					self?.movieRatingLabel.isHidden = true
					self?.posterImageView.isHidden = true
					self?.errorMessageLabel.isHidden = false
				} else {
					self?.movieTitleLabel.isHidden = false
					self?.movieRatingLabel.isHidden = false
					self?.posterImageView.isHidden = false
					self?.errorMessageLabel.isHidden = true
				}
			} onError: { _ in } onCompleted: {} onDisposed: {}
			.disposed(by: disposeBag)
	}
	
	private func bindGestures() {
		view.rx.tapGesture()
			.when(.recognized)
			.subscribe { _ in self.searchBar.resignFirstResponder() }
			.disposed(by: disposeBag)
	}
	
	// MARK: - Setup
	
	private func setup() {
		setupSearchBar()
		setupLabels()
	}
	
	private func setupSearchBar() {
		searchBar.placeholder = "Enter movie title"
		searchBar.prompt = "Movie Finder"
		searchBar.showsSearchResultsButton = true
		searchBar.returnKeyType = .done
	}
	
	private func setupLabels() {
		errorMessageLabel.text = ""
		movieTitleLabel.text = ""
		movieRatingLabel.text = ""
	}
}

