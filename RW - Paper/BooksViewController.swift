/*
* Copyright (c) 2015 Razeware LLC
*
* Permission is hereby granted, free of charge, to any person obtaining a copy
* of this software and associated documentation files (the "Software"), to deal
* in the Software without restriction, including without limitation the rights
* to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
* copies of the Software, and to permit persons to whom the Software is
* furnished to do so, subject to the following conditions:
*
* The above copyright notice and this permission notice shall be included in
* all copies or substantial portions of the Software.
*
* THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
* IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
* FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
* AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
* LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
* OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
* THE SOFTWARE.
*/

import UIKit

class BooksViewController: UICollectionViewController {

    var transition: BookOpeningTransition?
    //1
    var interactionController: UIPercentDrivenInteractiveTransition?
    //2
    var recognizer: UIGestureRecognizer? {
        didSet {
            if let recognizer = recognizer {
                collectionView?.addGestureRecognizer(recognizer)
            }
        }
    }
    var books: Array<Book>? {
        didSet {
            collectionView?.reloadData()
        }
    }
	
    override func viewDidLoad() {
        super.viewDidLoad()
        books = BookStore.sharedInstance.loadBooks(plist: "Books")
        recognizer = UIPinchGestureRecognizer(target: self, action: "handlePinch:")
        
    }
    // MARK: Gesture recognizer action
    func handlePinch(recognizer: UIPinchGestureRecognizer) {
        switch recognizer.state {
        case .began:
            //1
            interactionController = UIPercentDrivenInteractiveTransition()
            //2
            if recognizer.scale >= 1 {
                //3
                if recognizer.view == collectionView {
                    //4
                    var book = self.selectedCell()?.book
                    //5
                    self.openBook(book: book)
                }
                //6
            } else {
                //7
                navigationController?.popViewController(animated: true)
            }
        case .changed:
            //8
            if transition!.isPush {
                //9
                var progress = min(max(abs((recognizer.scale - 1)) / 5, 0), 1)
                //10
                interactionController?.update(progress)
                //11
            } else {
                //12
                var progress = min(max(abs((1 - recognizer.scale)), 0), 1)
                //13
                interactionController?.update(progress)
            }
        case .ended:
            //14
            interactionController?.finish()
            //15
            interactionController = nil
        default:
            break
        }
    }

    
    // MARK: Helpers
    func selectedCell() -> BookCoverCell? {
        if let indexPath = collectionView?.indexPathForItem(at: CGPoint(x: collectionView.contentOffset.x + collectionView!.bounds.width / 2, y: collectionView.bounds.height / 2)){
            if let cell = collectionView.cellForItem(at: indexPath) as? BookCoverCell {
                return cell
                
            }
        }
        return nil
    }
    func openBook(book: Book?) {
        let vc = storyboard?.instantiateViewController(withIdentifier: "BookViewController") as! BookViewController
        vc.book = selectedCell()?.book
        // UICollectionView loads it's cells on a background thread, so make sure it's loaded before passing it to the animation handler
        //1
        vc.view.snapshotView(afterScreenUpdates: true)
        DispatchQueue.main.async {
            self.navigationController?.pushViewController(vc, animated: true)
            return
        }
        
    }
//    func openBook(book: Book?) {
//        let vc = storyboard?.instantiateViewController(withIdentifier: "BookViewController") as! BookViewController
//        vc.book = book
//        // UICollectionView loads it's cells on a background thread, so make sure it's loaded before passing it to the animation handler
//        DispatchQueue.global(qos: .background).async {
//
//            // Background Thread
//
//            DispatchQueue.main.async {
//               self.navigationController?.pushViewController(vc, animated: true)
//            }
//        }
//
//    }
    
}
extension BooksViewController {
    func animationControllerForPresentController(vc: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        // 1
        var transition = BookOpeningTransition()
        // 2
        transition.isPush = true
        transition.interactionController = interactionController
        // 3
        self.transition = transition
        // 4
        return transition
    }
    func animationControllerForDismissController(vc: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        var transition = BookOpeningTransition()
        transition.isPush = false
        transition.interactionController = interactionController
        self.transition = transition
        return transition
    }
}

// MARK: UICollectionViewDelegate

extension BooksViewController {
    

    override func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        var book = books?[indexPath.row]
        openBook(book: book)
    }
    
}

// MARK: UICollectionViewDataSource

extension BooksViewController {
    

    override func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if let books = books {
            return books.count
        }
        return 0
    }
    
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        var cell = collectionView .dequeueReusableCell(withReuseIdentifier: "BookCoverCell", for: indexPath as IndexPath) as! BookCoverCell
        
        cell.book = books?[indexPath.row]
        
        return cell
    }
    
}
