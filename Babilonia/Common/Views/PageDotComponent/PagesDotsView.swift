//
//  PagesDotsView.swift
//  Babilonia
//
//  Created by Alya Filon  on 12.11.2020.
//  Copyright © 2020 Yalantis. All rights reserved.
//

import UIKit

private typealias DotConfig = (dot: UIView, constraints: (NSLayoutConstraint?, NSLayoutConstraint?))

final class PagesDotsView: NiblessView {

    private let stackView: UIStackView = .init()
    private var dotsViews = [UIView]()
    private var sideConstraints = [(NSLayoutConstraint?, NSLayoutConstraint?)]()

    var actualContentCount: Int = 0
    var dotsCount: Int = 0 {
        didSet {
            drawDots()
        }
    }
    private let dotsMaxCount = 5
    private var lastSelectedIndex = 0

    override init() {
        super.init()

        setupView()
    }

    func setCurrentDot(at index: Int) {
        if actualContentCount <= dotsCount {
            setupDefaultSelection(for: index)
        } else {
            resetDotsSelection()
            let animationsCount = actualContentCount - dotsCount
            let centerIndex = 2
            if lastSelectedIndex <= index {
                if index <= centerIndex {
                    setupDefaultSelection(for: index)
                } else {
                    if index <= centerIndex + animationsCount {
                        let sourceDot = dotsViews[dotsViews.count - 2]
                        let targetDot = dotsViews[dotsViews.count - 3]
                        let sourceConstraint = sideConstraints[sideConstraints.count - 2]
                        let targetConstraint = sideConstraints[sideConstraints.count - 3]

                        proceedAnimationFlow(sourceDot: (dot: sourceDot, constraints: sourceConstraint),
                                             targetDot: (dot: targetDot, constraints: targetConstraint))
                    } else {
                        let fixedIndex = dotsMaxCount - (actualContentCount - index)

                        guard fixedIndex < dotsCount else { return }
                        setupDefaultSelection(for: fixedIndex)
                    }
                }
            } else {
                if index < centerIndex {
                    setupDefaultSelection(for: index)
                } else {
                    if index < centerIndex + animationsCount {
                        let sourceDot = dotsViews[1]
                        let targetDot = dotsViews[2]
                        let sourceConstraint = sideConstraints[1]
                        let targetConstraint = sideConstraints[2]

                        proceedAnimationFlow(sourceDot: (dot: sourceDot, constraints: sourceConstraint),
                                             targetDot: (dot: targetDot, constraints: targetConstraint))
                    } else {
                        let fixedIndex = dotsMaxCount - (actualContentCount - index)

                        guard fixedIndex < dotsCount else { return }
                        setupDefaultSelection(for: fixedIndex)
                    }
                }
            }
        }
        lastSelectedIndex = index
    }

    private func proceedAnimationFlow(sourceDot: DotConfig, targetDot: DotConfig) {
        setSelected(sourceDot)
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.2, execute: {
            self.animateSelection(sourceDot: sourceDot,
                                  targetDot: targetDot)
        })
    }

    private func animateSelection(sourceDot: DotConfig, targetDot: DotConfig) {
        sourceDot.dot.backgroundColor = UIColor.white.withAlphaComponent(0.5)
        sourceDot.constraints.0?.constant = 6
        sourceDot.constraints.1?.constant = 6

        targetDot.dot.backgroundColor = .white
        targetDot.constraints.0?.constant = 8
        targetDot.constraints.1?.constant = 8

        UIView.animate(withDuration: 0.2, animations: {
            sourceDot.dot.layerCornerRadius = 3
            targetDot.dot.layerCornerRadius = 4
            self.layoutIfNeeded()
        })
    }

    private func setSelected(_ dotConfig: DotConfig) {
        dotConfig.dot.backgroundColor = .white
        dotConfig.dot.layerCornerRadius = 4
        dotConfig.constraints.0?.constant = 8
        dotConfig.constraints.1?.constant = 8
    }

    private func setupDefaultSelection(for index: Int) {
        for (dotIndex, dotView) in dotsViews.enumerated() {
            let isCurrent = index == dotIndex
            let color = isCurrent ? .white : UIColor.white.withAlphaComponent(0.5)
            let cornerRadius: CGFloat = isCurrent ? 4 : 3
            let side: CGFloat = isCurrent ? 8 : 6
            let constraints = sideConstraints[dotIndex]

            dotView.layerCornerRadius = cornerRadius
            dotView.backgroundColor = color
            dotView.frame.size = CGSize(width: side, height: side)
            constraints.0?.constant = side
            constraints.1?.constant = side
        }
    }

    private func resetDotsSelection() {
        sideConstraints.forEach {
            $0.0?.constant = 6
            $0.1?.constant = 6
        }
        dotsViews.forEach {
            $0.layerCornerRadius = 3
            $0.backgroundColor = UIColor.white.withAlphaComponent(0.5)
        }
    }

}

extension PagesDotsView {

    private func setupView() {
        stackView.axis = .horizontal
        stackView.spacing = 5
        stackView.alignment = .center

        addSubview(stackView)
        stackView.pinEdges(to: self)
    }

    private func drawDots() {
        clearDots()
        for _ in 0..<dotsCount {
            let dotView = UIView()
            dotView.backgroundColor = UIColor.white.withAlphaComponent(0.5)
            dotView.layerCornerRadius = 3

            dotView.frame.size = CGSize(width: 6, height: 6)

            var heightConstraint: NSLayoutConstraint?
            var widthConstraint: NSLayoutConstraint?

            dotView.layout {
                heightConstraint = $0.height.equal(to: 6)
                widthConstraint = $0.width.equal(to: 6)
            }

            stackView.addArrangedSubview(dotView)
            dotsViews.append(dotView)
            sideConstraints.append((heightConstraint, widthConstraint))
        }
    }

    private func clearDots() {
        stackView.arrangedSubviews.forEach { $0.removeFromSuperview() }
        dotsViews.removeAll()
    }

}
