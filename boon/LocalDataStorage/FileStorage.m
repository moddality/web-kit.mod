//
//  LQStorage.m
//  Liquid
//
//  Created by Liquid Data Intelligence, S.A. (lqd.io) on 01/09/14.
//  Copyright (c) Liquid Data Intelligence, S.A. All rights reserved.
//

#import "FileStorage.h"
#import "Defaults.h"
#import "NSString+MD5.h"

#define kDirectory kBundle

@implementation FileStorage

#pragma mark - File Handling

+ (BOOL)deleteAllLiquidFiles {
    BOOL status = false;
    for (NSString *path in [FileStorage filesInDirectory:[FileStorage phrontDirectory]]) {
        status &= [[NSFileManager defaultManager] removeItemAtPath:path error:NULL];
    }
    NSLog(@"Destroyed all Liquid cache files");
    return status;
}

+ (BOOL)fileExists:(NSString *)fileName {
    NSFileManager *fm = [NSFileManager defaultManager];
    return [fm fileExistsAtPath:fileName];
}

+ (BOOL)deleteFileIfExists:(NSString *)fileName error:(NSError **)err {
    NSFileManager *fm = [NSFileManager defaultManager];
    if ([FileStorage fileExists:fileName]) {
        return [fm removeItemAtPath:fileName error:err];
    }
    return NO;
}

+ (NSString *)phrontDirectory {
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0];
    return [documentsDirectory stringByAppendingPathComponent:kDirectory];
}

+ (NSArray *)filesInDirectory:(NSString *)directoryPath {
    NSFileManager *fileManager = [[NSFileManager alloc] init];
    NSArray *files = [fileManager contentsOfDirectoryAtPath:directoryPath error:nil];
    return files;
}

#pragma mark - File paths

+ (NSString*)filePathWithExtension:(NSString *)extesion forToken:(NSString *)apiToken {
    NSString *phrontDirectory = [FileStorage phrontDirectory];
    NSError *error;
    if (![[NSFileManager defaultManager] fileExistsAtPath:phrontDirectory]) {
        [[NSFileManager defaultManager] createDirectoryAtPath:phrontDirectory withIntermediateDirectories:NO attributes:nil error:&error];
    }
    NSString *md5apiToken = [NSString md5ofString:apiToken];
    NSString *liquidFile = [phrontDirectory stringByAppendingPathComponent:[NSString stringWithFormat:@"%@.%@", md5apiToken, extesion]];
    NSLog(@"ile location %@",liquidFile);
    return liquidFile;
}

+ (NSString*)filePathForAllTokensWithExtension:(NSString *)extesion {
    return [[self class] filePathWithExtension:extesion forToken:@"all_tokens"];
}

@end
