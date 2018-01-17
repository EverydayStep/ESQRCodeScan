//
//  ViewController.m
//  ESQRCodeScan
//
//  Created by codeLocker on 2018/1/17.
//  Copyright © 2018年 codeLocker. All rights reserved.
//

#import "ViewController.h"
#import "ESQRCodeScanView.h"
@interface ViewController ()<ESQRCodeScanViewDelegate>
@property (nonatomic, strong) ESQRCodeScanView *qrCodeScanView;
@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor blackColor];
    ESQRCodeScanConfig *config = [[ESQRCodeScanConfig alloc] init];
    CGSize scanSize = CGSizeMake(self.view.frame.size.width * 3/4, self.view.frame.size.width * 3/4);
    config.scanRegion = CGRectMake((self.view.frame.size.width - scanSize.width)/2, (self.view.frame.size.height - scanSize.height)/2, scanSize.width, scanSize.height);
    config.scanLineColor = [UIColor redColor];
    self.qrCodeScanView = [[ESQRCodeScanView alloc] initWithFrame:self.view.bounds config:config];
    self.qrCodeScanView.delegate = self;
    [self.view addSubview:self.qrCodeScanView];
    [self.qrCodeScanView startScan];
    // Do any additional setup after loading the view, typically from a nib.
}

- (void)qrCodeScanView:(ESQRCodeScanView *)qrCodeScanView didScan:(NSString *)result {
    NSLog(@"%@",result);
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
