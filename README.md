# MSPeekCollectionViewDelegateImplementation

[![Build Status](https://travis-ci.org/MaherKSantina/MSPeekCollectionViewDelegateImplementation.svg?branch=master)](https://travis-ci.org/MaherKSantina/MSPeekCollectionViewDelegateImplementation)

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
delegate = MSPeekCollectionViewDelegateImplementation()
```
Or you can use whatever arguments from the ones below (Can be combined together as needed):
```swift
delegate = MSPeekCollectionViewDelegateImplementation(cellSpacing: 10)
```
```swift
delegate = MSPeekCollectionViewDelegateImplementation(cellPeekWidth: 20)
```
```swift
//scrollThreshold is the minimum amount of scroll distance required to move to the adjacent item.
delegate = MSPeekCollectionViewDelegateImplementation(scrollThreshold: 150)
```
```swift
//minimumItemsToScroll is the minimum number of items that can be scrolled
delegate = MSPeekCollectionViewDelegateImplementation(minimumItemsToScroll: 1)
```
```swift
//maximumItemsToScroll is the maximum number of items that can be scrolled if the scroll distance is large
delegate = MSPeekCollectionViewDelegateImplementation(maximumItemsToScroll: 3)
```
```swift
//numberOfItemsToShow is the number of items that will be shown at the same time.
delegate = MSPeekCollectionViewDelegateImplementation(numberOfItemsToShow: 3)
```

![peek explanation](https://user-images.githubusercontent.com/24646608/41348656-b0ad14fc-6f50-11e8-8723-2996b016e9c9.jpg)


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
    let delegate = MSPeekCollectionViewDelegateImplementation()

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

## Features
### Getting the offset of a specific index
The implementation introduces a function (`scrollView(_:,contentOffsetForItemAtIndex:) -> CGFloat`) to get the content offset of an item at a specific index. This can be helpful if you want to scroll the collection view programmatically to a specific index (Maybe create a carousel with a timer). You can do that by using the following code:
```swift
let secondItemContentOffset = delegate.scrollView(collectionView, contentOffsetForItemAtIndex: 1)
collectionView.setContentOffset(CGPoint(x: secondItemContentOffset, y: 0), animated: false)
```

## Customization
### Vertical Scroll Direction
The implementation supports collection views with vertical directions and will automatically position cells correctly, you can set the scrolling and peeking to be vertical using:
```swift
delegate = MSPeekCollectionViewDelegateImplementation(scrollDirection: .vertical)
collectionView.configureForPeekingDelegate(scrollDirection: .vertical)
```
Or alternatively:
```swift
let layout = collectionView.collectionViewLayout as! UICollectionViewFlowLayout
delegate = MSPeekCollectionViewDelegateImplementation(scrollDirection: layout.scrollDirection)
collectionView.configureForPeekingDelegate(scrollDirection: layout.scrollDirection)
```

### Implementing MSPeekImplementationDelegate
You can implement the delegate of the peek implementation to listen to specific events. This is the protocol of the delegate
```swift
@objc public protocol MSPeekImplementationDelegate: AnyObject {
    ///Will be called when the current active index has changed
    @objc optional func peekImplementation(_ peekImplementation: MSPeekCollectionViewDelegateImplementation, didChangeActiveIndexTo activeIndex: Int)
    ///Will be called when the user taps on a cell at a specific index path
    @objc optional func peekImplementation(_ peekImplementation: MSPeekCollectionViewDelegateImplementation, didSelectItemAt indexPath: IndexPath)
}
```

To listen to those events, you can do something like this:
```swift
class ViewController: UIViewController {
    @IBOutlet weak var collectionView: UICollectionView!
    var peekImplementation: MSPeekCollectionViewDelegateImplementation!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        //Set the collection view
        //...
        peekImplementation = MSPeekCollectionViewDelegateImplementation()
        peekImplementation.delegate = self
    }
}

extension ViewController: MSPeekImplementationDelegate {
    func peekImplementation(_ peekImplementation: MSPeekCollectionViewDelegateImplementation, didChangeActiveIndexTo activeIndex: Int) {
        print("Changed active index to \(activeIndex)")
    }
    
    func peekImplementation(_ peekImplementation: MSPeekCollectionViewDelegateImplementation, didSelectItemAt indexPath: IndexPath) {
        print("Selected item at \(indexPath)")
    }
}
```

### Subclassing
You can subclass the delegate implementation to integrate other features to it, or listen to certain events:
```swift
class SelectablePeekCollectionViewDelegateImplementation: MSPeekCollectionViewDelegateImplementation {
    
    override func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
        super.scrollViewWillBeginDragging(scrollView)
        // Add other code to support other features
    }
}
```
Note: Make sure you call super on overriden functions (Unless you know what you're doing)

## Author

Maher Santina, maher.santina90@gmail.com

## Contributing

Any contribution is highly appreciated, please see [CONTRIBUTING.md](https://github.com/MaherKSantina/MSPeekCollectionViewDelegateImplementation/blob/master/CONTRIBUTING.md) for more info.

## License

MSPeekCollectionViewDelegateImplementation is available under the MIT license. See the [LICENSE](https://github.com/MaherKSantina/MSPeekCollectionViewDelegateImplementation/blob/master/LICENSE) file for more info.
