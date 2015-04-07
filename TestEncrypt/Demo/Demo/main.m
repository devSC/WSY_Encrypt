//
//  main.m
//  Demo
//
//  Created by Yue on 15/4/6.
//  Copyright (c) 2015年 Yue. All rights reserved.
//

#import <Foundation/Foundation.h>

int main(int argc, const char * argv[]) {
    @autoreleasepool {
        // insert code here...
        /*
        NSLog(@"Hello, World!");
    
        NSString *homePath=NSHomeDirectory();
        NSString *oriFilePath=[homePath stringByAppendingPathComponent:@"Downloads/zidan.mp4"];
        NSString *finFilePath=[homePath stringByAppendingPathComponent:@"Desktop/zidianH.mp4"];
        //利用fileManager去创建目标文件（源文件已有不必创建）
        NSFileManager *fileManager=[NSFileManager defaultManager];
        [fileManager createFileAtPath:finFilePath contents:nil attributes:nil];
        //打开源文件和目标文件
        NSFileHandle *oriFile=[NSFileHandle fileHandleForReadingAtPath:oriFilePath];
        NSFileHandle *finFile=[NSFileHandle fileHandleForWritingAtPath:finFilePath];
        //把源文件一次性读取出来的数据写入到目标文件中
//        [finFile writeData:[oriFile readDataToEndOfFile]];
        
//        unsigned long long picSize = [oriFile seekToEndOfFile]; // 图片大小
//        unsigned long long offset = 0;
//        // 循环读取文件写入到document下空的jpg文件
//        [oriFile seekToFileOffset:0]; // 设置文件指针
//        NSData *data = nil;
//        
//        while (offset + 1000 <= picSize) { // 一次读1000
//            
//            data = [oriFile readDataOfLength:1000];
//            
//            [finFile writeData:data];
//            offset += 1000;
//            NSLog(@"%llu",offset);
//        }
        // 不足1000的读到最后
//        data = [oriFile readDataToEndOfFile];
//        [finFile writeData:data];        //关闭文件
        
        //获取源文件大小，利用fileManager先获取文件属性，然后提取属性里面的文件大小，属性是一个字典，然后再把文件大小转化成整形
        NSDictionary *oriAttr=[[NSFileManager defaultManager] attributesOfItemAtPath:oriFilePath error:nil];
        NSNumber *fileSize0=[oriAttr objectForKey:NSFileSize];
        NSInteger fileSize=[fileSize0 longValue];
        //先设定已读文件大小为0，和一个while判断值
        NSInteger fileReadSize= 0;
        NSInteger readerOfLength = 1024*20;
        BOOL isEnd=YES;
        while (isEnd) {
            NSInteger sublength=fileSize-fileReadSize;//判断还有多少未读
            NSData *data=nil;//先设定个空数据
            if (sublength<readerOfLength) { //如果未读的数据少于500字节那么全都读取出来，并结束while循环
                isEnd=NO;
                data=[oriFile readDataToEndOfFile];
            }else{
                data=[oriFile readDataOfLength:readerOfLength];//如果未读的大于500字节，那么读取500字节
                fileReadSize+= readerOfLength;//把已读的加上500字节
                [oriFile seekToFileOffset:fileReadSize];//把光标定位在已读的末尾
            }
            [finFile writeData:data];//把以上存在data中得数据写入到目标文件中
        }
        
        
        [oriFile closeFile];
        [finFile closeFile];
        */
        NSString *sourcePaht = [NSHomeDirectory() stringByAppendingPathComponent:@"Downloads/22.sgk"];
        
        NSString *targetPaht = [NSHomeDirectory() stringByAppendingPathComponent:@"Desktop/24.mp4"];
        
        NSFileManager *firlManger = [NSFileManager defaultManager];
        
        BOOL isSuccess = [firlManger createFileAtPath:targetPaht contents:nil attributes:nil];
        if (isSuccess) {
            NSLog(@"目标文件创建成功");
        }
        
        NSFileHandle * readHandle = [NSFileHandle fileHandleForReadingAtPath:sourcePaht];
        NSFileHandle * writeHandle = [NSFileHandle fileHandleForWritingAtPath:targetPaht];
        
        
        
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
            
            [writeHandle writeData:key2];
//        [writeHandle writeData:[readHandle readDataToEndOfFile]];
            NSData *data = [readHandle readDataOfLength:1000];
            while (data.length != 0) {
                [writeHandle writeData:data];
                data = [readHandle readDataOfLength:1000];
            }
//        
//        //获取源文件大小，利用fileManager先获取文件属性，然后提取属性里面的文件大小，属性是一个字典，然后再把文件大小转化成整形
//        NSDictionary *oriAttr=[[NSFileManager defaultManager] attributesOfItemAtPath:sourcePaht error:nil];
//        NSNumber *fileSize0=[oriAttr objectForKey:NSFileSize];
//        NSInteger fileSize=[fileSize0 longValue];
//        //先设定已读文件大小为0，和一个while判断值
//        NSInteger fileReadSize= 1024+16;
//        NSInteger readerOfLength = 1024*10;
//        BOOL isEnd=YES;
//        while (isEnd) {
//            NSInteger sublength=fileSize-fileReadSize;//判断还有多少未读
//            NSData *data=nil;//先设定个空数据
//            if (sublength<readerOfLength) { //如果未读的数据少于500字节那么全都读取出来，并结束while循环
//                isEnd=NO;
//                data=[readHandle readDataToEndOfFile];
//            }else{
//                data=[readHandle readDataOfLength:readerOfLength];//如果未读的大于500字节，那么读取500字节
//                fileReadSize+= readerOfLength;//把已读的加上500字节
//                [readHandle seekToFileOffset:fileReadSize];//把光标定位在已读的末尾
//            }
//            [writeHandle writeData:data];//把以上存在data中得数据写入到目标文件中
//        }
        
        
            [readHandle closeFile];
            [writeHandle closeFile];
    }
    return 0;
}
