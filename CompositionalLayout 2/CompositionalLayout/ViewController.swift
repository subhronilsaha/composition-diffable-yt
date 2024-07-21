//
//  ViewController.swift
//  CompositionalLayout
//
//  Created by Subhronil Test on 24/04/24.
//

import UIKit

enum Section: Hashable {
    case first(Item?)
    case second(Item?)
    case third(Item?)
}
struct Item: Hashable {
    let uuid = UUID()
    var color: UIColor = .clear
}

class ViewController: UIViewController {

    private let collectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .vertical
        let view = UICollectionView(frame: .zero, collectionViewLayout: layout)
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = .systemPink
        return view
    }()
    
    var dataSource: UICollectionViewDiffableDataSource<Section, Item>!
    private var sectionData: [[Section]] = [
        [
            Section.first(Item(color: .yellow)),
            Section.first(Item(color: .yellow)),
            Section.first(Item(color: .yellow)),
            Section.first(Item(color: .yellow))
        ],
        [
            Section.second(Item(color: .yellow)),
            Section.second(Item(color: .yellow)),
            Section.second(Item(color: .yellow)),
            Section.second(Item(color: .yellow))
        ],
        [
            Section.third(Item(color: .yellow)),
            Section.third(Item(color: .yellow)),
            Section.third(Item(color: .yellow)),
            Section.third(Item(color: .yellow))
        ]
    ]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        createViews()
        setupCollectionView()
        setupDatasource()
        setupNav()
    }

    private func setupNav() {
        title = "Diffable"
        let rightBtn = UIBarButtonItem(image: .init(systemName: "plus"),
                                       style: .plain,
                                       target: self,
                                       action: #selector(addItem))
        navigationItem.rightBarButtonItem = rightBtn
        let leftBtn = UIBarButtonItem(image: .init(systemName: "minus"),
                                      style: .plain,
                                      target: self,
                                      action: #selector(minusItem))
        navigationItem.leftBarButtonItem = leftBtn
    }
    @objc func addItem() {
        let newItem = Section.third(Item(color: .systemBlue))
        sectionData[2].append(newItem)
        updateDatasource()
    }
    @objc func minusItem() {
        if sectionData[2].count > 0 {
            sectionData[2].removeLast()
        }
        updateDatasource()
    }
    
    
    private func createViews() {
        self.view.addSubview(collectionView)
        NSLayoutConstraint.activate([
            collectionView.topAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.topAnchor),
            collectionView.bottomAnchor.constraint(equalTo: self.view.bottomAnchor),
            collectionView.leadingAnchor.constraint(equalTo: self.view.leadingAnchor),
            collectionView.trailingAnchor.constraint(equalTo: self.view.trailingAnchor)
        ])
    }
    
    private func setupCollectionView() {
        registerCells()
        collectionView.setCollectionViewLayout(createLayout(), animated: true)
    }
    private func registerCells() {
        collectionView.register(MyCollectionViewCell.self,
                                forCellWithReuseIdentifier: MyCollectionViewCell.self.description())
        collectionView.register(MyHeaderCell.self,
                                forSupplementaryViewOfKind: MyHeaderCell.self.description(),
                                withReuseIdentifier: MyHeaderCell.self.description())
        collectionView.register(MyFooterCell.self,
                                forSupplementaryViewOfKind: MyFooterCell.self.description(),
                                withReuseIdentifier: MyFooterCell.self.description())
    }
}

