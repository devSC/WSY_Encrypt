//
//  WSVideoConvertUtil.h
//  TestEncrypt
//
//  Created by WOW on 15/3/29.
//  Copyright (c) 2015年 WoWSai. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface WSVideoConvertUtil : NSObject
/**
 *  <#Description#>
 *
 *  @param fileName fileName
 *  @param handler  <#handler description#>
 */
+ (void)decodeFileWithFileName: (NSString *)fileName
               completeHandler: (void (^)())completeHandler
                  errorHandler: (void(^)(NSError *error))errorHandler;

@end
