//
//  ViewController.m
//  DownloadVideoDemo
//
//  Created by chuanglong03 on 2016/11/25.
//  Copyright © 2016年 chuanglong. All rights reserved.
//

#import "ViewController.h"
#import "ZYDownloadManagement.h"
#import "ZYDownload.h"

@interface ViewController ()

@property (weak, nonatomic) IBOutlet UILabel *progressLbl;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // 添加下载任务
    [[ZYDownloadManagement sharedManager] addDownloadWithUrl:@"http://139.129.165.192/video/jk_00011_006_1_0_dh.mp4"];
    WS(weakSelf);
    [ZYDownloadManagement sharedManager].download.downloadingBlock = ^(CGFloat progress) {
        weakSelf.progressLbl.text = [NSString stringWithFormat:@"进度：%.2f%%", progress];
    };
}

#pragma mark - 开始下载
- (IBAction)startDownload:(UIButton *)sender {
    [[ZYDownloadManagement sharedManager].download resumeDownloadTask];
}

#pragma mark - 暂停下载
- (IBAction)suspendDownload:(UIButton *)sender {
    [[ZYDownloadManagement sharedManager].download suspendDownloadTask];
}

@end
