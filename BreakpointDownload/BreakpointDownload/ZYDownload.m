//
//  ZYDownload.m
//  DownloadVideoDemo
//
//  Created by chuanglong03 on 2016/11/28.
//  Copyright © 2016年 chuanglong. All rights reserved.
//

#import "ZYDownload.h"
#import "ZYFMDB.h"
#import "ZYDownloadModel.h"

@interface ZYDownload ()<NSURLSessionDownloadDelegate>

@property (nonatomic, strong) NSURLSession *session;
@property (nonatomic, strong) NSURLSessionDownloadTask *downloadTask;
@property (nonatomic, weak) NSString *url;

@end

@implementation ZYDownload

#pragma mark - 初始化
- (instancetype)initWithUrl:(NSString *)url {
    if (self = [super init]) {
        self.url = url;
        // 创建下载任务
        [self createDownloadTask];
    }
    return self;
}

#pragma mark - 创建下载任务
- (void)createDownloadTask {
     self.session = [NSURLSession sessionWithConfiguration:[NSURLSessionConfiguration defaultSessionConfiguration] delegate:self delegateQueue:[NSOperationQueue mainQueue]];
    ZYDownloadModel *downloadModel = [[ZYFMDB sharedManager] selectWithTableName:TableNameOfDownloading key:@"url" value:self.url];
    if (downloadModel == nil) {
        self.downloadTask = [self.session downloadTaskWithURL:[NSURL URLWithString:self.url]];
    } else {
        NSData *resumeData = [self getResumeDataWithDownloadModel:downloadModel];
        self.downloadTask = [self.session downloadTaskWithResumeData:resumeData];
    }
    [self.downloadTask resume];
}

#pragma mark - 获取 resumeData
- (NSData *)getResumeDataWithDownloadModel:(ZYDownloadModel *)downloadModel {
    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSString *temporaryPath = NSTemporaryDirectory();
    NSString *filePath = [temporaryPath stringByAppendingString:downloadModel.filePath];
    NSString *fileSize = [NSString stringWithFormat:@"%llu", [fileManager attributesOfItemAtPath:filePath error:nil].fileSize];
    NSString *resumeDataString = [downloadModel.resumeDataString stringByReplacingOccurrencesOfString:downloadModel.fileSize withString:fileSize];
    return [resumeDataString dataUsingEncoding:NSUTF8StringEncoding];
}

#pragma mark - 取消下载任务
- (void)cancelDownloadTask {
    WS(weakSelf);
    [self.downloadTask cancelByProducingResumeData:^(NSData * _Nullable resumeData) {
        // 解析保存 resumeData
        [weakSelf saveResumeData:resumeData];
        // 继续开始下载
        weakSelf.downloadTask = [weakSelf.session downloadTaskWithResumeData:resumeData];
        [weakSelf.downloadTask resume];
    }];
}

#pragma mark - 解析保存 resumeData
- (void)saveResumeData:(NSData *)resumeData {
    // 转为 NSString
    NSString *resumeDataString = [[NSString alloc] initWithData:resumeData encoding:NSUTF8StringEncoding];
    // 大小
    NSString *fileSize = [resumeDataString componentsSeparatedByString:@"<key>NSURLSessionResumeBytesReceived</key>\n\t<integer>"].lastObject;
    fileSize = [fileSize componentsSeparatedByString:@"</integer>"].firstObject;
    // 路径
    NSString *filePath = [resumeDataString componentsSeparatedByString:@"<key>NSURLSessionResumeInfoTempFileName</key>\n\t<string>"].lastObject;
    filePath = [filePath componentsSeparatedByString:@"</string>"].firstObject;
    // 保存
    ZYDownloadModel *downloadModel = [[ZYDownloadModel alloc] init];
    downloadModel.resumeDataString = resumeDataString;
    downloadModel.fileSize = fileSize;
    downloadModel.filePath = filePath;
    downloadModel.url = self.url;
    [[ZYFMDB sharedManager] insertWithTableName:TableNameOfDownloading downloadModel:downloadModel];
}

#pragma mark - 开启任务
- (void)resumeDownloadTask {
    [self.downloadTask resume];
}

#pragma mark - 暂停任务
- (void)suspendDownloadTask {
    [self.downloadTask suspend];
}

#pragma mark - NSURLSessionDownloadDelegate 代理方法
- (void)URLSession:(NSURLSession *)session downloadTask:(NSURLSessionDownloadTask *)downloadTask didFinishDownloadingToURL:(NSURL *)location {
    NSString *cachesPath = NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES).firstObject;
    NSString *filePath = [cachesPath stringByAppendingPathComponent:downloadTask.response.suggestedFilename];
    NSFileManager *fileManager = [NSFileManager defaultManager];
    [fileManager moveItemAtPath:location.path toPath:filePath error:nil];
    ZYDownloadModel *downloadModel = [[ZYDownloadModel alloc] init];
    downloadModel.url = self.url;
    downloadModel.filePath = filePath;
    [[ZYFMDB sharedManager] insertWithTableName:TableNameOfDownloadFinish downloadModel:downloadModel];
    NSLog(@"%@", filePath);
    if (self.downloadFinishBlock) {
        self.downloadFinishBlock(self.url);
    }
}

- (void)URLSession:(NSURLSession *)session downloadTask:(NSURLSessionDownloadTask *)downloadTask didWriteData:(int64_t)bytesWritten totalBytesWritten:(int64_t)totalBytesWritten totalBytesExpectedToWrite:(int64_t)totalBytesExpectedToWrite {
    if ([[ZYFMDB sharedManager] selectWithTableName:TableNameOfDownloading key:@"url" value:self.url] == nil) {
        [self cancelDownloadTask];
    }
    CGFloat progress = (CGFloat)totalBytesWritten/totalBytesExpectedToWrite;
    WS(weakSelf);
    dispatch_async(dispatch_get_main_queue(), ^{
        if (weakSelf.downloadingBlock) {
            weakSelf.downloadingBlock(progress*100);
        }
    });
}

@end
