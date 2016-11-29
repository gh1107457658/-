//
//  ZYDownload.h
//  DownloadVideoDemo
//
//  Created by chuanglong03 on 2016/11/28.
//  Copyright © 2016年 chuanglong. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

typedef void (^DownloadingBlock)(CGFloat progress);
typedef void (^DownloadFinishBlock)(NSString *url);

@interface ZYDownload : NSObject

@property (nonatomic, copy) DownloadingBlock downloadingBlock;
@property (nonatomic, copy) DownloadFinishBlock downloadFinishBlock;

// 初始化
- (instancetype)initWithUrl:(NSString *)url;
// 开启任务
- (void)resumeDownloadTask;
// 暂停任务
- (void)suspendDownloadTask;

@end
