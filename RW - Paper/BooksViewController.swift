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
    
    var books: Array<Book>? {
        didSet {
            collectionView?.reloadData()
        }
    }
	
    override func viewDidLoad() {
        super.viewDidLoad()
        books = BookStore.sharedInstance.loadBooks(plist: "Books")
        
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
    func openBook() {
        let vc = storyboard?.instantiateViewController(withIdentifier: "BookViewController") as! BookViewController
        vc.book = selectedCell()?.book
        // UICollectionView loads it's cells on a background thread, so make sure it's loaded before passing it to the animation handler
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

// MARK: UICollectionViewDelegate

extension BooksViewController {
    

    override func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        var book = books?[indexPath.row]
        openBook()
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
