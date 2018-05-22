//
//  SGChannelViewController.m
//  sogousearch
//
//  Created by 悦 on 2017/10/19.
//  Copyright © 2017年 搜狗. All rights reserved.
//

#import "SGChannelViewController.h"

@interface SGChannelViewController ()

@end

@implementation SGChannelViewController

-(instancetype)initWithReuseIdentifier:(NSString *)reuseIdentifier{
    self = [super init];
    if(self){
        _reuseIdentifier = reuseIdentifier;
        self.view.backgroundColor = [UIColor whiteColor];
    }
    return self;
}

-(void)loadNewDataWithChannel:(NSDictionary *)channel{
    
}

-(void)loadCacheDataWithChannel:(NSDictionary *)channel{
    
}

-(void)resetData{
    
}

@end
