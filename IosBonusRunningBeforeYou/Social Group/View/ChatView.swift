//
//  ChatView.swift
//  HelloMpPushMessage
//
//  Created by Apple on 2018/10/25.
//  Copyright © 2018 Apple. All rights reserved.
//

import UIKit

//MARK: -ChatItem

enum ChatSenderType{
    case fromMe
    case fromOthers
}
struct ChatItem {
    var text:String?
    var image:UIImage?
    var senderType: ChatSenderType
}


//MARK: - ChatView
class ChatView: UIScrollView {

    /*
    // Only override draw() if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func draw(_ rect: CGRect) {
        // Drawing code
    }
    */

    //Constants &variables
    //padding 對話匡間的距離
    private let padding: CGFloat = 20.0
    //記錄最後一個泡泡框的y值 泡泡長度紀錄 來判斷下一個對話泡泡的長度該到哪裡不會超過
    private var lastBubbleViewY: CGFloat = 0.0
    private(set) var allItems = [ChatItem]()

    func add(chatItem: ChatItem) {

        //Create and add bubble view
        let bubbleView = ChatBubbleView(item: chatItem, maxWidth: self.frame.width, offsetY: lastBubbleViewY + padding)
        self.addSubview(bubbleView)

        //Adjust variables
        lastBubbleViewY = bubbleView.frame.maxY
        contentSize = CGSize(width: self.frame.width, height: lastBubbleViewY)
        allItems.append(chatItem)

        //scroll to bottom  y: lastBubbleViewY - 1
        //lastBubbleViewY => scrollView的底部 -1 上面的部分 width: 1, height: 1 建一個矩陣
        let leftBottonRect = CGRect(x: 0, y: lastBubbleViewY - 1, width: 1, height: 1)
        //滾動scrollView 到指定位置
        scrollRectToVisible(leftBottonRect, animated: true)

    }


