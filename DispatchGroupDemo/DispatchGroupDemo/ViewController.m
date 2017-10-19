//
//  ViewController.m
//  DispatchGroupDemo
//
//  Created by HK on 16/9/24.
//  Copyright © 2016年 hkhust. All rights reserved.
//

#import "ViewController.h"
#import <SDWebImageManager.h>

@interface ViewController ()

@property (weak, nonatomic) IBOutlet UIImageView *combinedImage;
@property (strong, nonatomic) NSMutableArray *images;
@property (strong, nonatomic) UIActivityIndicatorView *loading;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self initDatas];
    [self initViews];
//    [self requestImages1];
    [self requestImages2];
}

#pragma mark - Init
- (void)initDatas {
    self.images = @[].mutableCopy;
}

- (void)initViews {
    self.loading = [[UIActivityIndicatorView alloc] initWithFrame:self.view.frame];
    self.loading.activityIndicatorViewStyle = UIActivityIndicatorViewStyleGray;
    [self.view addSubview:self.loading];
}

#pragma mark - loading
- (void)showLoading {
    [self.loading startAnimating];
}

- (void)hideLoading {
    [self.loading stopAnimating];
}

#pragma mark - Request
- (void)requestImages2 {
    [self showLoading];
    dispatch_group_t group = dispatch_group_create();
    // group one
    dispatch_group_enter(group);
    dispatch_async(dispatch_get_global_queue(0, 0), ^{
        NSLog(@"group one start===%@",[NSThread currentThread]);
        [[SDWebImageManager sharedManager] loadImageWithURL:[NSURL URLWithString:@"http://img05.tooopen.com/images/20150202/sy_80219211654.jpg"] options:SDWebImageAllowInvalidSSLCertificates progress:^(NSInteger receivedSize, NSInteger expectedSize, NSURL * _Nullable targetURL) {
            
        } completed:^(UIImage * _Nullable image, NSData * _Nullable data, NSError * _Nullable error, SDImageCacheType cacheType, BOOL finished, NSURL * _Nullable imageURL) {
            if (image) {
                [self.images addObject:image];
            }
            NSLog(@"group one finish===%@",[NSThread currentThread]);
            dispatch_group_leave(group);

        }];
    });
    
    // group two
    dispatch_group_enter(group);
    dispatch_async(dispatch_get_global_queue(0, 0), ^{
        NSLog(@"group two start===%@",[NSThread currentThread]);
        [[SDWebImageManager sharedManager] loadImageWithURL:[NSURL URLWithString:@"http://img04.tooopen.com/images/20130701/tooopen_10055061.jpg"] options:SDWebImageAllowInvalidSSLCertificates progress:^(NSInteger receivedSize, NSInteger expectedSize, NSURL * _Nullable targetURL) {
            
        } completed:^(UIImage * _Nullable image, NSData * _Nullable data, NSError * _Nullable error, SDImageCacheType cacheType, BOOL finished, NSURL * _Nullable imageURL) {
            if (image) {
                [self.images addObject:image];
            }
            NSLog(@"group two finish===%@",[NSThread currentThread]);
            dispatch_group_leave(group);
            
        }];
    });
    
    // group notify
    dispatch_group_notify(group, dispatch_get_global_queue(0, 0), ^{
        NSLog(@"group finished===%@",[NSThread currentThread]);
        if (self.images.count >= 2) {
            UIImage *image1 = self.images[0];
            UIImage *image2 = self.images[1];
            UIImage *combineImage = [self combineWithTopImage:image1 bottomImage:image2];
            dispatch_async(dispatch_get_main_queue(), ^{
                self.combinedImage.image = combineImage;
                [self hideLoading];
            });
        }
    });
    
}
- (void)requestImages1 {
    
    [self showLoading];
    dispatch_group_t group = dispatch_group_create();
    // group one
    dispatch_group_enter(group);
    dispatch_async(dispatch_get_global_queue(0, 0), ^{
        NSLog(@"group one start===%@",[NSThread currentThread]);
        NSURLSessionTask *task1 = [[NSURLSession sharedSession] dataTaskWithURL:[NSURL URLWithString:@"http://img05.tooopen.com/images/20150202/sy_80219211654.jpg"] completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
            UIImage *image = [UIImage imageWithData:data];
            if (image) {
                [self.images addObject:image];
            }
            NSLog(@"group one finish===%@",[NSThread currentThread]);
            dispatch_group_leave(group);
        }];
        [task1 resume];
    });
    
    // group two
    dispatch_group_enter(group);
    dispatch_async(dispatch_get_global_queue(0, 0), ^{
        NSLog(@"group two start===%@",[NSThread currentThread]);
        NSURLSessionTask *task2 = [[NSURLSession sharedSession] dataTaskWithURL:[NSURL URLWithString:@"http://img04.tooopen.com/images/20130701/tooopen_10055061.jpg"] completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
            UIImage *image = [UIImage imageWithData:data];
            if (image) {
                [self.images addObject:image];
            }
            NSLog(@"group two finish===%@",[NSThread currentThread]);
            dispatch_group_leave(group);
        }];
        [task2 resume];
    });
    
    // group notify
    dispatch_group_notify(group, dispatch_get_global_queue(0, 0), ^{
        NSLog(@"group finished===%@",[NSThread currentThread]);
        if (self.images.count >= 2) {
            UIImage *image1 = self.images[0];
            UIImage *image2 = self.images[1];
            UIImage *combineImage = [self combineWithTopImage:image1 bottomImage:image2];
            dispatch_async(dispatch_get_main_queue(), ^{
                self.combinedImage.image = combineImage;
                [self hideLoading];
            });
        }
    });
}

#pragma mark - Combine Images
- (UIImage *)combineWithTopImage:(UIImage *)topImage bottomImage:(UIImage *)bottomImage {
    CGFloat width = topImage.size.width ;
    CGFloat height = topImage.size.height * 2;
    CGSize offScreenSize = CGSizeMake(width, height);
    
    UIGraphicsBeginImageContext(offScreenSize);
    
    CGRect rect = CGRectMake(0, 0, width, height / 2);
    [topImage drawInRect:rect];
    rect.origin.y += height / 2;
    [bottomImage drawInRect:rect];
    
    UIImage* imagez = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return imagez;
}

@end
