//
//  ZYDownloadModel.h
//  DownloadVideoDemo
//
//  Created by chuanglong03 on 2016/11/25.
//  Copyright © 2016年 chuanglong. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface ZYDownloadModel : NSObject

@property (nonatomic, copy) NSString *filePath; // 文件路径
@property (nonatomic, copy) NSString *url; // 视频网址
@property (nonatomic, copy) NSString *resumeDataString; // 未完成下载数据
@property (nonatomic, copy) NSString *fileSize; // 未完成下载大小

@end
