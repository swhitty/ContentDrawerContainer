# ContentDrawerContainer
A Swift component that enables an interactive drawer to be displayed ala Apple Maps app.

## Usage
```swift
let container = ContentDrawerContainer()
container.content = MapViewController()
container.drawer = ListViewController()

//Close the drawer
container.setOpenState(.closed, animated: true)

//Open the drawer
container.setOpenState(.open, animated: true)
```