// MARK: Compositional Layout
extension ViewController {
    private func createLayout() -> UICollectionViewLayout {
        let layout = UICollectionViewCompositionalLayout { [weak self] index, env in
            return self?.getSectionLayoutFor(section: index, env: env)
        }
        let config = UICollectionViewCompositionalLayoutConfiguration()
        config.interSectionSpacing = 10
        layout.configuration = config
        return layout
    }
    private func getSectionLayoutFor(section: Int, env: NSCollectionLayoutEnvironment) -> NSCollectionLayoutSection {
        let sectionEnum = dataSource.sectionIdentifier(for: section)
        switch sectionEnum {
        case .first: return createSection(itemHeight: .absolute(150),
                                     itemWidth: .fractionalWidth(1),
                                     groupHeight: .absolute(150),
                                     groupWidth: .fractionalWidth(1),
                                     scrollingBehaviour: .groupPagingCentered)
        case .second: return createSection(itemHeight: .absolute(100),
                                     itemWidth: .fractionalWidth(1/3),
                                     interItemSpacing: 10,
                                     groupHeight: .absolute(100),
                                     groupWidth: .fractionalWidth(1),
                                     interGroupSpacing: 10,
                                     sectionInsets: .init(top: 0, leading: 10, bottom: 0, trailing: 10),
                                     scrollingBehaviour: .continuous,
                                     headerHeight: 50,
                                     footerHeight: 50)
        case .third: return createSection(itemHeight: .absolute(100),
                                     itemWidth: .fractionalWidth(1/3),
                                     interItemSpacing: 10,
                                     groupHeight: .estimated(100),
                                     groupWidth: .fractionalWidth(1),
                                     interGroupSpacing: 10,
                                     sectionInsets: .init(top: 0, leading: 10, bottom: 0, trailing: 10))
        default: break
        }
        return emptySection(height: 100.0)
    }
    private func emptySection(height: Double = 0) -> NSCollectionLayoutSection  {
        return createSection(itemHeight: .absolute(height),
                             itemWidth: .fractionalWidth(1),
                             groupHeight: .absolute(height),
                             groupWidth: .fractionalWidth(1))
    }
    private func createSection(itemHeight: NSCollectionLayoutDimension,
                               itemWidth: NSCollectionLayoutDimension,
                               itemInset: NSDirectionalEdgeInsets = .zero,
                               interItemSpacing: Double = 0,
                               groupHeight: NSCollectionLayoutDimension,
                               groupWidth: NSCollectionLayoutDimension,
                               interGroupSpacing: Double = 0,
                               sectionInsets: NSDirectionalEdgeInsets = .zero,
                               scrollingBehaviour: UICollectionLayoutSectionOrthogonalScrollingBehavior = .none,
                               headerHeight: CGFloat? = nil,
                               footerHeight: CGFloat? = nil)
    -> NSCollectionLayoutSection {
        let itemSize = NSCollectionLayoutSize(widthDimension: itemWidth,
                                              heightDimension: itemHeight)
        let item = NSCollectionLayoutItem(layoutSize: itemSize)
        item.contentInsets = itemInset
        let groupSize = NSCollectionLayoutSize(widthDimension: groupWidth,
                                               heightDimension: groupHeight)
        let group = NSCollectionLayoutGroup.horizontal(layoutSize: groupSize,
                                                       subitems: [item])
        group.interItemSpacing = .fixed(interItemSpacing)
        let section = NSCollectionLayoutSection(group: group)
        section.orthogonalScrollingBehavior = scrollingBehaviour
        section.interGroupSpacing = interGroupSpacing
        section.contentInsets = sectionInsets
        
        section.boundarySupplementaryItems = []
        
        if let headerHeight = headerHeight {
            let headerSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1),
                                                    heightDimension: .estimated(headerHeight))
            let header = NSCollectionLayoutBoundarySupplementaryItem(layoutSize: headerSize,
                                                                     elementKind: MyHeaderCell.self.description(),
                                                                     alignment: .top)
            section.boundarySupplementaryItems.append(header)
        }
        
        if let footerHeight = footerHeight {
            let footerSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1),
                                                    heightDimension: .estimated(footerHeight))
            let footer = NSCollectionLayoutBoundarySupplementaryItem(layoutSize: footerSize,
                                                                     elementKind: MyFooterCell.self.description(),
                                                                     alignment: .bottom)
            section.boundarySupplementaryItems.append(footer)
        }
        return section
    }
}

extension ViewController {
    private func setupDatasource() {
        createDatasource()
        updateDatasource()
    }
    private func createDatasource() {
        dataSource = UICollectionViewDiffableDataSource(collectionView: collectionView,
                                                        cellProvider: { [weak self] collectionView, indexPath, itemIdentifier in
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: MyCollectionViewCell.self.description(),
                                                          for: indexPath) as! MyCollectionViewCell
            let section = self?.sectionData[indexPath.section][indexPath.item]
            switch section {
            case .first(let data): cell.backgroundColor = data?.color
            case .second(let data): cell.backgroundColor = data?.color
            case .third(let data): cell.backgroundColor = data?.color
            default: cell.backgroundColor = .clear
            }
            cell.layer.borderColor = UIColor.black.cgColor
            cell.layer.borderWidth = 1.0
            return cell
        })
        dataSource.supplementaryViewProvider = { collectionView, kind, indexPath in
            if kind == MyHeaderCell.self.description() {
                let cell = collectionView.dequeueReusableSupplementaryView(ofKind: kind,
                                                                           withReuseIdentifier: MyHeaderCell.self.description(),
                                                                           for: indexPath) as! MyHeaderCell
                cell.backgroundColor = .gray
                return cell
            } else if kind == MyFooterCell.self.description() {
                let cell = collectionView.dequeueReusableSupplementaryView(ofKind: kind,
                                                                           withReuseIdentifier: MyFooterCell.self.description(),
                                                                           for: indexPath) as! MyFooterCell
                cell.backgroundColor = .purple
                return cell
            }
            return collectionView.dequeueReusableSupplementaryView(ofKind: kind,
                                                                   withReuseIdentifier: UICollectionViewCell.self.description(),
                                                                   for: indexPath)
        }
    }
    private func updateDatasource() {
        var snapshot = NSDiffableDataSourceSnapshot<Section, Item>()
        for section in sectionData {
            let sectionName = section[0]
            var items = [Item]()
            for item in section {
                switch item {
                case .first(let data) : if let data = data {
                    items.append(data)
                }
                case .second(let data): if let data = data {
                    items.append(data)
                }
                case .third(let data): if let data = data {
                    items.append(data)
                }
                default: break
                }
            }
            snapshot.appendSections([sectionName])
            snapshot.appendItems(items, toSection: sectionName)
        }
        dataSource.apply(snapshot, animatingDifferences: true)
    }
}
