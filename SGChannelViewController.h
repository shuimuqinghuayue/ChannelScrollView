//
//  SGChannelViewController.h
//  sogousearch
//
//  Created by 悦 on 2017/10/19.
//  Copyright © 2017年 搜狗. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SGChannelViewControllerProtocol.h"
@interface SGChannelViewController : UIViewController<SGChannelViewControllerProtocol>
@property (nonatomic,copy)NSString * reuseIdentifier;
- (instancetype)initWithReuseIdentifier:(NSString *)reuseIdentifier;
@end
