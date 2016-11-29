//
//  ZYDownloadManagement.h
//  DownloadVideoDemo
//
//  Created by chuanglong03 on 2016/11/28.
//  Copyright © 2016年 chuanglong. All rights reserved.
//

#import <Foundation/Foundation.h>

@class ZYDownload;

@interface ZYDownloadManagement : NSObject

@property (nonatomic, strong) ZYDownload *download;

// 单例
+ (ZYDownloadManagement *)sharedManager;
// 添加下载任务
- (void)addDownloadWithUrl:(NSString *)url;
// 查找单个
- (ZYDownload *)selectDownloadWithUrl:(NSString *)url;
// 查找所有
- (NSArray *)selectDownloads;

@end
