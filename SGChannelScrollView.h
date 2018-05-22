//
//  SGChannelScrollView.h
//  sogousearch
//
//  Created by 悦 on 2017/10/16.
//  Copyright © 2017年 搜狗. All rights reserved.
//

#import <UIKit/UIKit.h>
#import"SGChannelViewController.h"
@class SGChannelScrollView;
@protocol SGChannelScrollViewDataSource <NSObject>
@required
- (__kindof SGChannelViewController*)scrollView:(SGChannelScrollView*)scrollView controllerAtIndex:(NSInteger)index;
- (NSInteger)numberOfControllers;
@end

@protocol SGChannelScrollViewDelegate <NSObject>
@optional
- (void)scrollView:(SGChannelScrollView *)scrollView willDisplayViewController:(__kindof SGChannelViewController *)viewController index:(NSInteger)index;
- (void)scrollView:(SGChannelScrollView *)scrollView didEndDisplayingViewController:(__kindof SGChannelViewController *)viewController index:(NSInteger)index;
- (void)scrollView:(SGChannelScrollView *)scrollView didEndDeceleratingViewController:(__kindof SGChannelViewController *)viewController index:(NSInteger)index;
@end

@interface SGChannelScrollView : UIView
@property (nonatomic,weak)id<SGChannelScrollViewDataSource>dataSource;
@property (nonatomic,weak)id<SGChannelScrollViewDelegate>delegate;
- (SGChannelViewController*)dequeueReusableViewControllerWithIdentifier:(NSString *)identifier;
- (void)selectToIndex:(NSInteger)index;
- (void)reloadData;
@end
