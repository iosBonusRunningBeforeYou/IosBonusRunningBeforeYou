//
//  MemberViewController.swift
//  IosBonusRunningBeforeYou
//
//  Created by Edward on 2018/11/29.
//  Copyright © 2018 Apple. All rights reserved.
//

import UIKit

class MemberViewController: UIViewController {
    
    var pageViewController: UIPageViewController!
    @IBOutlet weak var sliderView: UIView!
    
    var pointRecordViewController: PointRecordViewController!
    var myCouponViewController: MyCouponViewController!
    var memberDataViewController: MemberDataViewController!
    var controllers = [UIViewController]()
    
    var sliderImageView: UIImageView!
    
    var lastPage = 0
    var currentPage: Int = 0 {
        didSet {
            //計算要顯示的大小
            let offset = self.view.frame.width / 3.0 * CGFloat(currentPage)
            UIView.animate(withDuration: 0.3) { () -> Void in
                self.sliderImageView.frame.origin = CGPoint(x: offset, y: -1)
            }
            //根據currentPage 和 lastPage的大小，控制切換方向
            if currentPage > lastPage {
                self.pageViewController.setViewControllers([controllers[currentPage]], direction: .forward, animated: true, completion: nil)
            }
            else {
                self.pageViewController.setViewControllers([controllers[currentPage]], direction: .reverse, animated: true, completion: nil)
            }
            lastPage = currentPage
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        pageViewController = self.children.first as! UIPageViewController
        let pageViewHeight = pageViewController.view.frame.height
        let pageViewWidth = pageViewController.view.frame.width
        
        //根據Storyboard ID 創建viewcontroller
        pointRecordViewController = storyboard?.instantiateViewController(withIdentifier: "PointRecordVC") as! PointRecordViewController
        myCouponViewController = storyboard?.instantiateViewController(withIdentifier: "MyCouponVC") as! MyCouponViewController
        memberDataViewController = storyboard?.instantiateViewController(withIdentifier: "MemberDataVC") as! MemberDataViewController
        
        
        //為pageViewController提供一個畫面
        pageViewController.setViewControllers([pointRecordViewController], direction: UIPageViewController.NavigationDirection.forward, animated: true, completion: nil)
        
        //添加顯示條到畫面
        sliderImageView = UIImageView(frame: CGRect(x: 0, y: -1, width: self.view.frame.width / 3.0, height: 3.0))
        sliderImageView.image = UIImage(named: "slider")
        sliderView.addSubview(sliderImageView)
        
        //把設定添加進去
        controllers.append(pointRecordViewController)
        controllers.append(myCouponViewController)
        controllers.append(memberDataViewController)
        
        //接收頁面的廣播通知
        NotificationCenter.default.addObserver(self, selector: #selector(MainViewController.currentPageChanged(notification:)), name: Notification.Name(rawValue: "currentPageChanged"), object: nil)
        
    }
    
    //通知方法
    @objc
    func currentPageChanged(notification: Notification) {
        //        showAlert(title: "currentPageChanged", message: "")
        currentPage = notification.object as! Int
    }
    @IBAction func changeCurrentPage(_ sender: UIButton) {
        currentPage = sender.tag - 100
    }
    
}
    
extension MemberViewController: UIPageViewControllerDataSource {
        
    //返回當前頁面的下一頁
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerAfter viewController: UIViewController) -> UIViewController? {
        if viewController.isKind(of: PointRecordViewController.self) {
            return myCouponViewController
        }
        else if viewController.isKind(of: MyCouponViewController.self) {
            return memberDataViewController
        }
        return nil
    }
    
    //返回當前頁面的下一頁
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerBefore viewController: UIViewController) -> UIViewController? {

        if viewController.isKind(of: PointRecordViewController.self) {
            return myCouponViewController
        }
        else if viewController.isKind(of: MyCouponViewController.self) {
            return memberDataViewController
        }
        return nil
    }
    
}
