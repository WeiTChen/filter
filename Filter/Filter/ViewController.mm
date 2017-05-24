//
//  ViewController.m
//  Filter
//
//  Created by william on 2017/5/17.
//  Copyright © 2017年 智齿. All rights reserved.
//

#import "ViewController.h"
#import "CubeMap.c"

@interface ViewController ()

//outputImage
@property (nonatomic,strong) UIImageView *outputImg;
//outputImage
@property (nonatomic,strong) UIImageView *inputImg;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.view.backgroundColor = [UIColor orangeColor];
    
    UILabel *oldLabel = [[UILabel alloc]initWithFrame:CGRectMake(0, 25, 160, 15)];
    oldLabel.text = @"原图";
    oldLabel.textAlignment = NSTextAlignmentCenter;
    [self.view addSubview:oldLabel];
    oldLabel.center = CGPointMake(self.view.center.x, oldLabel.center.y);
    
    UIImageView *oldImageView = [[UIImageView alloc]initWithFrame:CGRectMake(0, 50, 130, 130)];
    oldImageView.image =[UIImage imageNamed:@"1.png"];
    [self.view addSubview:oldImageView];
    self.inputImg = oldImageView;
    oldImageView.center = CGPointMake(self.view.center.x, oldImageView.center.y);
    
    
    UILabel *newLabel = [[UILabel alloc]initWithFrame:CGRectMake(0, 200, 320, 15)];
    newLabel.text = @"效果图";
    newLabel.textAlignment = NSTextAlignmentCenter;
    [self.view addSubview:newLabel];
    newLabel.center = CGPointMake(self.view.center.x, newLabel.center.y);
    
    CGFloat size = self.view.frame.size.width-20;
    UIImageView *newImageView = [[UIImageView alloc]initWithFrame:CGRectMake(10, 220, size, size)];
    [self.view addSubview:newImageView];
    self.outputImg = newImageView;
    
    
    UISlider *slider = [[UISlider alloc] initWithFrame:CGRectMake(30,CGRectGetMaxY(newImageView.frame)+30, size-40, 20)];
    [self.view addSubview:slider];
    slider.minimumValue = 0;
    slider.maximumValue = 255;
    [slider addTarget:self action:@selector(filter:) forControlEvents:UIControlEventValueChanged];
    
    [self drawImage:255/2];
}

- (void)filter:(UISlider *)slider{
    NSTimeInterval start = CFAbsoluteTimeGetCurrent();
    [self drawImage:slider.value];
    NSTimeInterval end = CFAbsoluteTimeGetCurrent();
    NSLog(@"time = %f,value = %f",end-start,slider.value);
}

- (void)drawImage:(double)filterValue
{
    UIImage *image = [UIImage imageNamed:@"1.png"];
    // 分配内存
    const int imageWidth = image.size.width;
    const int imageHeight = image.size.height;
    size_t      bytesPerRow = imageWidth * 4;
    uint32_t* rgbImageBuf = (uint32_t*)malloc(bytesPerRow * imageHeight);
    
    // 创建context
    CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
    CGContextRef context = CGBitmapContextCreate(rgbImageBuf, imageWidth, imageHeight, 8, bytesPerRow, colorSpace,kCGBitmapByteOrder32Little | kCGImageAlphaNoneSkipLast);
    CGContextDrawImage(context, CGRectMake(0, 0, imageWidth, imageHeight), image.CGImage);
    // 遍历像素
    int pixelNum = imageWidth * imageHeight;
    uint32_t* pCurPtr = rgbImageBuf;
    
    for (int i = 0; i < pixelNum; i++, pCurPtr++)
    {
//      ABGR
        uint8_t* ptr = (uint8_t*)pCurPtr;
        int B = ptr[1];
        int G = ptr[2];
        int R = ptr[3];
        double Gray = R*0.3+G*0.59+B*0.11;
        if (Gray > filterValue || (Gray == filterValue && filterValue == 0)) {
            ptr[0] = 0;
        }else{
//            ptr[3] = 0xff;
        }
    }
    // 将内存转成image
    CGDataProviderRef dataProvider = CGDataProviderCreateWithData(NULL, rgbImageBuf, bytesPerRow * imageHeight,NULL);
    CGImageRef imageRef = CGImageCreate(imageWidth, imageHeight, 8, 32, bytesPerRow, colorSpace,kCGImageAlphaLast | kCGBitmapByteOrder32Little, dataProvider,NULL, true, kCGRenderingIntentDefault);
    
    CGDataProviderRelease(dataProvider);
    
    UIImage* resultUIImage = [UIImage imageWithCGImage:imageRef scale:image.scale orientation:image.imageOrientation];
    // 释放
    CGImageRelease(imageRef);
    CGContextRelease(context);
    CGColorSpaceRelease(colorSpace);
    self.outputImg.image = resultUIImage;
}

//去色
-(UIImage *)grayImage:(UIImage *)sourceImage
{
    int bitmapInfo =kCGImageAlphaNone;
    int width = sourceImage.size.width;
    int height = sourceImage.size.height;
    CGColorSpaceRef colorSpace =CGColorSpaceCreateDeviceGray();
    CGContextRef context =CGBitmapContextCreate (nil,
                                                 width,
                                                 height,
                                                 8,     // bits per component
                                                 0,
                                                 colorSpace,
                                                 bitmapInfo);
    CGColorSpaceRelease(colorSpace);
    if (context ==NULL) {
        return nil;
    }
    CGContextDrawImage(context,
                       CGRectMake(0,0, width, height), sourceImage.CGImage);
    UIImage *grayImage = [UIImage imageWithCGImage:CGBitmapContextCreateImage(context)];
    CGContextRelease(context);
    return grayImage;
}


@end
