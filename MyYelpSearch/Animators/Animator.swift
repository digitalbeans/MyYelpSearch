//
//  Animator.swift
//  MyYelpSearch
//
//  Created by Dean Thibault on 5/3/20.
//  Copyright © 2020 Digital Beans. All rights reserved.
//

import UIKit

final class Animator: NSObject, UIViewControllerAnimatedTransitioning {

    static let duration: TimeInterval = 1.0

    private let type: PresentationType
    private let firstViewController: RootViewController
    private let secondViewController: DetailViewController
    private var selectedCellImageViewSnapshot: UIView
    private let cellImageViewRect: CGRect

    private let cellLabelRect: CGRect

    init?(type: PresentationType, firstViewController: RootViewController, secondViewController: DetailViewController, selectedCellImageViewSnapshot: UIView) {
        self.type = type
        self.firstViewController = firstViewController
        self.secondViewController = secondViewController
        self.selectedCellImageViewSnapshot = selectedCellImageViewSnapshot

        guard let window = firstViewController.view.window ?? secondViewController.view.window,
            let selectedCell = firstViewController.selectedCell
            else { return nil }

        self.cellImageViewRect = selectedCell.businessImageView.convert(selectedCell.businessImageView.bounds, to: window)
        self.cellLabelRect = selectedCell.titleLabel.convert(selectedCell.titleLabel.bounds, to: window)
    }

    func transitionDuration(using transitionContext: UIViewControllerContextTransitioning?) -> TimeInterval {
        return Self.duration
    }

    func animateTransition(using transitionContext: UIViewControllerContextTransitioning) {
        let containerView = transitionContext.containerView

        guard let toView = secondViewController.view
            else {
                transitionContext.completeTransition(false)
                return
        }

        containerView.addSubview(toView)

        guard
            let selectedCell = firstViewController.selectedCell,
            let window = firstViewController.view.window ?? secondViewController.view.window,
            let cellImageSnapshot = selectedCell.businessImageView.snapshotView(afterScreenUpdates: true),
            let controllerImageSnapshot = secondViewController.businessImageView.snapshotView(afterScreenUpdates: true),
            let cellLabelSnapshot = selectedCell.titleLabel.snapshotView(afterScreenUpdates: true),
            let closeButtonSnapshot = secondViewController.closeButton.snapshotView(afterScreenUpdates: true)
            else {
                transitionContext.completeTransition(true)
                return
        }

        let isPresenting = type.isPresenting
        let backgroundView: UIView
        let fadeView = UIView(frame: containerView.bounds)
        fadeView.backgroundColor = secondViewController.view.backgroundColor

		if isPresenting {
            selectedCellImageViewSnapshot = cellImageSnapshot

            backgroundView = UIView(frame: containerView.bounds)
            backgroundView.addSubview(fadeView)
            fadeView.alpha = 0
        } else {
            backgroundView = firstViewController.view.snapshotView(afterScreenUpdates: true) ?? fadeView
            backgroundView.addSubview(fadeView)
        }

        toView.alpha = 0

        [backgroundView, selectedCellImageViewSnapshot, controllerImageSnapshot, cellLabelSnapshot, closeButtonSnapshot].forEach { containerView.addSubview($0) }

        let controllerImageViewRect = secondViewController.businessImageView.convert(secondViewController.businessImageView.bounds, to: window)
        let controllerLabelRect = secondViewController.titleLabel.convert(secondViewController.titleLabel.bounds, to: window)
        let closeButtonRect = secondViewController.closeButton.convert(secondViewController.closeButton.bounds, to: window)

        [selectedCellImageViewSnapshot, controllerImageSnapshot].forEach {
            $0.frame = isPresenting ? cellImageViewRect : controllerImageViewRect
            $0.layer.cornerRadius = isPresenting ? 12 : 0
            $0.layer.masksToBounds = true
        }

        controllerImageSnapshot.alpha = isPresenting ? 0 : 1
        selectedCellImageViewSnapshot.alpha = isPresenting ? 1 : 0
        cellLabelSnapshot.frame = isPresenting ? cellLabelRect : controllerLabelRect
        closeButtonSnapshot.frame = closeButtonRect
        closeButtonSnapshot.alpha = isPresenting ? 0 : 1

        UIView.animateKeyframes(withDuration: Self.duration, delay: 0, options: .calculationModeCubic, animations: {

            UIView.addKeyframe(withRelativeStartTime: 0, relativeDuration: 1) {

				self.selectedCellImageViewSnapshot.frame = isPresenting ? controllerImageViewRect : self.cellImageViewRect
                controllerImageSnapshot.frame = isPresenting ? controllerImageViewRect : self.cellImageViewRect
                fadeView.alpha = isPresenting ? 1 : 0
                cellLabelSnapshot.frame = isPresenting ? controllerLabelRect : self.cellLabelRect
                [controllerImageSnapshot, self.selectedCellImageViewSnapshot].forEach {
                    $0.layer.cornerRadius = isPresenting ? 0 : 12
                }
            }

            UIView.addKeyframe(withRelativeStartTime: 0, relativeDuration: 0.6) {
                self.selectedCellImageViewSnapshot.alpha = isPresenting ? 0 : 1
                controllerImageSnapshot.alpha = isPresenting ? 1 : 0
            }

            UIView.addKeyframe(withRelativeStartTime: isPresenting ? 0.7 : 0, relativeDuration: 0.3) {
                closeButtonSnapshot.alpha = isPresenting ? 1 : 0
            }
        }, completion: { _ in

			self.selectedCellImageViewSnapshot.removeFromSuperview()
            controllerImageSnapshot.removeFromSuperview()
            backgroundView.removeFromSuperview()
            cellLabelSnapshot.removeFromSuperview()
            closeButtonSnapshot.removeFromSuperview()
            toView.alpha = 1
            transitionContext.completeTransition(true)
        })
    }
}

enum PresentationType {

    case present
    case dismiss

    var isPresenting: Bool {
        return self == .present
    }
}
