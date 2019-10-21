# FlickrMe

FlickrMe is an iOS project to demonstrate the infinite scrolling of collection view. This example uses Flickr's APIs available for public use. In particular, this example uses Photo Search API for paginated responses. More about Flickr and its public APIs here [Flickr API documentation](https://www.flickr.com/services/api/). Search API documentation can be found here [Search API documentation](https://www.flickr.com/services/api/flickr.photos.search.html)

## Getting Started

Install any stable version of Xcode 10.x or greater. Checkout this repository on your machine. Open `FlickrMe/FlickrMe.xcodeproj`. No further software/frameworks are required to run this project.

## Running the application

Select `FlickrMe` target. Choose any simulator like: iPhone 7, iPhone Xs, iPad Air 2. Just press `cmd + R`. Application should start compiling. If all is well. Simulator will launch and then the application.

## Running the tests

Select `FlickrMe` target. Choose any simulator like: iPhone 7, iPhone Xs, iPad Air 2. Just press `cmd + U`. This will run both unit tests and UI tests.

### Unit tests

NetworkLayerTests covers encoding parameters, given an `Endpoint`

```
func testURLEncoding()
func testJSONEncoding()
```

FlickrImageSearchViewModelTests covers all ViewModel related tests like search triggers - both fail case and success case

```
func testOnFailedFetchDelegateIsInformed()
func testOnSuccessfulFetchDelegateIsInformed()
func testOnSuccessfulImageDownloadDelegateIsInformed()
```


### UI tests covers mostly integration of `Search` feature

SearchIntegrationTests covers UI tests. Also treated as integration tests

```
func testEmptyPageOnLaunch()
func testCanEnterSearchTerm()
```

## Structure

### Architectural design pattern

Project uses simple MVVM - Model, View, ViewModel design pattern.

* **Models** hold application data. They’re usually structs or simple classes. Ex: `FlickrImage`
* **Views** display visual elements and controls on the screen. They’re typically subclasses of UIView. Ex: `SearchImageViewController`
* **View** models transform model information into values that can be displayed on a view. They’re usually classes, so they can be passed around as references. Ex: `FlickrImageSearchViewModel`

More about MVVM design pattern [here](https://www.flickr.com/services/api/)

### Networking

A network layer in pure Swift without any third-party libraries. 

* Protocol-oriented
* Easy to use
* Easy to implement
* Type safe
* Use enums to configure endPoints.

##  Future

There are many places where the code could be improved. Few of them are listed here

* Secrets management - Managing secret/API keys by reading from machines environment variable
* Image caching
* Localisation of error messages