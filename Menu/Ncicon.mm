//
//  Ncicon.m
//  ENGINE
//
//  Created by 烟雨 on 2024/4/1.
//  有尝解决Xcode疑难杂症问题   QQ 151384204
//  Copyright © 2024 烟雨. All yan yu.
//
#import "UIColor+Hex.h"
#import "菜单.h"
#import "Ncicon.h"
#import "cex.h"
#import "mahoa.h"
#define NcKuan  [UIScreen mainScreen].bounds.size.width
#define NcGao [UIScreen mainScreen].bounds.size.height
static UIButton *按钮;
static UIButton *btn;
static NSTimer *防屏蔽;
@implementation Ncicon

Ncicon*A;
//extern void alogo()
//{
//}
static void __attribute__((constructor)) initialize(void)
//extern void alogo()
{
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        //  Created by Telegram @CheatBot_Owner
        // [[self share] show];

            NSString *CFBundleIdentifier = [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleExecutable"];
            if ([CFBundleIdentifier isEqualToString:@"ShadowTrackerExtra"]) {
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(10 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{

        A=[Ncicon new];
        [A logoview];


            
            
        });
    }




    });



}
UIButton*btnlogo;
-(void)logoview{
    btnlogo = [UIButton buttonWithType:UIButtonTypeSystem];
    btnlogo.frame = CGRectMake(30, 57, 40, 40);
 
    UITapGestureRecognizer *tapGestureRecognizer = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(onConsoleButtonTapped)];
    [btnlogo addGestureRecognizer:tapGestureRecognizer];
    UIWindow *mainWindow = [UIApplication sharedApplication].keyWindow;
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] init];
    tap.numberOfTapsRequired = 2;//点击次数
    tap.numberOfTouchesRequired = 3;//手指数
    [tap addTarget:self action:@selector(tapIconView)];
    [mainWindow addGestureRecognizer:tap];
    
    btnlogo.hidden =NO;
    NSData *imageData = [[NSData alloc] initWithBase64EncodedString:xztime options:NSDataBase64DecodingIgnoreUnknownCharacters];
    UIImage *decodedImage = [UIImage imageWithData:imageData];
    dispatch_async(dispatch_get_main_queue(), ^{
        btnlogo.layer.contents = (id)decodedImage.CGImage;
    });
    [btnlogo addTarget:self action:@selector(buttonDragged:withEvent:)forControlEvents:UIControlEventTouchDragInside];
    [[UIApplication sharedApplication].keyWindow addSubview:btnlogo];


}
- (void)buttonDragged:(UIButton *)button withEvent:(UIEvent *)event{
       UITouch *touch = [[event touchesForView:button] anyObject];

       CGPoint previousLocation = [touch previousLocationInView:button];
       CGPoint location = [touch locationInView:button];
       CGFloat delta_x = location.x - previousLocation.x;
       CGFloat delta_y = location.y - previousLocation.y;

       button.center = CGPointMake(button.center.x + delta_x, button.center.y + delta_y);
}

-(void)tapIconView
{
btnlogo.hidden = !btnlogo.hidden;


}
+ (void)Mem{
    UIWindow *mainWindow = [UIApplication sharedApplication].keyWindow;
    
    UIButton *按钮 = [[UIButton alloc] initWithFrame:CGRectMake((mainWindow.frame.size.width - 40) / 2, 37, 40, 40)];
    [按钮 setTitle:@"" forState:UIControlStateNormal];
    [按钮 setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    按钮.backgroundColor = [UIColor clearColor];
    [按钮.titleLabel setFont:[UIFont systemFontOfSize:16]];
    按钮.layer.cornerRadius = 按钮.frame.size.width/2;
    按钮.clipsToBounds = YES;
    [按钮 addTarget:self action:@selector(buttonDragged:withEvent:)forControlEvents:UIControlEventTouchDragInside];
    [按钮 addTarget:self action:@selector(onConsoleButtonTapped) forControlEvents:UIControlEventTouchUpInside];
    dispatch_async(dispatch_get_global_queue(0, 0), ^{
        
        NSData *imageData = [[NSData alloc] initWithBase64EncodedString:xztime options:NSDataBase64DecodingIgnoreUnknownCharacters];
        UIImage *decodedImage = [UIImage imageWithData:imageData];
        dispatch_async(dispatch_get_main_queue(), ^{
            按钮.layer.contents = (id)decodedImage.CGImage;
        });
    });
    [mainWindow addSubview:按钮];
    UIPanGestureRecognizer *pan=[[UIPanGestureRecognizer alloc]initWithTarget:self action:@selector(TuoDong:)];
    [按钮 addGestureRecognizer:pan];
    
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] init];
    tap.numberOfTapsRequired = 2;//点击次数
    tap.numberOfTouchesRequired = 3;//手指数
    [mainWindow addGestureRecognizer:tap];
    [tap addTarget:self action:@selector(tapIconView)];
    
    防屏蔽 = [NSTimer scheduledTimerWithTimeInterval:0.2 repeats:YES block:^(NSTimer*t){
        if(!按钮.hidden) {
            [按钮.superview bringSubviewToFront:按钮];
            UIWindow *mainWindow = [UIApplication sharedApplication].keyWindow;
            if(按钮.superview != mainWindow) [mainWindow addSubview:按钮];
        }
    }];
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(60 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [防屏蔽 invalidate];
    });
    
}
+(void)buttonDragged:(UIButton *)button withEvent:(UIEvent *)event{
       UITouch *touch = [[event touchesForView:button] anyObject];

       CGPoint previousLocation = [touch previousLocationInView:button];
       CGPoint location = [touch locationInView:button];
       CGFloat delta_x = location.x - previousLocation.x;
       CGFloat delta_y = location.y - previousLocation.y;

       button.center = CGPointMake(button.center.x + delta_x, button.center.y + delta_y);
}
+ (void)tapIconView
{
    按钮.hidden = !按钮.hidden;
}

+ (void)TuoDong:(UIPanGestureRecognizer *)recognizer{
    CGPoint translation = [recognizer translationInView:按钮];
    if(recognizer.state == UIGestureRecognizerStateBegan){
    }else if(recognizer.state == UIGestureRecognizerStateChanged){
        按钮.center = CGPointMake(按钮.center.x + translation.x, 按钮.center.y + translation.y);
        [recognizer setTranslation:CGPointZero inView:按钮];
    }else if(recognizer.state == UIGestureRecognizerStateEnded){
        CGFloat newX=按钮.center.x;
        CGFloat newY=按钮.center.y;
        按钮.center = CGPointMake(newX, newY);
        [recognizer setTranslation:CGPointZero inView:按钮];
    }
}

-(void)onConsoleButtonTapped{
        [Nctabmenu NcMenuFun];
}



@end
