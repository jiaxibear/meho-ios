//
//  AudioConverter.h
//  meho-ios
//
//  Created by Meho Dev on 4/5/20.
//  Copyright © 2020 Meho. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface AudioConverter : NSObject

- (NSString *)mp3FileFromM4aFile:(NSString *)m4aFilePath;

@end