    //MARK: - ChatBubbleView
    //fileprivate 只有同一個.swift下的可以使用
    fileprivate class ChatBubbleView: UIView {

        // Constants
        let sidePaddingRate: CGFloat = 0.02
        //寬的比例
        let maxBubbleViewWidthRate: CGFloat = 0.6
        let contentMargin: CGFloat = 10.0
        let bubbleTailWidth: CGFloat = 10.0
        let textFontSize: CGFloat = 16.0


        //Constants from ChatView
        let item: ChatItem
        let maxWidth: CGFloat
        let offsetY: CGFloat


        //Variables for subviews.
        var imageView: UIImageView?
        var textLable: UILabel?
        var backgroundImageView: UIImageView?
        var currentY: CGFloat = 0.0


        //自動泡泡框的大小設定 maxWidth 螢幕寬度 , offsetY泡泡高度
        init(item: ChatItem, maxWidth: CGFloat, offsetY: CGFloat) {
            self.item = item
            self.maxWidth = maxWidth
            self.offsetY = offsetY
            super.init(frame: .zero)


        //Step.1: Decide a basic frame.
        self.frame = caculateBasicFrame()

        //Step.2: Caculate imageView's frame
        prepareImageView()

        //Step.3: Caculate textLabel's frame
        prepareTextLabel()

        //Step4.: Decide final size of bubble view.
        decideFinalSize()

        //Step5.: Display background of bubble.
        prepareBackgroundImageView()

        }
        //自己刻的元件要顯示用在storybord上時 需要用這行代碼
        required init?(coder aDecoder: NSCoder) {
            fatalError("init(coder:) has not been implemented")
        }
        //建立初始版型
        private func caculateBasicFrame() -> CGRect {
            let sidePadding = maxWidth * sidePaddingRate
            //隱形框的最大寬
            let maxBubbleViewWidth = maxWidth * maxBubbleViewWidthRate
            let offsetX:CGFloat
            if item.senderType == .fromMe {
                offsetX = maxWidth - maxBubbleViewWidth - sidePadding
            }else { //.fromOthers
                offsetX = sidePadding
            }
            //The result is just a assumptation.
            return CGRect(x: offsetX, y: offsetY, width: maxBubbleViewWidth, height: 10.0)
        }
        //建立圖片
        private func prepareImageView() {
            //Check if there is a image in this chat item.
            guard let image = item.image else {
                return
            }

            //Decide x and y.
            var x = contentMargin
            let y = contentMargin
            if item.senderType == .fromOthers {
                x += bubbleTailWidth
            }
            //Decide width and height.
            //min 回傳比較小值的那一個, 如果圖片大小沒有imageView那麼大
            //（self.frame.width - 2 *contentMargin - bubbleTailWidth）外框總寬-泡泡腳長-image到外框間距
            //image 可以有的最大寬
            let displayWidth = min(image.size.width, self.frame.width - 2 *
            contentMargin - bubbleTailWidth)
            //顯示的寬除圖片寬
            let displayRatio = displayWidth / image.size.width
            //顯示的高除圖片高
            let dispalyHeight = image.size.height * displayRatio

            //Decide final frame.
            //實際顯示的寬高
            let displayFrame = CGRect(x: x, y: y, width: displayWidth, height: dispalyHeight)

            //Create and add to bubble view
            let photoImageView = UIImageView(frame: displayFrame)
            self.imageView = photoImageView
            photoImageView.image = image

            //Make a rounded corner 做圓弧角
            photoImageView.layer.cornerRadius = 5.0
            //預設false將超出邊界的部分切除
            photoImageView.layer.masksToBounds = true
            self.addSubview(photoImageView)
            //imageView的最大Ｙ值  用來判斷之後文字要從哪邊開始顯示
            currentY = photoImageView.frame.maxY

        }

        private func prepareTextLabel() {

            //檢查是否有文字
            guard let text = item.text, !text.isEmpty else {
                return
            }

            //Decide x and y.
            var x = contentMargin
            //textFontSize/2 依文字大小調整文字框大小
            let y = currentY + textFontSize/2
            if item.senderType == .fromOthers {
                x += bubbleTailWidth
            }

            //Decide width and hieght
            let displayWidth = self.frame.width - 2 * contentMargin - bubbleTailWidth

            //Decide final frame of text label.
            let displayFrame = CGRect(x: x, y: y, width: displayWidth, height: textFontSize)

            //Create and add to bubble view.
            let label = UILabel(frame: displayFrame)
            self.textLable = label
            label.font = UIFont.systemFont(ofSize: textFontSize)
            label.numberOfLines = 0 //Important!!
            label.text = text
            label.sizeToFit() //Important!!

            self.addSubview(label)
            currentY = label.frame.maxY
        }


        //確定最後對話框的大小
        private func decideFinalSize() {
            let finalHieght: CGFloat = currentY + contentMargin
            var finalWidth: CGFloat = 0.0
            //Check width with imageView
            if let imageView = self.imageView{
                if item.senderType == .fromMe {
                    //因為maxX的算法 沒有加上泡泡尾巴所以這邊要加
                    finalWidth = imageView.frame.maxX + contentMargin + bubbleTailWidth
                }else { //From Others   的有包含尾巴 原因是xy的起點
                    finalWidth = imageView.frame.maxX + contentMargin
                }
            }
            //Check finalWidth with textLabel
            if let textLabel = self.textLable {
                var textWidth: CGFloat
                if item.senderType == .fromMe {
                    textWidth = textLabel.frame.maxX + contentMargin + bubbleTailWidth
                }else {//From others
                    textWidth = textLabel.frame.maxX + contentMargin
                }
                //拿imageView與文字框的寬取最大值 做為泡泡匡的依據回傳兩個的最大值
                finalWidth = max(finalWidth, textWidth)
            }
            //Final adjustment 最後的寬小於60% 調整對話匡往右移至邊框
            if item.senderType == .fromMe ,self.frame.width > finalWidth {
                self.frame.origin.x += self.frame.width - finalWidth
            }
            self.frame.size = CGSize(width: finalWidth, height: finalHieght)
        }


        private func prepareBackgroundImageView() {

            let image: UIImage?
            if item.senderType == .fromMe {
                let insets = UIEdgeInsets(top: 14, left: 14, bottom: 17, right: 28)
                //resizableImage 可延展的imageView 依照withCapInsets 所設的比例將四個角固定其他地方的複製接上來做延展
                image = UIImage(named: "fromMe.png")?.resizableImage(withCapInsets: insets)
            }else { // .fromOthers
                let insets = UIEdgeInsets(top: 14, left: 22, bottom: 17, right: 20)
                image = UIImage(named: "fromOthers.png")?.resizableImage(withCapInsets: insets)
            }
//            let frame = CGRect(x: 0, y: 0, width: self.frame.width, height: self.frame.height)

            let frame = self.bounds
            let imageView = UIImageView(frame: frame)
            self.backgroundImageView = imageView
            imageView.image = image
            self.addSubview(imageView)
            //將imageView拉到最底部 越晚加上subview 的view會被疊在上層所以
            self.sendSubviewToBack(imageView)
        }
    }
}
