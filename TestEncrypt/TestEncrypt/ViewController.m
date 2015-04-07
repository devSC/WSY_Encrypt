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
#import "NSString+NSStringHexToBytes.h"
#import "WSVideoConvertUtil.h"
@interface ViewController ()

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
    
//    self.view.backgroundColor = [UIColor cyanColor];
    
    NSError *error = nil;
    
    [self downloadTheFile];
    [WSVideoConvertUtil decodeFileWithFileName:@"22" completeHandler:^{
        NSLog(@"已完成");
    } errorHandler:^(NSError *error) {
        NSLog(@"%@", error.description);
    }];
    
    return;
    NSFileHandle *fileHandle = [NSFileHandle fileHandleForReadingAtPath:filePath];
    if (error) {
        NSLog(@"error: %@", [error description]);
    }

    NSData *datas = [fileHandle readDataOfLength:16];
    
    
    Byte *headByte = (Byte *)[datas bytes];
//    for(int i=0;i<[datas length];i++) {
//        printf("testByte = %d\n",headByte[i]);
//        NSLog(@"%@", [NSString stringWithFormat:@"%c", headByte[i]]);
//    }
    
    //检查是sgk开头
    if ([self checkIsSkg:headByte]) {
        //检查算法版本号 如果算法版本号不能支持，则无法解密；
        if ([self checkKeyVersionWithByte:headByte]) {
            Byte *trueKey = [self trueKeyWithHeaderString:headByte];
            [fileHandle seekToFileOffset:[fileHandle offsetInFile]];
            NSData *headData = [fileHandle readDataOfLength:1024];
            Byte *newHeadByte = (Byte *)headData.bytes;
            NSString *new = nil;
            for (int i = 0; i < 1024; i++) {
                newHeadByte[i] = trueKey[i] ^ newHeadByte[i];
                NSLog(@"%@", [NSString stringWithFormat:@"%c", newHeadByte[i]]);
                new = [new stringByAppendingString:[NSString stringWithFormat:@"%c", newHeadByte[i]]];
                printf("i: %d testByte = %d\n",i, newHeadByte[i]);
            }
            NSLog(@"newHeadByte: %s", newHeadByte);
            [self chectFileExistWithFilePath:movFilePath];

            [[NSData dataWithBytes:newHeadByte length:1024] writeToFile:movFilePath atomically:YES];;
//            [fileHandle offsetInFile];
//            NSLog(@"%llu", [fileHandle offsetInFile]);

            [fileHandle seekToFileOffset:[fileHandle offsetInFile]];
            [[fileHandle readDataToEndOfFile] writeToFile:movFilePath atomically:YES];

            NSLog(@"转换成功");
        }else {
            //提示更新版本
        }
        
    }
    
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

//- (Byte *)trueKeyWithKey1: (Byte *)key

