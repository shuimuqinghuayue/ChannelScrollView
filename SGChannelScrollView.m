//
//  SGChannelScrollView.m
//  sogousearch
//
//  Created by 悦 on 2017/10/16.
//  Copyright © 2017年 搜狗. All rights reserved.
//

#import "SGChannelScrollView.h"

@interface SGChannelLoopItemView : UIView
@property (nonatomic,strong)SGChannelViewController * viewController;
@property (nonatomic,assign)NSInteger index;
-(void)removeViewController;
@end;

@implementation SGChannelLoopItemView

-(instancetype)initWithFrame:(CGRect)frame viewController:(SGChannelViewController*)viewController{
    self = [super initWithFrame:frame];
    if(self){
        _index = -1;
        _viewController = viewController;
        viewController.view.frame = self.bounds;
        [self addSubview:viewController.view];
    }
    return self;
}

-(void)removeViewController{
    [self removeAllSubviews];
    self.viewController = nil;
    self.index = -1;
}

-(void)dealloc{
    
}

@end;

@interface SGChannelScrollView ()<UIScrollViewDelegate,UIGestureRecognizerDelegate>
@property (nonatomic,strong)UIScrollView * scrollView;
@property (nonatomic,strong)NSMutableArray * visibles;
@property (nonatomic,strong)NSMutableDictionary * reuseables;
@property (nonatomic,assign)NSInteger count;
@property (nonatomic,assign)NSInteger currentIndex;
@end

@implementation SGChannelScrollView
static const NSInteger maxLoopCount = 3;
-(instancetype)initWithFrame:(CGRect)frame{
    self = [super initWithFrame:frame];
    if(self){
        self.currentIndex = -1;
        self.reuseables = [[NSMutableDictionary alloc] initWithCapacity:10];
        self.visibles = [NSMutableArray arrayWithCapacity:10];
        [self setupUI];
    }
    return self;
}

-(void)setupUI{
    UIScrollView * scrollView = [[UIScrollView alloc]initWithFrame:CGRectMake(0, 0, self.frame.size.width, self.frame.size.height)];
    scrollView.userInteractionEnabled = YES;
    scrollView.showsHorizontalScrollIndicator = NO;
    scrollView.showsVerticalScrollIndicator = NO;
    scrollView.bounces = NO;
    scrollView.pagingEnabled = YES;
    scrollView.autoresizesSubviews = YES;
    scrollView.contentSize = CGSizeZero;
    scrollView.delegate = self;
    [self addSubview:scrollView];
    self.scrollView = scrollView;
}

- (void)reloadData{
    [self.scrollView removeAllSubviews];
    [self.reuseables removeAllObjects];
    [self.visibles removeAllObjects];
    self.scrollView.contentSize = CGSizeMake(self.scrollView.width * self.count, self.scrollView.height);
    [self selectToIndex:0];
}

- (void)selectToIndex:(NSInteger)index{
    [self scrollToIndex:index];
    [self.scrollView setContentOffset:CGPointMake(index * self.scrollView.frame.size.width, 0) animated:NO];
}

