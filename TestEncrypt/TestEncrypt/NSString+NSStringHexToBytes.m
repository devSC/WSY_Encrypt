//
//  NSString+NSStringHexToBytes.m
//  TestEncrypt
//
//  Created by 袁仕崇 on 15/3/31.
//  Copyright (c) 2015年 WoWSai. All rights reserved.
//

#import "NSString+NSStringHexToBytes.h"

@implementation NSString (NSStringHexToBytes)
-(NSData*) hexToBytes {
    NSMutableData* data = [NSMutableData data];
    int idx;
    for (idx = 0; idx+2 <= self.length; idx+=2) {
        NSRange range = NSMakeRange(idx, 2);
        NSString* hexStr = [self substringWithRange:range];
        NSScanner* scanner = [NSScanner scannerWithString:hexStr];
        unsigned int intValue;
        [scanner scanHexInt:&intValue];
        [data appendBytes:&intValue length:1];
    }
    return data;
}
@end