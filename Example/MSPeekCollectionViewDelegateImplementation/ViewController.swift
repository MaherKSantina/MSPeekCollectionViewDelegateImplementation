//Copyright (c) 2018 maher.santina90@gmail.com <maher.santina90@gmail.com>
//
//Permission is hereby granted, free of charge, to any person obtaining a copy
//of this software and associated documentation files (the "Software"), to deal
//in the Software without restriction, including without limitation the rights
//to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
//copies of the Software, and to permit persons to whom the Software is
//furnished to do so, subject to the following conditions:
//
//The above copyright notice and this permission notice shall be included in
//all copies or substantial portions of the Software.
//
//THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
//IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
//FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
//AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
//LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
//OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
//THE SOFTWARE.


import UIKit
import MSPeekCollectionViewDelegateImplementation

class CustomSlider: UISlider {
    @IBInspectable var isInt: Bool = false
}

class ViewController: UIViewController {
    
    @IBOutlet weak var cellSpacingSlider: UISlider!
    @IBOutlet weak var cellPeekWidthSlider: UISlider!
    @IBOutlet weak var scrollThresholdSlider: UISlider!
    @IBOutlet weak var maximumItemsToScrollSlider: UISlider!
    @IBOutlet weak var numberOfItemsToShowSlider: UISlider!

    @IBOutlet weak var collectionView: UICollectionView!

    var behavior: MSCollectionViewPeekingBehavior!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        reloadDelegate()
        collectionView.delegate = self
        collectionView.dataSource = self
        
        initSliderValues()
    }
    
    func initSliderValues() {
        cellSpacingSlider.value = Float(behavior.cellSpacing)
        cellPeekWidthSlider.value = Float(behavior.cellPeekWidth)
        maximumItemsToScrollSlider.value = Float(behavior.maximumItemsToScroll ?? 1)
        numberOfItemsToShowSlider.value = Float(behavior.numberOfItemsToShow)
    }
    
    @IBAction func sliderValueDidChange(_ slider: CustomSlider) {
        if slider.isInt {
            let value = slider.value
            slider.value = Float(Int(value))
        }
        
        reloadDelegate()
    }
    
    func reloadDelegate() {
        behavior = MSCollectionViewPeekingBehavior(cellSpacing: CGFloat(cellSpacingSlider.value), cellPeekWidth: CGFloat(cellPeekWidthSlider.value), maximumItemsToScroll: Int(maximumItemsToScrollSlider.value), numberOfItemsToShow: Int(numberOfItemsToShowSlider.value), scrollDirection: .horizontal)
        collectionView.configureForPeekingBehavior(behavior: behavior)
        collectionView.reloadData()
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
        let value =  (180 + CGFloat(indexPath.row)*20) / 255
        cell.contentView.backgroundColor = UIColor(red: value, green: value, blue: value, alpha: 1)
        return cell
    }
}

extension ViewController: UICollectionViewDelegate {
    func scrollViewWillEndDragging(_ scrollView: UIScrollView, withVelocity velocity: CGPoint, targetContentOffset: UnsafeMutablePointer<CGPoint>) {
        behavior.scrollViewWillEndDragging(scrollView, withVelocity: velocity, targetContentOffset: targetContentOffset)
    }

    func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
        behavior.scrollViewWillBeginDragging(scrollView)
    }
}
