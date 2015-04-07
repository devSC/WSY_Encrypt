//
//  WSVideoConvertUtil.m
//  TestEncrypt
//
//  Created by WOW on 15/3/29.
//  Copyright (c) 2015年 WoWSai. All rights reserved.
//

#import "WSVideoConvertUtil.h"

@implementation WSVideoConvertUtil

+(void)decodeFileWithFileName:(NSString *)fileName completeHandler:(void (^)())completeHandler errorHandler:(void (^)(NSError *error))errorHandler
{
    NSFileManager *manager = [NSFileManager defaultManager];
    NSString *documentPath = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) firstObject];
    NSString *encrypthPath = [documentPath stringByAppendingPathComponent:[NSString stringWithFormat:@"%@.sgk", fileName]];
    
    BOOL fileExist = [manager fileExistsAtPath:encrypthPath isDirectory:nil];
    if (!fileExist) {
        NSError *error = [NSError errorWithDomain:@"没有加密文件" code:1 userInfo:nil];
        errorHandler(error);
        return;
    }
    
    
    NSString *decodeFilePath = [documentPath stringByAppendingPathComponent:[NSString stringWithFormat:@"%@.mp4", fileName]];
    
    [WSVideoConvertUtil chectFileExistWithFilePath:decodeFilePath];
#if 0
    NSFileHandle * readHandle = [NSFileHandle fileHandleForReadingAtPath:encrypthPath];
    NSFileHandle * writeHandle = [NSFileHandle fileHandleForWritingAtPath:decodeFilePath];
    NSData *headerData = [readHandle readDataOfLength:16];
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
    
    [writeHandle writeData:key2];
    //        [writeHandle writeData:[readHandle readDataToEndOfFile]];
    NSData *data = [readHandle readDataOfLength:1000];
    while (data.length != 0) {
        [writeHandle writeData:data];
        data = [readHandle readDataOfLength:1000];
    }
    
    [readHandle closeFile];
    [writeHandle closeFile];
    
#else
    NSFileHandle *readHandler = [NSFileHandle fileHandleForReadingAtPath:encrypthPath];
    NSFileHandle *writeHandler = [NSFileHandle fileHandleForWritingAtPath:decodeFilePath];
    NSString *key = @"da2514efeb1ad217140454taskwn49c1283062467080280c8c742869ffbeb1669618a4a308475161474798bbd02d3810955817359843taskwn4a77605eaa89f93a6e9954e020b10d6be129349348ab1166fc79ecd13ed837a829f0073610189643dde15fb4688e6d";
    //处理头部
    NSData *headerData = [readHandler readDataOfLength:16];
    Byte *headByte = (Byte *)[headerData bytes];
    if ([WSVideoConvertUtil checkIsSkg:headByte]) {
        if ([WSVideoConvertUtil checkKeyVersionWithByte:headByte]) {
            
//            NSString *subKey = [key substringFromIndex:headByte[5]];
//            while (subKey.length < 1024) {
//                subKey = [subKey stringByAppendingString:subKey];
//            }
//            NSData *stringData = [subKey dataUsingEncoding:NSUTF8StringEncoding];
//            NSMutableData *data = [NSMutableData dataWithData:stringData];
//            NSData *newData = [data subdataWithRange:NSMakeRange(0, 1024)];//key0fix
            NSData *key1 = [headerData subdataWithRange:NSMakeRange(5, 1)];
            char *key1Char = (char *)key1.bytes;

            NSString *sub = [key substringFromIndex:key1Char[0]];
            NSData *key0Sub = [sub dataUsingEncoding:NSUTF8StringEncoding];
            
            NSMutableData *key0fix = [NSMutableData dataWithLength:1024];
            
            for (int i = 0; i < 8; i++) {
                [key0fix replaceBytesInRange:NSMakeRange(i*key0Sub.length, key0Sub.length) withBytes:(const void *)[key0Sub bytes]];
            }
            NSData *newFix = [key0fix subdataWithRange:NSMakeRange(0, 1024)];

            char *stringByte = (char *)newFix.bytes;
            char key2Char[1024];
            for (int i = 0; i < 1024; i ++) {
                key2Char[i] = stringByte[i] ^ key1Char[0];
            }
            NSData *frontData = [readHandler readDataOfLength:1024];
            char *frontDataChar = (char *)frontData.bytes;
            char endChar[1024];
            for (int i = 0; i<1024; i ++) {
                endChar[i] = key2Char[i] ^ frontDataChar[i] ;
            }
            NSData *endData = [NSData dataWithBytes:endChar length:1024];
            [writeHandler writeData:endData];
            NSInteger readOfFileLength = 1024*10;
            NSData *readData = [readHandler readDataOfLength:readOfFileLength];
            while (readData.length != 0) {
                [writeHandler writeData:readData];
                readData = [readHandler readDataOfLength:readOfFileLength];
            }
            [readHandler closeFile];
            [writeHandler closeFile];
            completeHandler();
            
        }else {
            //提示更新版本
            NSError *error = [NSError errorWithDomain:@"请更新版本" code:1 userInfo:nil];
            errorHandler(error);
        }
    }
#endif
}

+ (BOOL)checkKeyVersionWithByte: (Byte *)byte{
    return byte[3] == 0x31 ? YES : NO;
}

+ (BOOL)checkIsSkg: (Byte *)byte {
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


+ (void)chectFileExistWithFilePath: (NSString *)path
{
    NSError *error = nil;
    if ([[NSFileManager defaultManager] fileExistsAtPath:path isDirectory:nil]) {
        [[NSFileManager defaultManager] removeItemAtPath:path error:&error];
        if (error) {
            NSLog(@"error :%@", [error description]);
        }else {
            NSLog(@"移除成功");
        }
    }else {
        BOOL creatSuccess = [[NSFileManager defaultManager] createFileAtPath:path contents:nil attributes:nil];
        if (creatSuccess) {
            NSLog(@"创建文件成功");
        }else {
            NSLog(@"创建文件失败");
        }
    }
}
@end
