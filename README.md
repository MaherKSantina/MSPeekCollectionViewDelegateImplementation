# MSPeekCollectionViewDelegateImplementation

![ezgif-2-9f7a86182f](https://user-images.githubusercontent.com/24646608/41348369-c0887714-6f4f-11e8-9231-8a86a278ee4a.gif)

Current design trends require complex designs which allow horizontal scrolling inside vertical scrolling. So to show the users that they can scroll vertically, a peeking item should be shown on the side. This library does exactly that.
I wrote this library because there's no pod that does this simple feature. Also, other libraries require me to inherit from a UICollectionViewController, which doesn't give alot of freedom if I'm inheriting from other View Controllers.

## Example

To run the example project, clone the repo, and run `pod install` from the Example directory first.

## Requirements

- XCode 9.3
- Swift 3.2

This pod will probably work on older versions of XCode but I haven't tested it.

## Installation

MSPeekCollectionViewDelegateImplementation is available through [CocoaPods](https://cocoapods.org). To install
it, simply add the following line to your Podfile:

```ruby
pod 'MSPeekCollectionViewDelegateImplementation'
```

## Usage

### Storyboard
1. Drag-Drop a `UICollectionView`

2. Set the reuse identifier for the collection view's cell to `Cell`

3. Create a reference for the collection view
```swift
@IBOutlet weak var collectionView: UICollectionView!
```

4. Bind collection view to outlet

5. Import library
```swift
import MSPeekCollectionViewDelegateImplementation
```

6. Create a variable of type `MSPeekCollectionViewDelegateImplementation`
```swift
var delegate: MSPeekCollectionViewDelegateImplementation!
```

7. In `viewDidLoad()`, Configure the `collectionView` for peek behavior:
```swift
collectionView.configureForPeekingDelegate()
```

8. In `viewDidLoad()`, initialize the delegate using the basic initializer:
```swift
delegate = MSPeekCollectionViewDelegateImplementation(itemsCount: 4)
```
Or you can use one of the initializers that take more arguments:
```swift
delegate = MSPeekCollectionViewDelegateImplementation(itemsCount: 4, cellSpacing: 10)
```
```swift
delegate = MSPeekCollectionViewDelegateImplementation(itemsCount: 4, cellSpacing: 10, cellPeekWidth: 20)
```
```swift
delegate = MSPeekCollectionViewDelegateImplementation(itemsCount: 4, cellSpacing: 10, cellPeekWidth: 20, scrollThreshold: 150)
```

![peek explanation](https://user-images.githubusercontent.com/24646608/41348656-b0ad14fc-6f50-11e8-8723-2996b016e9c9.jpg)

The scroll threshold is the minimum amount of scroll distance required to move to the adjacent item.

9. In `viewDidLoad()`, set the collection view's delegate:
```swift
collectionView.delegate = delegate
```
10. Create the data source implementation as an extension for the `ViewController`
```swift
extension ViewController: UICollectionViewDataSource {
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 4
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "Cell", for: indexPath)
        //TODO: Configure cell
        return cell
    }
}
```

11. In `viewDidLoad()`, Set the collection view's data source to `self`
```swift
collectionView.dataSource = self
```

### Working Example

```swift
import UIKit
import MSPeekCollectionViewDelegateImplementation

class ViewController: UIViewController {
    
    @IBOutlet weak var collectionView: UICollectionView!
    let delegate = MSPeekCollectionViewDelegateImplementation(itemsCount: 4)

    override func viewDidLoad() {
        super.viewDidLoad()
        collectionView.configureForPeekingDelegate()
        collectionView.delegate = delegate
        collectionView.dataSource = self
    }


}

extension ViewController: UICollectionViewDataSource {
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 4
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "Cell", for: indexPath)
        cell.contentView.backgroundColor = UIColor.red
        return cell
    }
}
```

## Author

Maher Santina, maher.santina90@gmail.com

## Contributing

Any contribution is highly appreciated, please see [CONTRIBUTING.md](https://github.com/MaherKSantina/MSPeekCollectionViewDelegateImplementation/blob/master/CONTRIBUTING.md) for more info.

## License

MSPeekCollectionViewDelegateImplementation is available under the MIT license. See the [LICENSE](https://github.com/MaherKSantina/MSPeekCollectionViewDelegateImplementation/blob/master/LICENSE) file for more info.
