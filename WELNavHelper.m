//
//  WELNavHelper.m
//  WELNavBarHelper
//
//  Created by WELCommand on 15/7/9.
//  Copyright (c) 2015年 WELCommand. All rights reserved.
//

#import "WELNavHelper.h"
#import <objc/runtime.h>

@implementation UIViewController (WELNavBarHook)

-(void)setW_navBarHidden:(BOOL)w_navBarHidden {
    objc_setAssociatedObject(self, @selector(w_navBarHidden), @(w_navBarHidden), OBJC_ASSOCIATION_COPY);
}

-(BOOL)w_navBarHidden {
    return [objc_getAssociatedObject(self, @selector(w_navBarHidden)) boolValue];
}

-(void)WEL_navHelper_viewWillAppear:(BOOL)animated {
    [self WEL_navHelper_viewWillAppear:animated];
    if(self.navigationController) {
        [self.navigationController setNavigationBarHidden:self.w_navBarHidden animated:YES];
    }
}

@end

@implementation UIScreenEdgePanGestureRecognizer (WELNavPanBackHook)

-(void)setTouch_off:(CGFloat)touch_off {
    objc_setAssociatedObject(self, @selector(touch_off), @(touch_off), OBJC_ASSOCIATION_COPY);
}

-(CGFloat)touch_off {
    return [objc_getAssociatedObject(self, @selector(touch_off)) floatValue];
}

-(void)WEL_beganTouchOffset:(UITouch *)touch {
    CGPoint point = [[touch valueForKey:@"_locationInWindow"] CGPointValue];
    self.touch_off = point.x;
}

-(void)WEL_moveTouchOffset:(UITouch *)touch {
    CGPoint offPoint = [[touch valueForKey:@"_locationInWindow"] CGPointValue];
    offPoint.x -= self.touch_off;
    [touch setValue:[NSValue valueWithCGPoint:offPoint] forKey:@"_locationInWindow"];
}

-(void)full_touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event {
    UITouch *touch = [touches anyObject];
    [self WEL_moveTouchOffset:touch];
    
    [self full_touchesMoved:touches withEvent:event];
}

-(void)full_touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    UITouch *touch = [touches anyObject];
    [self WEL_beganTouchOffset:touch];
    [self WEL_moveTouchOffset:touch];
    
    [self full_touchesBegan:touches withEvent:event];
}

@end

@implementation WELNavHelper

+(void)load {
    [super load];
    
    [self exchangeImpWithClass:[UIViewController class] method1:@"viewWillAppear:" method2:@"WEL_navHelper_viewWillAppear:"];
    
    [self exchangeImpWithClass:[UIScreenEdgePanGestureRecognizer class] method1:@"full_touchesBegan:withEvent:" method2:@"touchesBegan:withEvent:"];
    
    [self exchangeImpWithClass:[UIScreenEdgePanGestureRecognizer class] method1:@"full_touchesMoved:withEvent:" method2:@"touchesMoved:withEvent:"];
    
    Method m1 = class_getInstanceMethod([self class], @selector(nav_g_delegate_hook_g:t:));
    Method m2 = class_getInstanceMethod(NSClassFromString(@"_UINavigationInteractiveTransition"), NSSelectorFromString(@"gestureRecognizer:shouldReceiveTouch:"));
    method_exchangeImplementations(m1, m2);
}

+(void)exchangeImpWithClass:(Class)class method1:(NSString *)method1 method2:(NSString *)method2 {
    Method m1 = class_getInstanceMethod(class,NSSelectorFromString(method1));
    Method m2 = class_getInstanceMethod(class, NSSelectorFromString(method2));
    method_exchangeImplementations(m1,m2);
}

-(BOOL)nav_g_delegate_hook_g:(id)g t:(id)t {
    return YES;
}


@end
