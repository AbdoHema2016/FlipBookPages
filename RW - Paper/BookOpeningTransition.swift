//
//  BookOpeningTransition.swift
//  RW - Paper
//
//  Created by Abdelrahman-Arw on 12/10/19.
//  Copyright © 2019 -. All rights reserved.
//

import UIKit


//1
class BookOpeningTransition: NSObject, UIViewControllerAnimatedTransitioning {
    
    // MARK: Stored properties
    var transforms = [UICollectionViewCell: CATransform3D]() //2
    var toViewBackgroundColor: UIColor? //3
    var isPush = true //4
    // MARK: Interaction Controller
    var interactionController: UIPercentDrivenInteractiveTransition?
    
    //5
    // MARK: UIViewControllerAnimatedTransitioning
    func transitionDuration(using transitionContext: UIViewControllerContextTransitioning?) -> TimeInterval {
        if isPush {
            return 1
        } else {
            return 1
        }
    }
    // MARK: Helper Methods
    func makePerspectiveTransform() -> CATransform3D {
        var transform = CATransform3DIdentity
        transform.m34 = 1.0 / -2000
        return transform
    }
    func closePageCell(cell : BookPageCell) {
        // 1
        var transform = self.makePerspectiveTransform()
        // 2
        if cell.layer.anchorPoint.x == 0 {
            // 3
            transform = CATransform3DRotate(transform, CGFloat(0), 0, 1, 0)
            // 4
            transform = CATransform3DTranslate(transform, -0.7 * cell.layer.bounds.width / 2, 0, 0)
            // 5
            transform = CATransform3DScale(transform, 0.7, 0.7, 1)
        }
            // 6
        else {
            // 7
            transform = CATransform3DRotate(transform, CGFloat(-M_PI), 0, 1, 0)
            // 8
            transform = CATransform3DTranslate(transform, 0.7 * cell.layer.bounds.width / 2, 0, 0)
            // 9
            transform = CATransform3DScale(transform, 0.7, 0.7, 1)
        }
        
        //10
        cell.layer.transform = transform
    }
    func setStartPositionForPush(fromVC: BooksViewController, toVC: BookViewController) {
        // 1
        toViewBackgroundColor = fromVC.collectionView?.backgroundColor
        toVC.collectionView?.backgroundColor = nil
        
        //2
        fromVC.selectedCell()?.alpha = 0
        
        //3
        for cell in toVC.collectionView!.visibleCells as! [BookPageCell] {
            //4
            transforms[cell] = cell.layer.transform
            //5
            closePageCell(cell: cell)
            cell.updateShadowLayer()
            //6
            if let indexPath = toVC.collectionView?.indexPath(for: cell) {
                if indexPath.row == 0 {
                    cell.shadowLayer.opacity = 0
                }
            }
        }
    }
    func setEndPositionForPush(fromVC: BooksViewController, toVC: BookViewController) {
        //1
        for cell in fromVC.collectionView!.visibleCells as! [BookCoverCell] {
            cell.alpha = 0
        }
        
        //2
        for cell in toVC.collectionView!.visibleCells as! [BookPageCell] {
            cell.layer.transform = transforms[cell]!
            cell.updateShadowLayer(animated: true)
        }
    }
    
    func cleanupPush(fromVC: BooksViewController, toVC: BookViewController) {
        // Add background back to pushed view controller
        toVC.collectionView?.backgroundColor = toViewBackgroundColor
        // Pass the gesture recognizer
        toVC.recognizer = fromVC.recognizer
    }
    
    // MARK: Pop methods
    func setStartPositionForPop(fromVC: BookViewController, toVC: BooksViewController) {
        // Remove background from the pushed view controller
        toViewBackgroundColor = fromVC.collectionView?.backgroundColor
        fromVC.collectionView?.backgroundColor = nil
    }
    func setEndPositionForPop(fromVC: BookViewController, toVC: BooksViewController) {
        //1
        let coverCell = toVC.selectedCell()
        //2
        for cell in toVC.collectionView!.visibleCells as! [BookCoverCell] {
            if cell != coverCell {
                cell.alpha = 1
            }
        }
        //3
        for cell in fromVC.collectionView!.visibleCells as! [BookPageCell] {
            closePageCell(cell: cell)
        }
    }
    func cleanupPop(fromVC: BookViewController, toVC: BooksViewController) {
        // Add background back to pushed view controller
        fromVC.collectionView?.backgroundColor = self.toViewBackgroundColor
        // Unhide the original book cover
        toVC.selectedCell()?.alpha = 1
        // Pass the gesture recognizer
        toVC.recognizer = fromVC.recognizer
    }
    
    func animateTransition(using transitionContext: UIViewControllerContextTransitioning) {
        //1
        let container = transitionContext.containerView
        //2
        if isPush {
            //3
            let fromVC = transitionContext.viewController(forKey: UITransitionContextViewControllerKey.from) as! BooksViewController
            let toVC = transitionContext.viewController(forKey: UITransitionContextViewControllerKey.to) as! BookViewController
            //4
            container.addSubview(toVC.view)
            
            // Perform transition
            //5
            self.setStartPositionForPush(fromVC: fromVC, toVC: toVC)
            
            UIView.animate(withDuration: self.transitionDuration(using: transitionContext), delay: 0.0,usingSpringWithDamping: 0.7, initialSpringVelocity: 0.7, animations: {
                //6
                self.setEndPositionForPush(fromVC: fromVC, toVC: toVC)
            }, completion: { finished in
                //7
                self.cleanupPush(fromVC: fromVC, toVC: toVC)
                //8
                transitionContext.completeTransition(finished)
            })
            
        } else {
            //POP
            //1
            let fromVC = transitionContext.viewController(forKey: UITransitionContextViewControllerKey.from) as! BookViewController
            let toVC = transitionContext.viewController(forKey: UITransitionContextViewControllerKey.to) as! BooksViewController
            
            //2
            container.insertSubview(toVC.view, belowSubview: fromVC.view)
            
            //3
            setStartPositionForPop(fromVC: fromVC, toVC: toVC)
           
            UIView.animate(withDuration: self.transitionDuration(using: transitionContext), animations: {
                //6
                self.setEndPositionForPop(fromVC: fromVC, toVC: toVC)
            }, completion: { finished in
                //7
                self.cleanupPop(fromVC: fromVC, toVC: toVC)
                //8
                transitionContext.completeTransition(finished)
            })
        }
    }
}
