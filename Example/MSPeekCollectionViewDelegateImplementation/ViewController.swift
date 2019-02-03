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
    var peekImplementation: MSPeekCollectionViewDelegateImplementation!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        peekImplementation = MSPeekCollectionViewDelegateImplementation()
        peekImplementation.delegate = self
        collectionView.configureForPeekingDelegate()
        collectionView.delegate = peekImplementation
        collectionView.dataSource = self
        
        initSliderValues()
    }
    
    func initSliderValues() {
        cellSpacingSlider.value = Float(peekImplementation.cellSpacing)
        cellPeekWidthSlider.value = Float(peekImplementation.cellPeekWidth)
        scrollThresholdSlider.value = Float(peekImplementation.scrollThreshold)
        maximumItemsToScrollSlider.value = Float(peekImplementation.maximumItemsToScroll)
        numberOfItemsToShowSlider.value = Float(peekImplementation.numberOfItemsToShow)
    }
    
    @IBAction func sliderValueDidChange(_ slider: CustomSlider) {
        if slider.isInt {
            let value = slider.value
            slider.value = Float(Int(value))
        }
        
        reloadDelegate()
    }
    
    func reloadDelegate() {
        peekImplementation = MSPeekCollectionViewDelegateImplementation(cellSpacing: CGFloat(cellSpacingSlider.value), cellPeekWidth: CGFloat(cellPeekWidthSlider.value), scrollThreshold: CGFloat(scrollThresholdSlider.value), maximumItemsToScroll: Int(maximumItemsToScrollSlider.value), numberOfItemsToShow: Int(numberOfItemsToShowSlider.value))
        collectionView.delegate = peekImplementation
        peekImplementation.delegate = self
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

extension ViewController: MSPeekImplementationDelegate {
    func peekImplementation(_ peekImplementation: MSPeekCollectionViewDelegateImplementation, didChangeActiveIndexTo activeIndex: Int) {
        print("Changed active index to \(activeIndex)")
    }
    
    func peekImplementation(_ peekImplementation: MSPeekCollectionViewDelegateImplementation, didSelectItemAt indexPath: IndexPath) {
        print("Selected item at \(indexPath)")
    }
}

