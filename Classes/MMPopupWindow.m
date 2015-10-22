//
//  MMPopupWindow.m
//  MMPopupView
//
//  Created by Ralph Li on 9/6/15.
//  Copyright © 2015 LJC. All rights reserved.
//

#import "MMPopupWindow.h"
#import "MMPopupCategory.h"
#import "MMPopupDefine.h"
#import "MMPopupView.h"

@interface MMPopupWindow()

@property (nonatomic, assign) CGRect keyboardRect;

@end

@implementation MMPopupWindow

/**
 初始化的同时:
 1.设置window优先级
 2.添加键盘的位置尺寸即将发生改变的通知
 3.添加点击手势actionTap
 */
- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    
    if ( self )
    {
        self.windowLevel = UIWindowLevelStatusBar + 1;
        
        //注册UIKeyboardWillChangeFrameNotification
        /**
         *  键盘状态改变的时候,系统会发出一些特定的通知
         UIKeyboardWillShowNotification // 键盘即将显示
         UIKeyboardDidShowNotification // 键盘显示完毕
         UIKeyboardWillHideNotification // 键盘即将隐藏
         UIKeyboardDidHideNotification // 键盘隐藏完毕
         UIKeyboardWillChangeFrameNotification // 键盘的位置尺寸即将发生改变
         UIKeyboardDidChangeFrameNotification // 键盘的位置尺寸改变完毕
         
         系统发出键盘通知时,会附带一下跟键盘有关的额外信息(字典),字典常见的key如下:
         UIKeyboardFrameBeginUserInfoKey // 键盘刚开始的frame
         UIKeyboardFrameEndUserInfoKey // 键盘最终的frame(动画执行完毕后)
         UIKeyboardAnimationDurationUserInfoKey // 键盘动画的时间
         UIKeyboardAnimationCurveUserInfoKey // 键盘动画的执行节奏(快慢)
         */
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(notifyKeyboardChangeFrame:) name:UIKeyboardWillChangeFrameNotification object:nil];
        
        UITapGestureRecognizer *gesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(actionTap:)];
        [self addGestureRecognizer:gesture];
    }
    return self;
}

/**
 *  单例模式
 *
 */
+ (MMPopupWindow *)sharedWindow
{
    static MMPopupWindow *window;
    static dispatch_once_t onceToken;
    
    dispatch_once(&onceToken, ^{
        
        window = [[MMPopupWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
        
    });
    
    return window;
}

- (void)cacheWindow
{
    [self makeKeyAndVisible];//通过makeKeyAndVisible让它变成keyWindow并显示出来
    [[[UIApplication sharedApplication].delegate window] makeKeyWindow];//变成keyWindow,keyWindow是指定的用来接收键盘以及非触摸类的消息，而且程序中每一个时刻只能有一个window是keyWindow
    
    self.mm_dimBackgroundView.hidden = YES;//设置背景View
    self.hidden = YES;
}

- (void)actionTap:(UITapGestureRecognizer*)gesture
{
    if ( self.touchWildToHide && !self.mm_dimBackgroundAnimating )
    {
        for ( UIView *v in self.mm_dimBackgroundView.subviews )
        {
            if ( [v isKindOfClass:[MMPopupView class]] )
            {
                MMPopupView *popupView = (MMPopupView*)v;
                [popupView hide];
            }
        }
    }
}

- (void)notifyKeyboardChangeFrame:(NSNotification *)n
{
    NSValue *keyboardBoundsValue = [[n userInfo] objectForKey:UIKeyboardFrameEndUserInfoKey];
    self.keyboardRect = [keyboardBoundsValue CGRectValue];
}

@end
