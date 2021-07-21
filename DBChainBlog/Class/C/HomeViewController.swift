//
//  HomeViewController.swift
//  DBChainBlog
//
//  Created by iOS on 2021/6/21.
//

import UIKit
import DBChainKit

class HomeViewController: BaseViewController {

    var segmentedDataSource: JXSegmentedBaseDataSource?
    let segmentedView = JXSegmentedView()
    lazy var listContainerView: JXSegmentedListContainerView! = {
        return JXSegmentedListContainerView(dataSource: self)
    }()
    let titles = ["POPULAR","最新","评论最多"]
    var rightIconBtn = UIButton()

    lazy var homeView : HomeView = {
        let view = HomeView.init(frame: self.view.frame)
        return view
    }()

    lazy var headerView : UIView = {
        let view = UIView.init(frame: CGRect(x: 0, y: 46, width: SCREEN_WIDTH, height: 50))
        view.backgroundColor = .clear
        let backView = UIView.init(frame: CGRect(x: 16, y: 20, width: SCREEN_WIDTH - 32, height: 50))
        backView.backgroundColor = .colorWithHexString("EFEFEF")
        backView.extSetCornerRadius(10)
        view.addSubview(backView)
        let searchImgV = UIImageView.init(frame: CGRect(x: backView.frame.width - 38, y: 10, width: 28, height: 28))
        searchImgV.image = UIImage(named: "home_search_image")
        backView.addSubview(searchImgV)
        return view
    }()

    lazy var blogBtn : UIButton = {
        let btn = UIButton.init(frame: CGRect(x: SCREEN_WIDTH * 0.5 - 100, y: SCREEN_HEIGHT - kTabBarHeight - 88, width: 200, height: 52))
        btn.setTitle("写博客", for: .normal)
        btn.setTitleColor(.white, for: .normal)
        btn.titleLabel?.font = UIFont.ThemeFont.H2Regular
        btn.backgroundColor = .colorWithHexString("2E44FF")
        btn.extSetCornerRadius(18)
        btn.addTarget(self, action: #selector(writeBlogClick), for: .touchUpInside)
        return btn
    }()

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)

