app = angular.module('app', [
  'ngAutocomplete'
  'app.services'
  'app.directives'
  'app.controllers'
])

app.config [ '$locationProvider', ($locationProvider) ->
  $locationProvider.html5Mode(true)
]

app = angular.module('app.services', [])

params=
  url: 'https://api.flickr.com/services/rest'
  apiKey: 'ed7fdc9c944b933e7c35437053c744cc'
  format: 'json&jsoncallback=JSON_CALLBACK'

baseUrl = params.url + '?api_key=' + params.apiKey + '&format=' + params.format

app.factory 'getLocation', [ '$http', ($http) ->
  factory = {}
  factory.searchQuery = (location) ->
    $http.jsonp(baseUrl + '&method=flickr.places.find&query=' + encodeURIComponent(location))
    .success (data) ->
      return data

  factory.searchPhotos = (id, page) ->
    $http.jsonp(baseUrl + '&method=flickr.photos.search&woe_id=' + id + '&per_page=20&page=' + page + '&extras=url_z,url_o,url_sq,url_s')
    .success (data) ->
      return data

  return factory
]

app = angular.module('app.directives', [])

app.directive 'gridInit', [ '$scope', ($scope) ->
  return (scope, element, attrs) ->
    if scope.$last
      console.log "last element loaded now do things"
]

app.directive "markable", ->
  return {
  link: (scope, elem, attrs) ->
    elem.on "click", ->
      elem.addClass("active")
      angular.element('body').addClass('view-full')
  }

app = angular.module('app.controllers', [])

app.controller 'SearchController', [
  '$scope'
  '$http'
  'getLocation'
  '$timeout'
  ($scope, $http, getLocation, $timeout) ->

    $scope.loading = false

    $scope.searchFlickr = ->
      if $scope.loading is true then return false
      i = 1
      $scope.loading = true
      loadingMore = false

      getLocation.searchQuery($scope.location).then((response) ->
        if response.data.places.place[0].woeid
          locationId = response.data.places.place[0].woeid
          $scope.shrink = true

          getLocation.searchPhotos(locationId, i).then((response) ->
            $scope.photos = response.data.photos.photo
            $scope.loading = false

            $scope.activatePhoto = (event, $index) ->
              $scope.previewImage = response.data.photos.photo[$index]
              $scope.modalImage = true
              $scope.isActive = true

            $scope.closePlaceholder = ->
              $scope.isActive = false
              angular.element('.grid-item').removeClass('active')
              $scope.modalImage = false

            return
          )
        else
          $scope.shrink = false
          console.log "too many results"
      )
      return
    return


]