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
@interface ViewController ()

@end
#define filePath [[NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) firstObject] stringByAppendingPathComponent:@"movie.sgk"]
#define movFilePath [[NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) firstObject] stringByAppendingPathComponent:@"movie.mp4"]
static NSString *skgString = @"http://mov1.shougongke.com/x/22.sgk";
static NSString *mp4String = @"http://mov1.shougongke.com/x/21.mp4";

static NSString *originKey = @"da2514efeb1ad217140454taskwn49c1283062467080280c8c742869ffbeb1669618a4a308475161474798bbd02d3810955817359843taskwn4a77605eaa89f93a6e9954e020b10d6be129349348ab1166fc79ecd13ed837a829f0073610189643dde15fb4688e6d";
static char *originKeyC = "da2514efeb1ad217140454taskwn49c1283062467080280c8c742869ffbeb1669618a4a308475161474798bbd02d3810955817359843taskwn4a77605eaa89f93a6e9954e020b10d6be129349348ab1166fc79ecd13ed837a829f0073610189643dde15fb4688e6d";

@implementation ViewController



- (void)viewDidLoad {
    [super viewDidLoad];
    
//    self.view.backgroundColor = [UIColor cyanColor];
    
//    [self test];
//    return;
    NSError *error = nil;
    
    [self downloadTheFile];

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

            //5. 把 key0fix 逐字节与 key1 进行 XOR 计算，得到 trueKey；
//               Byte *trueKey = [self trueKeyWithI ndex:headByte[5]];
            Byte *trueKey = [self trueKeyWithHeader:headByte];
//            Byte *trueKey = [self trueKeyWithHead:headByte];
            NSLog(@"trueKey: %s\n\n\n", trueKey);

            /* 6. 继续读取需要解密的文件，并打开输出文件，
             如果是前 1024 个字节，与 trueKey 的对应位置进行 XOR 计算，并输出；
             否则，直接输出。
             */
//            NSLog(@"%llu", [fileHandle offsetInFile]);
            [fileHandle seekToFileOffset:[fileHandle offsetInFile]];
            NSMutableData *headData = [[fileHandle readDataOfLength:1024] mutableCopy];
            Byte *newHeadByte = (Byte *)headData.mutableBytes;
            NSLog(@"newHeadByte: %s", newHeadByte);
            Byte headerFile[] = {};
            for (int i = 0; i < headData.length; i++) {
                char trueChar = trueKey[i];
////                char headerChar = newHeadByte[i];
////                headerFile[i] = trueChar ^ headerChar;
                NSLog(@"i = %d %hhu %hhu", i, trueKey[i], newHeadByte[i]);
                newHeadByte[i] = (Byte)(newHeadByte[i] ^ trueChar);
                NSLog(@"*****i = %d %hhu %hhu", i, trueKey[i], newHeadByte[i]);
//                newHeadByte[i] ^= trueKey[i];
            }
//            NSData *data = [self obfuscate:headData withKey:trueKey];
            
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
- (Byte *)trueKeyWithHeader: (Byte *)header
{
    //4. 从 offset 为 key1 处，截取解密密钥 key0，得到 key0sub；扩展长度到 1024 字节，以下称为 key0fix；
    NSString *keySub = [originKey substringFromIndex:header[5]];
    while (keySub.length < 1024) {
        keySub =[keySub stringByAppendingString:keySub];
    }
    NSLog(@"keySub: %@ \n\n\n", keySub);
    NSData *ksData = [keySub dataUsingEncoding: NSMacOSRomanStringEncoding];
    Byte *ksBytes = (Byte *)[ksData bytes];
    NSLog(@"ksBytes: %s \n\n\n", ksBytes);
    char key = header[5];
    for (int i = 0; i < 1024; i++) {
        //进行异或运算
        ksBytes[i] =(Byte)(ksBytes[i] ^ key);
    }
    NSLog(@"ksBytes: %s", ksBytes);
    return ksBytes;
}

- (Byte *)trueKeyWithHead: (Byte *)header
{
    //4. 从 offset 为 key1 处，截取解密密钥 key0，得到 key0sub；扩展长度到 1024 字节，以下称为 key0fix；
//    Byte *key =
    char *byte;
//    for (int i = header[5], j = 0; i < strlen(originKeyC); i ++, j++) {
//        byte[j] = originKeyC[i];
//    }
    NSString *keySub = [originKey substringFromIndex:header[5]];
    while (keySub.length < 1024) {
        keySub =[keySub stringByAppendingString:keySub];
    }

    byte = [keySub cString];
    while (strlen(byte) < 1024) {
        byte = strcat(byte, byte);
    }
    //char -> byte
    Byte *ksByte;
    for (int i=0;i<strlen(byte);i++){
//        printf("%02X",byte[i]&0xff);//16进制
        ksByte[i] = byte[i]^0xff;
    }
    
    for (int i = 0; i < 1024; i++) {
        //进行异或运算
        ksByte[i] =(ksByte[i]^header[5]);
    }
    return ksByte;
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
//- (NSData *)obfuscate:(NSData *)data withKey:(NSString *)key
//{
//    NSMutableData *result = [data mutableCopy];
//    
//    
//    // Get pointer to data to obfuscate
//    char *dataPtr = (char *) [result mutableBytes];
//    
//    // Get pointer to key data
//    char *keyData = (char *) [[key dataUsingEncoding:NSUTF8StringEncoding] bytes];
//    
//    // Points to each char in sequence in the key
//    char *keyPtr = keyData;
//    int keyIndex = 0;
//    
//    // For each character in data, xor with current value in key
//    for (int x = 0; x < [data length]; x++)
//    {
//        // Replace current character in data with
//        // current character xor'd with current key value.
//        // Bump each pointer to the next character
////        *dataPtr = *dataPtr++ ^ *keyPtr++;
//        *dataPtr = *dataPtr ^ *keyPtr;
//        dataPtr++;
//        keyPtr++;
//        // If at end of key data, reset count and
//        // set key pointer back to start of key value
//        if (++keyIndex == [key length])
//            keyIndex = 0, keyPtr = keyData;
//    }
//    
//    return result;
//}

- (NSData *)obfuscate:(NSData *)data withKey:(Byte *)key
{
    NSMutableData *result = [data mutableCopy];
    
    
    // Get pointer to data to obfuscate
    char *dataPtr = (char *) [result mutableBytes];
    
    // Get pointer to key data
//    char *keyData = (char *) [[key dataUsingEncoding:NSUTF8StringEncoding] bytes];
    char *keyData = (char *) key;
    
    // Points to each char in sequence in the key
    char *keyPtr = keyData;
    int keyIndex = 0;
    
    // For each character in data, xor with current value in key
    for (int x = 0; x < [data length]; x++)
    {
        // Replace current character in data with
        // current character xor'd with current key value.
        // Bump each pointer to the next character
        //        *dataPtr = *dataPtr++ ^ *keyPtr++;
        *dataPtr = *dataPtr ^ *keyPtr;
        dataPtr++;
        keyPtr++;
        // If at end of key data, reset count and
        // set key pointer back to start of key value
        if (++keyIndex == strlen(keyData))
            keyIndex = 0, keyPtr = keyData;
    }
    
    return result;
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
