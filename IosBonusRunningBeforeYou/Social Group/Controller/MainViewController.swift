//
//  ViewController.swift
//  pageViewDemo
//
//  Created by Apple on 2018/11/19.
//  Copyright © 2018 Apple. All rights reserved.
//

import UIKit

class MainViewController: UIViewController {

    var pageViewController: UIPageViewController!
    @IBOutlet weak var sliderView: UIView!
    
    var gameViewController: GameViewController!
    var goFriendsViewController: GoFriendsViewController!
    var controllers = [UIViewController]()
    
    var sliderImageView: UIImageView!
    
    var lastPage = 0
    var currentPage: Int = 0 {
        didSet {
            //計算要顯示的大小
            let offset = self.view.frame.width / 2.0 * CGFloat(currentPage)
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
        // Do any additional setup after loading the view, typically from a nib.
        
        pageViewController = self.children.first as! UIPageViewController
        let pageViewHeight = pageViewController.view.frame.height
        let pageViewWidth = pageViewController.view.frame.width
        
        //根據Storyboard ID 創建viewcontroller
        gameViewController = storyboard?.instantiateViewController(withIdentifier: "GameVC") as! GameViewController
        goFriendsViewController = storyboard?.instantiateViewController(withIdentifier: "GoFriendsVC") as! GoFriendsViewController
        goFriendsViewController.view.bounds = CGRect(x: 0, y: 0, width: pageViewWidth, height: pageViewHeight)
        
        pageViewController.dataSource = self
        
        //為pageViewController提供一個畫面
        pageViewController.setViewControllers([gameViewController], direction: UIPageViewController.NavigationDirection.forward, animated: true, completion: nil)
        
        //添加顯示條到畫面
        sliderImageView = UIImageView(frame: CGRect(x: 0, y: -1, width: self.view.frame.width / 2.0, height: 3.0))
        sliderImageView.image = UIImage(named: "slider")
        sliderView.addSubview(sliderImageView)
        
        //把設定添加進去
        controllers.append(gameViewController)
        controllers.append(goFriendsViewController)
        
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

extension MainViewController: UIPageViewControllerDataSource {
    
    //返回當前頁面的下一頁
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerAfter viewController: UIViewController) -> UIViewController? {
        if viewController.isKind(of: GameViewController.self) {
            return goFriendsViewController
        }
        return nil
    }
    
    //返回當前頁面的下一頁
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerBefore viewController: UIViewController) -> UIViewController? {
        
        if viewController.isKind(of: GoFriendsViewController.self) {
            return gameViewController
        }
        return nil
    }
}
