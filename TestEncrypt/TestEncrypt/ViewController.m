//
//  ViewController.m
//  TestEncrypt
//
//  Created by WOW on 15/3/29.
//  Copyright (c) 2015年 WoWSai. All rights reserved.
//

#import "ViewController.h"
#import <CommonCrypto/CommonCrypto.h>
#import "ConverUtil.h"
#import <MediaPlayer/MediaPlayer.h>
@interface ViewController ()

@end
#define filePath [[NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) firstObject] stringByAppendingPathComponent:@"movie.sgk"]
#define movFilePath [[NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) firstObject] stringByAppendingPathComponent:@"movie.mp4"]
static NSString *skgString = @"http://mov1.shougongke.com/x/22.sgk";

static NSString *originKey = @"da2514efeb1ad217140454taskwn49c1283062467080280c8c742869ffbeb1669618a4a308475161474798bbd02d3810955817359843taskwn4a77605eaa89f93a6e9954e020b10d6be129349348ab1166fc79ecd13ed837a829f0073610189643dde15fb4688e6d";

@implementation ViewController



- (void)viewDidLoad {
    [super viewDidLoad];
    
    
    NSError *error = nil;
    
    [self downloadTheFile];
    
    NSFileHandle *fileHandle = [NSFileHandle fileHandleForReadingAtPath:filePath];
    if (error) {
        NSLog(@"error: %@", [error description]);
    }

    NSData *datas = [fileHandle readDataOfLength:16];
    
    
    Byte *headByte = (Byte *)[datas bytes];
    for(int i=0;i<[datas length];i++) {
        printf("testByte = %d\n",headByte[i]);
        NSLog(@"%@", [NSString stringWithFormat:@"%c", headByte[i]]);
    }

    if ([self checkIsSkg:headByte]) {
        if ([self checkKeyVersionWithByte:headByte]) {

            //5. 把 key0fix 逐字节与 key1 进行 XOR 计算，得到 trueKey；
               Byte *trueKey = [self trueKeyWithIndex:headByte[5]];
            /* 6. 继续读取需要解密的文件，并打开输出文件，
             如果是前 1024 个字节，与 trueKey 的对应位置进行 XOR 计算，并输出；
             否则，直接输出。
             */
            [fileHandle seekToFileOffset:[fileHandle offsetInFile]];
            NSData *headData = [fileHandle readDataOfLength:1024];
            Byte *newHeadByte = (Byte *)headData.bytes;
            for (int i = 0; i < 1024; i++) {
                newHeadByte[i] = (newHeadByte[i]^trueKey[i]);
            }
            [self chectFileExistWithFilePath:movFilePath];
            [[NSData dataWithBytes:newHeadByte length:1024] writeToFile:movFilePath atomically:YES];;
            [fileHandle offsetInFile];
            [[fileHandle readDataToEndOfFile] writeToFile:movFilePath atomically:YES];

            dispatch_async(dispatch_get_main_queue(), ^{
                [self playVideoWithUrl:movFilePath];

            });
            NSLog(@"转换成功");
        }else {
            //提示更新版本
        }
        
    }
    
}
- (void)playVideoWithUrl: (NSString *)urlString
{
    MPMoviePlayerViewController *mpVC = [[MPMoviePlayerViewController alloc] initWithContentURL:[NSURL fileURLWithPath:urlString]];
    [self presentMoviePlayerViewControllerAnimated:mpVC];
}
- (void)chectFileExistWithFilePath: (NSString *)path
{
    NSError *error = nil;
    if ([[NSFileManager defaultManager] fileExistsAtPath:path isDirectory:nil]) {
        [[NSFileManager defaultManager] removeItemAtPath:path error:&error];
        if (error) {
            NSLog(@"error :%@", [error description]);
        }else {
            NSLog(@"移除成功");
        }
    }
}
- (Byte *)trueKeyWithIndex: (int)index
{
    NSString *keySub = [originKey substringFromIndex:index];
    while (keySub.length < 1024) {
      keySub =[keySub stringByAppendingString:keySub];
    }
    NSData *ksData = [keySub dataUsingEncoding: NSUTF8StringEncoding];
    Byte *ksBytes = (Byte *)[ksData bytes];
//    Byte *bytes = keySub.
    for (int i = 0; i < 1024; i++) {
        //进行异或运算
        ksBytes[i] =(ksBytes[i]^index);
    }
//    NSLog(@"%@", keySub);
    return ksBytes;
}
- (BOOL)checkKeyVersionWithByte: (Byte *)byte{
    return byte[3] == 0x31 ? YES : NO;
}

- (BOOL)checkIsSkg: (Byte *)byte {
    if (byte[0] == 's') {
        if (byte[1] == 'g') {
            if (byte[2] == 'k') {
                return YES;
            }
            return NO;
        }
        return NO;
    }
    return NO;
}
- (NSString *)dataToHexStringData: (NSData *)data
{
    NSUInteger len = data.length;
    char * chars = (char *)[data bytes];
    NSMutableString * hexString = [[NSMutableString alloc] init];
    
    for(NSUInteger i = 0; i < len; i++ )
        [hexString appendString:[NSString stringWithFormat:@"  %0.2hhx", chars[i]]];
    
    
    return hexString;
}

- (void)downloadTheFile
{
    NSString *urlAsString = skgString;
    NSURL    *url = [NSURL URLWithString:urlAsString];
    NSURLRequest *request = [NSURLRequest requestWithURL:url];
    NSError *error = nil;
    NSData   *data = [NSURLConnection sendSynchronousRequest:request
                                           returningResponse:nil
                                                       error:&error];
    /* 下载的数据 */
    if (data != nil){
        NSLog(@"下载成功");
        [self chectFileExistWithFilePath:filePath];
        if ([data writeToFile:filePath atomically:YES]) {
            NSLog(@"保存成功.");
        }
        else
        {
            NSLog(@"保存失败.");
        }
    } else {
        NSLog(@"%@", error);
    }
    
}


/*
- (void) loadFileContentsIntoTextView
{
    //通过流打开一个文件
 
    NSInputStream *inputStream = [[NSInputStream alloc] initWithFileAtPath: filePath];
 
    [inputStream open];
 
 
    NSInteger maxLength = 128;
    uint8_t readBuffer [maxLength];
    //是否已经到结尾标识
    BOOL endOfStreamReached = NO;
    // NOTE: this tight loop will block until stream ends
    while (! endOfStreamReached)
    {
        NSInteger bytesRead = [inputStream read: readBuffer maxLength:maxLength];
        if (bytesRead == 0)
        {//文件读取到最后
            endOfStreamReached = YES;
        }
        else if (bytesRead == -1)
        {//文件读取错误
            endOfStreamReached = YES;
        }
        else
        {
            NSString *readBufferString =[[NSString alloc] initWithBytesNoCopy: readBuffer length: bytesRead encoding: NSUTF8StringEncoding freeWhenDone: NO];
            //将字符不段的加载到视图
            [self appendTextToView: readBufferString];
            [readBufferString release];
        }
    }
    [inputStream close];
    [inputStream release];
}
*/

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
