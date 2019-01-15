# ContentDrawerContainer
A Swift component that enables an interactive drawer to be displayed ala Apple Maps app.

## Usage
```swift
let container = ContentDrawerContainer()
container.content = DetailViewController()
container.drawer = SettingsViewController()

container.setOpenState(.closed, animated: true)
```