- (Byte *)trueKeyWithHeader: (int)header
{
    //4. 从 offset 为 key1 处，截取解密密钥 key0，得到 key0sub；扩展长度到 1024 字节，以下称为 key0fix；
    char keySub[] = {};
    for (int i = header, j = 0; i < strlen(originKey); i ++, j ++) {
//        keySub = strcat(keySub, &originKey[i]);
        keySub[j] = originKey[i];
    }
//    NSString *keySub = [originKey substringFromIndex:header[5]];
    printf("%s %lu", keySub, strlen(keySub));
    
    char keySub2[] = {};
    int j = 0;
    int keySubLen = (int )strlen(keySub);
    while (strlen(keySub2) < 1024) {
//        keySub2[] = strcat(keySub, keySub);
        for (int i = 0; i < keySubLen; i ++) {
            //        keySub = strcat(keySub, &originKey[i]);
            keySub2[j] = keySub[i];
            printf("\n%d %d keySub:Len %lu" ,j, i, strlen(keySub));
            j ++;
        }
        if (strlen(keySub) > 1024) {
            break;
        }
    }
    
//    NSData *ksData = [keySub dataUsingEncoding: NSUTF8StringEncoding];
//    Byte *ksBytes = (Byte *)[ksData bytes];
//        Byte *ksBytes = (Byte *)[keySub  hexToBytes].bytes;
//    Byte *bytes = keySub.
//    int headerC = header[5];
    for (int i = 0; i < 1024; i++) {
        //进行异或运算
//        ksBytes[i] =(ksBytes[i]^header[5]);
        
        keySub[i] = keySub[i]^header;
    }
    NSLog(@"%s", keySub);
    //ksBytes	Byte *	"|~z}z\x7f|\x7f|rs))/{y/xsz{r~~sz|x~rs\x7fx?*8 <%\x7f*||}{~.**sr-rx*}.rr~\x7f.{y{)z{/}).zyrx\x7frx\x7fs*)zz}}-(|r.(/zx./sx|*syr-{{|x}z{zsr}\x7fx//.z~-)\x7f}ss.}/|~z}z\x7f|\x7f|rs))/{y/xsz{r~~sz|x~rs\x7fx?*8 <%\x7f*||}{~.**sr-rx*}.rr~\x7f.{y{)z{/}).zyrx\x7frx\x7fs*)zz}}-(|r.(/zx./sx|*syr-{{|x}z{zsr}\x7fx//.z~-)\x7f}ss.}/|~z}z\x7f|\x7f|rs))/{y/xsz{r~~sz|x~rs\x7fx?*8 <%\x7f*||}{~.**sr-rx*}.rr~\x7f.{y{)z{/}).zyrx\x7frx\x7fs*)zz}}-(|r.(/zx./sx|*syr-{{|x}z{zsr}\x7fx//.z~-)\x7f}ss.}/|~z}z\x7f|\x7f|rs))/{y/xsz{r~~sz|x~rs\x7fx?*8 <%\x7f*||}{~.**sr-rx*}.rr~\x7f.{y{)z{/}).zyrx\x7frx\x7fs*)zz}}-(|r.(/zx./sx|*syr-{{|x}z{zsr}\x7fx//.z~-)\x7f}ss.}/|~z}z\x7f|\x7f|rs))/{y/xsz{r~~sz|x~rs\x7fx?*8 <%\x7f*||}{~.**sr-rx*}.rr~\x7f.{y{)z{/}).zyrx\x7frx\x7fs*)zz}}-(|r.(/zx./sx|*syr-{{|x}z{zsr}\x7fx//.z~-)\x7f}ss.}/|~z}z\x7f|\x7f|rs))/{y/xsz{r~~sz|x~rs\x7fx?*8 <%\x7f*||}{~.**sr-rx*}.rr~\x7f.{y{)z{/}).zyrx\x7frx\x7fs*)zz}}-(|r.(/zx./sx|*syr-{{|x}z{zsr}\x7fx//.z~-)\x7f}ss.}/|~z}z\x7f|\x7f|rs))/{y/xsz{r~~sz|x~rs\x7fx?*8 <%\x7f*||}{~.**sr-rx*}.rr~\x7f.{y{)z{/}).zyrx\x7frx\x7fs*)zz}}-(|r.(/zx./sx|*syr-{{|x}z{zsr}\x7fx//.z~-)\x7f}ss.}/|~z}z\x7f|\x7f|rs))/{y/xsz{r~~sz|x~rs\x7fx?*8 <%\x7f*||}{~.**sr-rx*}.rr~\x7f.{y{)z{/}).zyrx\x7frx\x7fs*)zz}}-(|r.(..."	0x14ab6a00
//    return ksBytes;
    return (Byte *)keySub;
}

