//
//  ESQRCodeScanView.m
//  ESQRCodeScan
//
//  Created by codeLocker on 2018/1/17.
//  Copyright © 2018年 codeLocker. All rights reserved.
//

#import "ESQRCodeScanView.h"
#import <AVFoundation/AVFoundation.h>

@interface ESQRCodeScanView()<AVCaptureMetadataOutputObjectsDelegate>
@property (nonatomic, strong) ESQRCodeScanConfig *config;
@property (nonatomic, strong) UIView *maskView;
@property (nonatomic, strong) UIView *scanView;
@property (nonatomic, strong) UIView *scanLine;
@property (nonatomic, strong) AVCaptureDevice *device;
@property (nonatomic, strong) AVCaptureDeviceInput *deviceInput;
@property (nonatomic, strong) AVCaptureMetadataOutput *dataOutput;
@property (nonatomic, strong) AVCaptureSession *session;
@property (nonatomic, strong) AVCaptureVideoPreviewLayer *previewLayer;
@end

@implementation ESQRCodeScanView

- (id)initWithFrame:(CGRect)frame config:(ESQRCodeScanConfig *)config {
    self = [super initWithFrame:frame];
    if (self) {
        self.config = config;
        [self loadUI];
        [self layout];
    }
    return self;
}

- (id)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        self.config = [[ESQRCodeScanConfig alloc] init];
        [self loadUI];
        [self layout];
    }
    return self;
}

#pragma mark - Private_Methods
- (void)addScanLineAnimation{
    CABasicAnimation *animation = [CABasicAnimation animationWithKeyPath:@"transform.translation.y"];
    animation.fromValue = @(-self.config.scanLineHeight);
    animation.toValue = @(self.config.scanRegion.size.height);
    animation.duration = self.config.scanDuration;
    animation.repeatCount = OPEN_MAX;
    animation.fillMode = kCAFillModeForwards;
    animation.removedOnCompletion = NO;
    animation.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut];
    [self.scanLine.layer addAnimation:animation forKey:@"scanLineAnimation"];
}

- (void)removeScanLineAnimation{
    [self.scanLine.layer removeAnimationForKey:@"scanLineAnimation"];
}

- (void)configCamera {
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        self.device = [AVCaptureDevice defaultDeviceWithMediaType:AVMediaTypeVideo];
        NSError *error;
        self.deviceInput = [AVCaptureDeviceInput deviceInputWithDevice:self.device error:&error];
        if (error) {
            NSLog(@"%@",error);
        }
        self.dataOutput = [[AVCaptureMetadataOutput alloc] init];
        [self.dataOutput setMetadataObjectsDelegate:self queue:dispatch_get_main_queue()];
        
        self.session = [[AVCaptureSession alloc] init];
        if ([self.device supportsAVCaptureSessionPreset:AVCaptureSessionPreset1920x1080]) {
            [self.session setSessionPreset:AVCaptureSessionPreset1920x1080];
        }
        else{
            [self.session setSessionPreset:AVCaptureSessionPresetHigh];
        }
        if ([self.session canAddInput:self.deviceInput]){
            [self.session addInput:self.deviceInput];
        }
        if ([self.session canAddOutput:self.dataOutput]){
            [self.session addOutput:self.dataOutput];
        }
        if (![self.dataOutput.availableMetadataObjectTypes containsObject:AVMetadataObjectTypeQRCode]) {
            NSLog(@"The camera unsupport for QRCode.");
        }
        self.dataOutput.metadataObjectTypes = @[AVMetadataObjectTypeQRCode];
        dispatch_async(dispatch_get_main_queue(), ^{
            self.previewLayer = [AVCaptureVideoPreviewLayer layerWithSession:self.session];
            self.previewLayer.videoGravity = AVLayerVideoGravityResizeAspectFill;
            self.previewLayer.frame = self.frame;
            [self.layer insertSublayer:self.previewLayer atIndex:0];
            [self.session startRunning];
            self.dataOutput.rectOfInterest = [self.previewLayer metadataOutputRectOfInterestForRect:self.config.scanRegion];
        });
    });
}

- (void)startScan {
    if (!self.session) {
        [self configCamera];
    }
    if (self.session.isRunning) {
        return;
    }
    [self.session startRunning];
}

- (void)stopScan {
    if (!self.session.isRunning){
        return;
    }
    [self.session stopRunning];
    [self removeScanLineAnimation];
}

#pragma mark - AVCaptureMetadataOutputObjectsDelegate
- (void)captureOutput:(AVCaptureOutput *)captureOutput didOutputMetadataObjects:(NSArray<AVMetadataMachineReadableCodeObject *> *)metadataObjects fromConnection:(AVCaptureConnection *)connection{
    if (metadataObjects.count == 0) {
        return;
    }
    NSString *result = [metadataObjects.firstObject stringValue];
    if (self.delegate && [self.delegate respondsToSelector:@selector(qrCodeScanView:didScan:)]) {
        [self.delegate qrCodeScanView:self didScan:result];
    }
}

#pragma mark - Load_UI
- (void)loadUI {
    [self addSubview:self.maskView];
    [self addSubview:self.scanView];
    [self drawScanViewCorner];
    [self.scanView addSubview:self.scanLine];
    [self addScanLineAnimation];
}

