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

    private let colors: [UIColor] = [.red, .orange, .yellow, .green, .blue, .red]

    private var currentIndex = 0.0

    override func viewDidLoad() {
        super.viewDidLoad()
        setupViews()
        activateTimer()
    }
}

extension ViewController: UICollectionViewDataSource {
    func collectionView(
        _ collectionView: UICollectionView,
        numberOfItemsInSection section: Int
    ) -> Int {
        return colors.count
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
        cell.backgroundColor = colors[indexPath.row]
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

        if scrollView.contentOffset.x > targetContentOffset.pointee.x { roundedIndex = floor(index) }
        else if scrollView.contentOffset.x < targetContentOffset.pointee.x {
            roundedIndex = ceil(index)
        } else {
            roundedIndex = round(index)
        }
        currentIndex = roundedIndex
        offset = CGPoint(
            x: (roundedIndex * cellWidthIncludingSpacing) - scrollView.contentInset.left,
            y: -scrollView.contentInset.top
        )

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
            collectionView
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

    }

    func activateTimer() {
        let _ = Timer.scheduledTimer(
            timeInterval: 1,
            target: self,
            selector: #selector(repeatAction),
            userInfo: nil,
            repeats: true)
    }

    @objc func repeatAction() {
        if Int(currentIndex) == colors.count - 1 {
            collectionView.scrollToItem(at: IndexPath(row: 0, section: 0), at: .centeredHorizontally, animated: false)
            currentIndex = 0
            return
        }
        collectionView.scrollToItem(at: IndexPath(row: Int(currentIndex) + 1, section: 0), at: .centeredHorizontally, animated: true)
        currentIndex += 1


    }
}

