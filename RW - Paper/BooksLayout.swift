//
//  BooksLayout.swift
//  RW - Paper
//
//  Created by Abdelrahman-Arw on 12/10/19.
//  Copyright © 2019 -. All rights reserved.
//

import UIKit
private let PageWidth: CGFloat = 362
private let PageHeight: CGFloat = 568
class BooksLayout: UICollectionViewFlowLayout {

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        scrollDirection = UICollectionView.ScrollDirection.horizontal
        itemSize = CGSize(width: PageWidth, height: PageHeight)
        minimumLineSpacing = 10
    }
    override func prepare() {
        super.prepare()
        
        //The rate at which we scroll the collection view.
        //1
        collectionView?.decelerationRate = UIScrollView.DecelerationRate.fast
        
        //2
        collectionView?.contentInset = UIEdgeInsets(
            top: 0,
            left: collectionView!.bounds.width / 2 - PageWidth / 2,
            bottom: 0,
            right: collectionView!.bounds.width / 2 - PageWidth / 2
        )
    }
    override func layoutAttributesForElements(in rect: CGRect) -> [UICollectionViewLayoutAttributes]? {
        var array = super.layoutAttributesForElements(in: rect) as! [UICollectionViewLayoutAttributes]
        //2
        for attributes in array {
            //3
            var frame = attributes.frame
            //4
            var distance = abs(collectionView!.contentOffset.x + collectionView!.contentInset.left - frame.origin.x)
            //5
            var scale = 0.7 * min(max(1 - distance / (collectionView!.bounds.width), 0.75), 1)
            //6
            attributes.transform = CGAffineTransform(scaleX: scale, y: scale)
        }
        
        return array
    }
    override func shouldInvalidateLayout(forBoundsChange newBounds: CGRect) -> Bool {
        return true
    }
}