- (Byte *)trueKeyWithHeaderString: (Byte *)header
{
    //4. 从 offset 为 key1 处，截取解密密钥 key0，得到 key0sub；扩展长度到 1024 字节，以下称为 key0fix；
    NSString *string = [originKeyString substringFromIndex:header[5]];
    while (string.length < 1024) {
        string = [string stringByAppendingString:string];
    }
    NSData *stringData = [string dataUsingEncoding:NSMacOSRomanStringEncoding];
    Byte *stringByte = (Byte *)stringData.bytes;
    NSLog(@"%s", stringByte);
    for (int i = 0; i < 1024; i ++) {
        stringByte[i] = (Byte )(stringByte[i] ^ header[5]);
    }
    NSLog(@"%s", stringByte);
    return (Byte *)stringByte;
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
- (void)pyCode
{
    NSString *sourcePaht = [NSHomeDirectory() stringByAppendingPathComponent:filePath];
    
    NSString *targetPaht = [NSHomeDirectory() stringByAppendingPathComponent:@"Desktop/24.mp4"];
    
    NSFileManager *firlManger = [NSFileManager defaultManager];
    
    BOOL isSuccess = [firlManger createFileAtPath:movFilePath contents:nil attributes:nil];
    if (isSuccess) {
        NSLog(@"目标文件创建成功");
    }
    
    NSFileHandle * readHandle = [NSFileHandle fileHandleForReadingAtPath:filePath];
    NSFileHandle * writeHandle = [NSFileHandle fileHandleForWritingAtPath:movFilePath];
    
    
    
    NSData *headerData = [readHandle readDataOfLength:16];
    
    //        NSData *headerSgk = [headerData subdataWithRange:NSMakeRange(0, 3)];
    //
    //
    //        NSString *hSgk = [[NSString alloc] initWithData:headerSgk encoding:NSUTF8StringEncoding];
    
    
    
    NSString *key0 = @"da2514efeb1ad217140454taskwn49c1283062467080280c8c742869ffbeb1669618a4a308475161474798bbd02d3810955817359843taskwn4a77605eaa89f93a6e9954e020b10d6be129349348ab1166fc79ecd13ed837a829f0073610189643dde15fb4688e6d";
    
    NSData *key1 = [headerData subdataWithRange:NSMakeRange(5, 1)];
    
    
    
    NSData *hex = [headerData subdataWithRange:NSMakeRange(8, 7)];
    
    
    NSLog(@"%@",[[NSString alloc] initWithData:hex encoding:NSUTF8StringEncoding]);
    
    
    
    char *key1C = (char *)key1.bytes;
    
    NSString *sub = [key0 substringFromIndex:key1C[0]];
    NSData *key0Sub = [sub dataUsingEncoding:NSUTF8StringEncoding];
    
    NSMutableData *key0fix = [NSMutableData dataWithLength:1024];
    
    for (int i = 0; i < 8; i++) {
        [key0fix replaceBytesInRange:NSMakeRange(i*key0Sub.length, key0Sub.length) withBytes:(const void *)[key0Sub bytes]];
    }
    
    NSData *newFix = [key0fix subdataWithRange:NSMakeRange(0, 1024)];
    
    //        NSLog(@"%@,%d",newFix,key0fix.length);
    
    
    
    
    char *key0fixChar = (char *)newFix.bytes;
    char ss[1024];
    for (int i = 0; i < 1024; i++) {
        ss[i] = key0fixChar[i] ^ key1C[0];
    }
    
    
    
    NSData *frontData = [readHandle readDataOfLength:1024];
    char *front = (char *)frontData.bytes;
    
    char newS[1024];
    for (int i = 0; i < 1024; i++) {
        newS[i] = ss[i] ^ front[i];
    }
    
    NSData *key2 = [NSData dataWithBytes:newS length:1024];
    [self chectFileExistWithFilePath:movFilePath];
    
    [key2 writeToFile:movFilePath atomically:YES];;
    //            [fileHandle offsetInFile];
    //            NSLog(@"%llu", [fileHandle offsetInFile]);
    
    [readHandle seekToFileOffset:[readHandle offsetInFile]];
    [[readHandle readDataToEndOfFile] writeToFile:movFilePath atomically:YES];
    NSLog(@"完成");
    return;
    [writeHandle writeData:key2];
    
    NSData *data = [readHandle readDataOfLength:1024*10];

    while (data != 0) {
        [writeHandle writeData:data];
        data = [readHandle readDataOfLength:1000 * 10];
    }
    
    [readHandle closeFile];
    [writeHandle closeFile];
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
