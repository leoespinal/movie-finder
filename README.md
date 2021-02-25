# Movie Finder

Movie Finder provides users a way to search for information about movies by querying the OMDB database. The app provides the user with a search bar to look up a movie of their choosing, as the user starts their search they will be able to see information such as the movie's poster image and rating if the movie exists in the OMDB database.

## Design
The Movie Finder UI consist of a single screen that contains a `UISearchBar` that allows for the user to type in a movie that they would like to search for. The reason why I chose to go with a `UISearchBar` versus a `UITextfield` is because Apple provides some more built in functionality that the regular text field doesn't. The `UISearchBar` is widely recognized by iOS users and is intuitively made for searching for content within an app. It contains buttons that can be enabled or disabled using flags and comes with the ability to delete search text at the tap of a button which would otherwise, need to be implemented as a part of a regular `UITextField`. The movie poster image is displayed by a `UIImageView` and the movie title, rating, and message (if there is one such as `Movie Not Found!` or `Start searching for some movies`) are displayed to the user via `UILabels`. The UI is fairly simple and was created entirely in `Storyboard` due to the scope of this exercise.

## Architecture
Movie Finder is built using the MVVM (Model-View-ViewModel) architecture. This architecture is one that I prefer using simply because it allows for better testability of the code that binds data to the view. I used `Protocols` for the `ViewModel` and the `MovieRequestService` in the event that the app were to be extended, other view models or mock services could make use of them. The `ViewModel` protocol defines `Input` and `Output` associated types which define the flow of data going in to the view model and out of the view model which I feel would be a good pattern to follow for the implementation of future view models. The `MovieRequestService` is defined as a `Singleton` since there isn't a need to have more than a single instance within the app. I decided to define it as a `shared` instance, this a pattern that I've frequently seen in Apple's APIs.

To further expand upon this app, additional services that are created should be created as Singleton objects with their respective protocols for easier testing purposes and any additional screens added to the app should stick to the MVVM architectural pattern as well to keep the codebase consistent.

If the `Movie` data model and `MovieRequestService` would need to be extended to be reused by a second app, I would update the `Movie` data model to be able to decode the rest of the movie data that can be provided from the OMDb API versus just the title, posterURL, rating, and error message so that it is flexible enough to support additional data that a second app might want to use. I would also modify the `MovieRequestService` and related protocol to create functions that could call other endpoints, I'd also make the request function much more flexible to make use of any number of parameters that the OMDb API provides (this could be achieved by passing a dictionary to the request function that contains query parameters and their values or even by passing in an array of search criteria which then internal to the service would get constructed into query parameters for the request). This would make the service much more complete because currently the service only currently allows for searching of movies by title and the request only currently supports a single parameter.

## Third Party Libraries

#### RxSwift
I choose to use RxSwift when building this app because it allowed for much simpler data binding capabilities between the `MovieSearchViewController` and `MovieSearchViewModel`. I have found that RxSwift works really well with the MVVM architectural pattern. By using RxSwift I was able to easily bind to the search bar's text and provide real time search results to the user.

#### RxGesture
I included the `RxGesture` package because it provides a reactive wrapper around bindings to gestures which fits well with the rest of the code base as it is written in RxSwift. It allowed for me to easily bind to tap gestures on the view which allowed for dismissing of the keyboard once the user finishes typing in the search bar.

I did run into an issue with getting the keyboard to dismiss by tapping the `Done` button which created a bug. Using a tap gesture recognizer was a way to work around that issue for the purposes of this exercise but given more time I would have created an `RxDelegateProxy` for the `UISearchBarDelegate` to bind to the search bar delegate methods.  

#### Kingfisher
Kingfisher is a popular well supported library used in most cases to asynchronously load images from a URL to a `UIImageView` so, I thought that it was a good option for this project since the the OMDb API returns the movie poster image URL indicating that the image needed to be fetched.

#### RxTest
Since I decided to use RxSwift, the RxTest library was the best option to include in the project to be able to write unit tests.

I came across an issue including this library using the Swift Package Manager which I was able to use for the other libraries I included so I ended up installing it using Cocoapods. With more time beyond this exercise I would have done some further research to find a fix so that all libraries included in the project are consistently using a single dependency manager.

## Third Party Tools

### Postman
Postman was extremely helpful in testing out and understanding the OMDb API prior to building out the `MovieSearchService` so that I could better understand what data the endpoint would provide me with based on various query parameters that the API provides. It helped me decide to go with using the `t` query parameter versus the `s` query parameter which according to documentation provide the ability to search for a movie by title but provide very different response results. The `s` query parameter wouldn't have allowed me to obtain the `imdbRating` needed to generate the movie star rating.

## Documentation
- OMDb API:
https://www.omdbapi.com/

- Apple:
https://developer.apple.com/documentation/uikit/uisearchbar
https://developer.apple.com/documentation/foundation/urlcomponents
https://developer.apple.com/design/human-interface-guidelines/ios/bars/search-bars/

- RayWenderlich.com RxTest:
https://www.raywenderlich.com/7408-testing-your-rxswift-code

## Test Automation
For test automation, I would create a series of UITests using Apple's `XCUITest` framework which I would run and automate use a tool like `fastlane`. I'd create a `Fastfile` for debug and a `Fastfile` for production that defines the test scripts and integrate with a CI tool so that UITests are run on a periodic basis.

## CI/CD
If I were to set this app up for production I would setup a CI/CD pipeline using a tool like Jenkins. Create a Jenkins job for the app and create a `Jenkinsfile` defining the build pipeline to build the app bundle and build/run tests whenever a branch is pushed up to a remote repo or whenever a feature branch is merged into the `main`.

I'd create separate build configurations and build targets in Xcode for different testing environments such a `Debug` build configuration and a `Release` build configuration. This would allow for developers to test the app using the `Debug` configuration which could consist of things such as specific or and have QA test with the `Release` candidate builds.

## Future Improvements
It took me about 3 hours to get through this exercise with some things that I would have liked to accomplish which I have listed below in priority order.

### My Priorities
#### Unfinished work
- A part of the exercise was to write unit tests to verify the movie rating scale and showing of the `Movie not found` message to the user but I ran into some issues getting the tests setup using the `RxTest` framework so given more time I would definitely figure out how to set those tests up properly so that I could have several test cases that cover all of the data flowing out of the `MovieSearchViewModel`. I'd also test for edge cases such as the scenario when no rating was returned by the API for a given search result, resulting in an empty rating string.

#### Bug fixes
- Fix the `Done` keyboard button so that it allows for the search bar to `resignFirstResponder` when tapped
- I noticed that there is a bug around the scrolling capabilities of the `MovieSearchViewController` which made it tough to see some of the search result content on a smaller device such as an iPhone 8

#### Debugging Enhancements
- Currently the app doesn't have any logs which could make it tough to debug the app so I would add logging capabilities

#### UI Enhancements
- The UI looks pretty simple at the moment, it would be nice to make some changes so that it would look more polished such as add some animations and change colors, style the search bar, or even clean up constraints on the UI a bit more so that the poster image is proportionately resized proportional based on device's screen size.

### If you were to make improvements
If you were to add functionality to this app you could make it so that the `Movie` data model gets extended to decode more data from the search endpoint so that a much richer set of data/more metrics about the movie searched for could be presented to the user.