- (void)scrollToIndex:(NSInteger)index{
    NSMutableArray * indexs = [NSMutableArray array];
    if((index - 1) >= 0){
        [indexs addObject:@(index - 1)];
    }
    if ((index + 1) <= (self.count - 1)){
        [indexs addObject:@(index + 1)];
    }
    if(index >= 0 && index <= self.count - 1){
        [indexs addObject:@(index)];
    }
    if(indexs.count == 0) {
        return;
    }
    NSMutableArray * removePages = [NSMutableArray array];
    //1、找到移除屏幕的view
    for(SGChannelLoopItemView * view in self.visibles){
        if(![indexs containsObject:@(view.index)]){
            //需要移除的view
            [removePages addObject:view];
        } else {
            //删除不需要重新设置frame的view
            [indexs removeObject:@(view.index)];
        }
    }
    //2、需要移除的view
    for(SGChannelLoopItemView * view in removePages){
        //1）、viewController添加复用队列
        [self addToReuseablesWithLoopItemView:view];
        //2）、移除view
        [self.visibles removeObject:view];
        [view removeViewController];
        [view removeFromSuperview];
    }
    
    SGChannelViewController * currentViewController = nil;
    //3、复用或创建
    for(NSNumber * index in indexs){
        SGChannelViewController * viewController = [self.dataSource scrollView:self controllerAtIndex:[index integerValue]];
        SGChannelLoopItemView * view = [[SGChannelLoopItemView alloc] initWithFrame:CGRectMake([index integerValue] * self.scrollView.frame.size.width, 0, self.scrollView.frame.size.width, self.scrollView.frame.size.height) viewController:viewController];
        view.index = [index integerValue];
        [self.scrollView addSubview:view];
        [self.visibles addObject:view];
        if(self.currentIndex == [index integerValue]){
            currentViewController = viewController;
        }
    }
    if(self.delegate&&[self.delegate respondsToSelector:@selector(scrollView:didEndDisplayingViewController:index:)]){
        [self.delegate scrollView:self didEndDisplayingViewController:currentViewController index:index];
    }
}

-(void)addToReuseablesWithLoopItemView:(SGChannelLoopItemView*)view{
    NSString * reuseIdentifier = view.viewController.reuseIdentifier;
    if(![self.reuseables.allKeys containsObject:reuseIdentifier]){
        self.reuseables[reuseIdentifier] = @[view.viewController];
    } else {
        NSMutableArray * viewControllers = [NSMutableArray arrayWithArray:self.reuseables[reuseIdentifier]];
        if([viewControllers containsObject:view.viewController]){
            return;
        }
        if(viewControllers.count > maxLoopCount){
            [viewControllers removeObjectAtIndex:0];
            [viewControllers addObject:view.viewController];
        } else {
            [viewControllers addObject:view.viewController];
        }
        self.reuseables[reuseIdentifier] = viewControllers;
    }
}

- (SGChannelViewController*)dequeueReusableViewControllerWithIdentifier:(NSString *)identifier{
    SGChannelViewController * viewController = nil;
    if([self.reuseables.allKeys containsObject:identifier]){
        NSMutableArray * viewControllers = self.reuseables[identifier];
        NSMutableArray * tempViewControllers = [NSMutableArray arrayWithArray:viewControllers];
        viewController = viewControllers[0];
        [tempViewControllers removeObjectAtIndex:0];
        if(tempViewControllers.count == 0){
            self.reuseables[identifier] = nil;
        } else {
            self.reuseables[identifier] = tempViewControllers;
        }
    }
    return viewController;
}

-(NSInteger)count{
    if(self.dataSource&&[self.dataSource respondsToSelector:@selector(numberOfControllers)]){
        _count = [self.dataSource numberOfControllers];
    }
    return _count;
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView{
    CGPoint offset = scrollView.contentOffset;
    NSInteger index = roundf(offset.x / scrollView.frame.size.width);
    if(self.currentIndex == index){
        return;
    }
    self.currentIndex = index;
    self.userInteractionEnabled = NO;
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.25 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [self scrollToIndex:index];
        self.userInteractionEnabled = YES;
    });
}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView{

    CGPoint offset = scrollView.contentOffset;
    NSInteger index = roundf(offset.x / scrollView.frame.size.width);
    [self scrollToIndex:index];
 
    if(self.delegate&&[self.delegate respondsToSelector:@selector(scrollView:didEndDeceleratingViewController:index:)]){
        for(SGChannelLoopItemView * view in self.visibles) {
            if(view.index == self.currentIndex){
                [self.delegate scrollView:self didEndDeceleratingViewController:view.viewController index:self.currentIndex];
            }
        }
    }
}

@end
