# ContentDrawerContainer
A Swift component that enables an interactive drawer to be displayed ala Apple Maps app.

## Usage
```swift
let container = ContentDrawerContainer()
container.content = MapViewController()
container.drawer = ListViewController()

container.setOpenState(.closed, animated: true)
```


