//
//  ViewController.swift
//  CarouselCollectionViewExample
//
//  Created by iMac on 2022/07/05.
//

import UIKit
import SnapKit

class ViewController: UIViewController {
    private lazy var collectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .horizontal
        layout.minimumLineSpacing = 16
        layout.itemSize = CGSize(
            width: UIScreen.main.bounds.width - 32,
            height: 300.0
        )

        let collectionView = UICollectionView(
            frame: .zero,
            collectionViewLayout: layout
        )
        collectionView.dataSource = self
        collectionView.delegate = self
        collectionView.register(UICollectionViewCell.self, forCellWithReuseIdentifier: "cell")
        collectionView.showsHorizontalScrollIndicator = false
        collectionView.contentInset = UIEdgeInsets(top: 0, left: 16, bottom: 0, right: 16)
        collectionView.isPagingEnabled = false
        collectionView.decelerationRate = .fast
        return collectionView
    }()

    private lazy var activateButton: UIButton = {
        let button = UIButton()
        button.layer.cornerRadius = 10
        button.layer.borderColor = UIColor.lightGray.cgColor
        button.layer.borderWidth = 0.3

        button.setTitleColor(.label, for: .normal)
        button.setTitle("Activate", for: .normal)

        button.addTarget(self, action: #selector(activateTimer), for: .touchUpInside)
        return button
    }()


    private let colors: [UIColor] = [.red, .orange, .yellow, .green, .blue]

    private var currentIndex = 0.0

    private var isActive: Bool = false

    private var timer: Timer?

    override func viewDidLoad() {
        super.viewDidLoad()
        setupViews()
    }

    override func viewDidLayoutSubviews() {
        let segmentSize = colors.count
        collectionView.scrollToItem(at: IndexPath(row: segmentSize, section: 0), at: .centeredHorizontally, animated: false)
        currentIndex = CGFloat(segmentSize)
    }
}

extension ViewController: UICollectionViewDataSource {
    func collectionView(
        _ collectionView: UICollectionView,
        numberOfItemsInSection section: Int
    ) -> Int {
        return colors.count * 3
    }

    func collectionView(
        _ collectionView: UICollectionView,
        cellForItemAt indexPath: IndexPath
    ) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(
            withReuseIdentifier: "cell",
            for: indexPath
        )
        cell.layer.cornerRadius = 10
        cell.backgroundColor = colors[indexPath.row % colors.count]
        return cell
    }
}

extension ViewController: UICollectionViewDelegateFlowLayout {
    func scrollViewWillEndDragging(
        _ scrollView: UIScrollView,
        withVelocity velocity: CGPoint,
        targetContentOffset: UnsafeMutablePointer<CGPoint>
    ) {
        guard let layout = collectionView.collectionViewLayout as? UICollectionViewFlowLayout else {
            return
        }
        let cellSize = UIScreen.main.bounds.width - 32

        let cellWidthIncludingSpacing = cellSize + layout.minimumLineSpacing

        var offset = targetContentOffset.pointee
        let index = (offset.x + scrollView.contentInset.left) / cellWidthIncludingSpacing
        var roundedIndex = round(index)
        print(roundedIndex)
        if scrollView.contentOffset.x > targetContentOffset.pointee.x { roundedIndex = floor(index) }
        else if scrollView.contentOffset.x < targetContentOffset.pointee.x {
            roundedIndex = ceil(index)
        } else {
            roundedIndex = round(index)
        }

        offset = CGPoint(
            x: (roundedIndex * cellWidthIncludingSpacing) - scrollView.contentInset.left,
            y: -scrollView.contentInset.top
        )

        print("scrollView.contentOffset.x: \(scrollView.contentOffset.x), scrollView.bounds.width * CGFloat(colors.count * 3) - ((32 * 15)): \(scrollView.bounds.width * CGFloat(colors.count * 3) - (32 * 15) - 16)")
        if scrollView.contentOffset.x <= (-16 - (cellSize / 4)) {
            roundedIndex = CGFloat(colors.count * 3 - 1)
            offset = CGPoint(
                x: (roundedIndex * cellWidthIncludingSpacing) - scrollView.contentInset.left,
                y: -scrollView.contentInset.top
            )
            targetContentOffset.pointee = offset


        } else if scrollView.contentOffset.x > scrollView.bounds.width * CGFloat(colors.count * 3) - (32 * 15) - 16 {
            roundedIndex = 0
            offset = CGPoint(
                x: (roundedIndex * cellWidthIncludingSpacing) - scrollView.contentInset.left,
                y: -scrollView.contentInset.top
            )
            targetContentOffset.pointee = offset

        } else {
            targetContentOffset.pointee = offset
        }
        targetContentOffset.pointee = offset
        
    }
}

extension ViewController: UICollectionViewDelegate {
    func collectionView(
        _ collectionView: UICollectionView,
        willDisplay cell: UICollectionViewCell,
        forItemAt indexPath: IndexPath
    ) {
        print(indexPath.row)
    }
}

private extension ViewController {
    func setupViews() {
        [
            collectionView,
            activateButton
        ]
            .forEach {
                view.addSubview($0)
            }

        collectionView.snp.makeConstraints {
            $0.top.equalTo(view.safeAreaLayoutGuide).offset(16.0)
            $0.leading.equalToSuperview()
            $0.trailing.equalToSuperview()
            $0.height.equalTo(300.0)
        }

        activateButton.snp.makeConstraints {
            $0.center.equalToSuperview()
            $0.width.equalTo(100.0)
            $0.height.equalTo(50.0)
        }

    }

    @objc func activateTimer() {
        if isActive {
            timer?.invalidate()
            activateButton.setTitle("Activate", for: .normal)
        } else {
            timer = Timer.scheduledTimer(
                timeInterval: 1,
                target: self,
                selector: #selector(repeatAction),
                userInfo: nil,
                repeats: true)
            activateButton.setTitle("Deactivate", for: .normal)
        }
        isActive = !isActive


    }


    func stopTimer() {
        guard let timer = self.timer else { return }

        if timer.isValid {
            timer.invalidate()
        }
    }

    @objc func repeatAction() {
        if Int(currentIndex) == colors.count * 3 - 1 {
            collectionView.scrollToItem(
                at: IndexPath(row: 0, section: 0),
                at: .centeredHorizontally, animated: false
            )
            currentIndex = 0
            return
        }
        currentIndex += 1
        collectionView.scrollToItem(
            at: IndexPath(row: Int(currentIndex), section: 0),
            at: .centeredHorizontally, animated: true
        )
    }
}

