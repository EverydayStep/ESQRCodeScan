//
//  ESQRCodeScanView.h
//  ESQRCodeScan
//
//  Created by codeLocker on 2018/1/17.
//  Copyright © 2018年 codeLocker. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ESQRCodeScanConfig.h"

@class ESQRCodeScanView;
@protocol ESQRCodeScanViewDelegate <NSObject>
- (void)qrCodeScanView:(ESQRCodeScanView *)qrCodeScanView didScan:(NSString *)result;
@end

@interface ESQRCodeScanView : UIView
@property (nonatomic, weak) id<ESQRCodeScanViewDelegate> delegate;
- (id)initWithFrame:(CGRect)frame config:(ESQRCodeScanConfig *)config;
- (void)startScan;
@end
