//
//  ViewController.m
//  TestEncrypt
//
//  Created by WOW on 15/3/29.
//  Copyright (c) 2015年 WoWSai. All rights reserved.
//

#import "ViewController.h"
#import <CommonCrypto/CommonCrypto.h>
#import <MediaPlayer/MediaPlayer.h>
#import "WSVideoConvertUtil.h"
@interface ViewController ()
@property (weak, nonatomic) IBOutlet UIButton *playButton;

@end
#define filePath [[NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) firstObject] stringByAppendingPathComponent:@"22.sgk"]
#define movFilePath [[NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) firstObject] stringByAppendingPathComponent:@"22.mp4"]
static NSString *skgString = @"http://mov1.shougongke.com/x/22.sgk";
static NSString *mp4String = @"http://mov1.shougongke.com/x/21.mp4";

static char *originKey = "da2514efeb1ad217140454taskwn49c1283062467080280c8c742869ffbeb1669618a4a308475161474798bbd02d3810955817359843taskwn4a77605eaa89f93a6e9954e020b10d6be129349348ab1166fc79ecd13ed837a829f0073610189643dde15fb4688e6d\0";

static NSString *originKeyString = @"da2514efeb1ad217140454taskwn49c1283062467080280c8c742869ffbeb1669618a4a308475161474798bbd02d3810955817359843taskwn4a77605eaa89f93a6e9954e020b10d6be129349348ab1166fc79ecd13ed837a829f0073610189643dde15fb4688e6d";

@implementation ViewController



- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self downloadTheFile];
    self.playButton.enabled = NO;
    [WSVideoConvertUtil decodeFileWithFileName:@"22" completeHandler:^{
        self.playButton.enabled = YES;
        NSLog(@"已完成");
    } errorHandler:^(NSError *error) {
        NSLog(@"%@", error.description);
    }];
}
- (IBAction)player:(id)sender {
    [self playVideoWithUrl:movFilePath];
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

- (void)downloadTheFile
{
    NSString *urlAsString = skgString;
//    NSString *urlAsString = mp4String;
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
