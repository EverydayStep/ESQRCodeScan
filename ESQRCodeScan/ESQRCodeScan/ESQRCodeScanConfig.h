//
//  ESQRCodeScanConfig.h
//  ESQRCodeScan
//
//  Created by codeLocker on 2018/1/17.
//  Copyright © 2018年 codeLocker. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@interface ESQRCodeScanConfig : NSObject
/** 扫描区域 */
@property (nonatomic, assign) CGRect scanRegion;
/** 扫描区域拐角线条宽度 */
@property (nonatomic, assign) CGFloat cornerWidth;
/** 扫描区域拐角线条颜色 */
@property (nonatomic, strong) UIColor *cornerColor;
/** 扫描线的高度 */
@property (nonatomic, assign) CGFloat scanLineHeight;
/** 扫描线的颜色 */
@property (nonatomic, strong) UIColor *scanLineColor;
/** 扫描的时长 */
@property (nonatomic, assign) CGFloat scanDuration;
@end