        //离开页面的时候，需要恢复屏幕边缘手势，不能影响其他页面
        navigationController?.interactivePopGestureRecognizer?.isEnabled = true
    }


    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        segmentedView.frame = CGRect(x: 0, y: 0, width: view.bounds.size.width - 20, height: 50)
        listContainerView.frame = CGRect(x: 0, y: 50, width: view.bounds.size.width, height: view.bounds.size.height - 50)
    }

    deinit {
        NotificationCenter.default.removeObserver(self)
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        //处于第一个item的时候，才允许屏幕边缘手势返回
        navigationController?.interactivePopGestureRecognizer?.isEnabled = (segmentedView.selectedIndex == 0)
    }

    override func setupUI() {
        super.setupUI()
        
        NotificationCenter.default.addObserver(self, selector: #selector(iconImageUploadSuccessEvent), name: NSNotification.Name(rawValue: USERICONUPLOADSUCCESS), object: nil)
        view.backgroundColor = .colorWithHexString("F8F8F8")
        let titleDataSource = JXSegmentedTitleDataSource()
        titleDataSource.isTitleColorGradientEnabled = true
        titleDataSource.titleNormalColor = .colorWithHexString("444444")
        titleDataSource.titleSelectedColor = .colorWithHexString("444444")
        titleDataSource.titleNormalFont = UIFont.ThemeFont.H2Regular
        titleDataSource.titleSelectedFont = UIFont.ThemeFont.H2Bold
        titleDataSource.isTitleZoomEnabled = true
        titleDataSource.titleSelectedZoomScale = 1.2
        titleDataSource.isTitleStrokeWidthEnabled = true
        titleDataSource.titles = titles
        titleDataSource.isItemSpacingAverageEnabled = false
        titleDataSource.itemSpacing = 30
        segmentedDataSource = titleDataSource
        segmentedView.dataSource = segmentedDataSource
        segmentedView.delegate = self
        view.addSubview(segmentedView)

        segmentedView.listContainer = listContainerView
        segmentedView.backgroundColor = .colorWithHexString("F8F8F8")
        view.addSubview(listContainerView)
        view.addSubview(headerView)
        view.addSubview(blogBtn)
    }

    override func setNavBar() {
        super.setNavBar()

        self.navigationController?.navigationBar.barTintColor = .colorWithHexString("F8F8F8")
        let navContentView = UIView.init(frame: CGRect(x: 0, y: 0, width: SCREEN_WIDTH, height: kNavBarHeight))
        self.navigationItem.leftBarButtonItem = UIBarButtonItem(customView: navContentView)

        let leftImgV = UIImageView.init(image: UIImage(named: "creat_top_image"))
        leftImgV.frame = CGRect(x: 0, y: 0, width: 178, height: 40)
        navContentView.addSubview(leftImgV)

        rightIconBtn = UIButton.init(frame: CGRect(x: navContentView.frame.width - 76, y: 0, width: 40, height: 40))
        rightIconBtn.extSetCornerRadius(20)
        let filePath = documentTools() + "/USERICONPATH"
        if FileTools.sharedInstance.isFileExisted(fileName: USERICONPATH, path: filePath) == true {
            let fileDic = FileTools.sharedInstance.filePathsWithDirPath(path: filePath)
            do{
                let imageData = try Data(contentsOf: URL.init(fileURLWithPath: fileDic[0]))
                rightIconBtn.setImage(UIImage(data: imageData), for: .normal)
            }catch{
                rightIconBtn.setImage(UIImage(named: "home_icon_image"), for: .normal)
            }
        } else {
            rightIconBtn.setImage(UIImage(named: "home_icon_image"), for: .normal)
        }
        rightIconBtn.addTarget(self, action: #selector(checkHomePageClick), for: .touchUpInside)
        navContentView.addSubview(rightIconBtn)
    }

    @objc func writeBlogClick() {
        let vc = ReleaseBlogViewController()
        self.navigationController?.pushViewController(vc, animated: true)
    }

    @objc func checkHomePageClick(){
        let vc = MinePageViewController()
        self.navigationController?.pushViewController(vc, animated: true)
    }

    /// 更换头像
    @objc func iconImageUploadSuccessEvent(){
        let filePath = documentTools() + "/USERICONPATH"
        let fileDic = FileTools.sharedInstance.filePathsWithDirPath(path: filePath)
        do{
            let imageData = try Data(contentsOf: URL.init(fileURLWithPath: fileDic[0]))
            rightIconBtn.setImage(UIImage(data: imageData), for: .normal)

        }catch{

            rightIconBtn.setImage(UIImage(named: "home_icon_image"), for: .normal)
        }
    }
}

extension HomeViewController: JXSegmentedViewDelegate ,JXSegmentedListContainerViewDataSource {

    func numberOfLists(in listContainerView: JXSegmentedListContainerView) -> Int {
        if let titleDataSource = segmentedView.dataSource as? JXSegmentedBaseDataSource {
            return titleDataSource.dataSource.count
        }
        return 0
    }

    func listContainerView(_ listContainerView: JXSegmentedListContainerView, initListAt index: Int) -> JXSegmentedListContainerViewListDelegate {

        let vc = HomeListViewController()
        return vc
    }


    func segmentedView(_ segmentedView: JXSegmentedView, didSelectedItemAt index: Int) {
        if let dotDataSource = segmentedDataSource as? JXSegmentedDotDataSource {
            //先更新数据源的数据
            dotDataSource.dotStates[index] = false
            //再调用reloadItem(at: index)
            segmentedView.reloadItem(at: index)
        }
        navigationController?.interactivePopGestureRecognizer?.isEnabled = (segmentedView.selectedIndex == 0)
    }

}