/**
 绘制扫描区域四个角
 */
- (void)drawScanViewCorner {
    CAShapeLayer *lineLayer = [CAShapeLayer layer];
    lineLayer.lineWidth = self.config.cornerWidth;
    lineLayer.strokeColor = self.config.cornerColor.CGColor;
    lineLayer.fillColor = [UIColor clearColor].CGColor;
    CGFloat lineLength = self.config.scanRegion.size.width / 12;
    UIBezierPath *lineBezierPath = [UIBezierPath bezierPath];
    
    CGFloat spacing = self.config.cornerWidth/2;
    //左上角
    CGPoint leftUpPoint = (CGPoint){self.config.scanRegion.origin.x + spacing ,self.config.scanRegion.origin.y + spacing};
    [lineBezierPath moveToPoint:(CGPoint){leftUpPoint.x,leftUpPoint.y + lineLength}];
    [lineBezierPath addLineToPoint:leftUpPoint];
    [lineBezierPath addLineToPoint:(CGPoint){leftUpPoint.x + lineLength,leftUpPoint.y}];
    lineLayer.path = lineBezierPath.CGPath;
    [self.layer addSublayer:lineLayer];
    //左下角
    CGPoint leftDownPoint = (CGPoint){self.config.scanRegion.origin.x + spacing,self.config.scanRegion.origin.y + self.config.scanRegion.size.height - spacing};
    [lineBezierPath moveToPoint:(CGPoint){leftDownPoint.x,leftDownPoint.y - lineLength}];
    [lineBezierPath addLineToPoint:leftDownPoint];
    [lineBezierPath addLineToPoint:(CGPoint){leftDownPoint.x + lineLength,leftDownPoint.y}];
    lineLayer.path = lineBezierPath.CGPath;
    [self.layer addSublayer:lineLayer];
    //右上角
    CGPoint rightUpPoint = (CGPoint){self.config.scanRegion.origin.x + self.config.scanRegion.size.width - spacing,self.config.scanRegion.origin.y + spacing};
    [lineBezierPath moveToPoint:(CGPoint){rightUpPoint.x - lineLength,rightUpPoint.y}];
    [lineBezierPath addLineToPoint:rightUpPoint];
    [lineBezierPath addLineToPoint:(CGPoint){rightUpPoint.x,rightUpPoint.y + lineLength}];
    lineLayer.path = lineBezierPath.CGPath;
    [self.layer addSublayer:lineLayer];
    //右下角
    CGPoint rightDownPoint = (CGPoint){self.config.scanRegion.origin.x + self.config.scanRegion.size.width - spacing,self.config.scanRegion.origin.y + self.config.scanRegion.size.height - spacing};
    [lineBezierPath moveToPoint:(CGPoint){rightDownPoint.x - lineLength,rightDownPoint.y}];
    [lineBezierPath addLineToPoint:rightDownPoint];
    [lineBezierPath addLineToPoint:(CGPoint){rightDownPoint.x,rightDownPoint.y - lineLength}];
    lineLayer.path = lineBezierPath.CGPath;
    [self.layer addSublayer:lineLayer];
}


- (void)layout {
    
}

#pragma mark - Setter && Getter
- (UIView *)maskView {
    if (!_maskView) {
        _maskView = [[UIView alloc]initWithFrame:self.bounds];
        _maskView.backgroundColor = [UIColor colorWithRed:0.0 green:0.0 blue:0.0 alpha:0.5];
        UIBezierPath *fullBezierPath = [UIBezierPath bezierPathWithRect:self.bounds];
        UIBezierPath *scanBezierPath = [UIBezierPath bezierPathWithRect:self.config.scanRegion];
        [fullBezierPath appendPath:[scanBezierPath  bezierPathByReversingPath]];
        CAShapeLayer *shapeLayer = [CAShapeLayer layer];
        shapeLayer.path = fullBezierPath.CGPath;
        _maskView.layer.mask = shapeLayer;
    }
    return _maskView;
}

- (UIView *)scanView {
    if (!_scanView) {
        _scanView = [[UIView alloc] initWithFrame:self.config.scanRegion];
        _scanView.clipsToBounds = YES;
    }
    return _scanView;
}

- (UIView *)scanLine{
    if (!_scanLine) {
        _scanLine = [[UIView alloc]initWithFrame:CGRectMake(0,0, self.config.scanRegion.size.width, self.config.scanLineHeight)];
        CAGradientLayer *gradient = [CAGradientLayer layer];
        gradient.startPoint = CGPointMake(0.5, 0);
        gradient.endPoint = CGPointMake(0.5, 1);
        gradient.frame = _scanLine.layer.bounds;
        gradient.colors = @[(__bridge id)[self.config.scanLineColor colorWithAlphaComponent:0].CGColor,(__bridge id)[self.config.scanLineColor colorWithAlphaComponent:0.4f].CGColor,(__bridge id)self.config.scanLineColor.CGColor];
        gradient.locations = @[@0,@0.96,@0.97];
        [_scanLine.layer addSublayer:gradient];
    }
    return _scanLine;
}
@end
