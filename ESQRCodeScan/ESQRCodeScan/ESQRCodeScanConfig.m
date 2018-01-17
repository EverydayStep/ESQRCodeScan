//
//  ESQRCodeScanConfig.m
//  ESQRCodeScan
//
//  Created by codeLocker on 2018/1/17.
//  Copyright © 2018年 codeLocker. All rights reserved.
//

#import "ESQRCodeScanConfig.h"

@implementation ESQRCodeScanConfig
- (id)init {
    self = [super init];
    if (self) {
        self.scanRegion = CGRectMake(0, 0, 100, 100);
        self.cornerWidth = 3.0f;
        self.cornerColor = [UIColor blackColor];
        self.scanLineHeight = 40.0f;
        self.scanLineColor = [UIColor blackColor];
        self.scanDuration = 3.0f;
    }
    return self;
}
@end
