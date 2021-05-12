//
//  YKFileManager.m
//  ComponentDemo
//
//  Created by Kevin on 2021/5/12.
//

#import "YKFileManager.h"

@implementation YKFileManager

#pragma mark - 获取沙盒目录
+ (NSString *)homeDirectory{
    return NSHomeDirectory();
}

+ (NSString *)documentsDirectory{
    return [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) firstObject];
}

+ (NSString *)libraryDirectory{
    return [NSSearchPathForDirectoriesInDomains(NSLibraryDirectory, NSUserDomainMask, YES) lastObject];;
}

+ (NSString *)preferencesDirectory{
    NSString *libraryDir = [self libraryDirectory];
    return [libraryDir stringByAppendingPathComponent:@"Preferences"];
}

+ (NSString *)cachesDirectory{
    return [NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES) firstObject];
}

+ (NSString *)temporaryDirectory{
    return NSTemporaryDirectory();
}

#pragma mark - 创建文件(夹)
+ (BOOL)createDirectoryAtPath:(NSString *)path error:(NSError * __autoreleasing *)error{
    NSFileManager *manager = [NSFileManager defaultManager];
    BOOL isSuccess = [manager createDirectoryAtPath:path withIntermediateDirectories:YES attributes:nil error:error];
    return isSuccess;
}

+ (BOOL)createFileAtPath:(NSString *)path error:(NSError * __autoreleasing *)error{
    return [self createFileAtPath:path content:nil overwrite:YES error:error];
}

+ (BOOL)createFileAtPath:(NSString *)path overwrite:(BOOL)overwrite error:(NSError * __autoreleasing *)error{
    return [self createFileAtPath:path content:nil overwrite:overwrite error:error];
}

+ (BOOL)createFileAtPath:(NSString *)path content:(nullable NSObject *)content error:(NSError *__autoreleasing *)error{
    return [self createFileAtPath:path content:content overwrite:YES error:error];
}

+ (BOOL)createFileAtPath:(NSString *)path content:(nullable NSObject *)content overwrite:(BOOL)overwrite error:(NSError *__autoreleasing *)error {
    // 如果文件夹路径不存在，那么先创建文件夹
    NSString *directoryPath = [self directoryAtPath:path];
    if (![self isExistsAtPath:directoryPath]) {
        // 创建文件夹
        if (![self createDirectoryAtPath:directoryPath error:error]) {
            return NO;
        }
    }
    // 如果文件存在，并不想覆盖，那么直接返回YES。
    if (!overwrite) {
        if ([self isExistsAtPath:path]) {
            if (content) 
                [self writeFileAtPath:path content:content error:error];
            return YES;
        }
    }
    // 创建文件
    BOOL isSuccess = [[NSFileManager defaultManager] createFileAtPath:path contents:nil attributes:nil];
    if (content) {
        [self writeFileAtPath:path content:content error:error];
    }
    return isSuccess;
}

// 获取创建文件时间(错误信息error)
+ (NSDate *)creationDateOfItemAtPath:(NSString *)path error:(NSError *__autoreleasing *)error{
    return (NSDate *)[self attributeOfItemAtPath:path forKey:NSFileCreationDate error:error];
}
// 获取文件修改时间(错误信息error)
+ (NSDate *)modificationDateOfItemAtPath:(NSString *)path error:(NSError *__autoreleasing *)error{
    return (NSDate *)[self attributeOfItemAtPath:path forKey:NSFileModificationDate error:error];
}

#pragma mark - 删除文件(夹)
+ (BOOL)removeItemAtPath:(NSString *)path error:(NSError *__autoreleasing *)error {
    return [[NSFileManager defaultManager] removeItemAtPath:path error:error];
}

+ (BOOL)clearCachesDirectory {
    NSArray *subFiles = [self listFilesInCachesDirectoryByDeep:NO];
    BOOL isSuccess = YES;
    
    for (NSString *file in subFiles) {
        NSString *absolutePath = [[self cachesDirectory] stringByAppendingPathComponent:file];
        isSuccess &= [self removeItemAtPath:absolutePath error:nil];
    }
    return isSuccess;
}

+ (BOOL)clearTmpDirectory {
    NSArray *subFiles = [self listFilesInTmpDirectoryByDeep:NO];
    BOOL isSuccess = YES;
    
    for (NSString *file in subFiles) {
        NSString *absolutePath = [[self temporaryDirectory] stringByAppendingPathComponent:file];
        isSuccess &= [self removeItemAtPath:absolutePath error:nil];
    }
    return isSuccess;
}


#pragma mark - 复制文件(夹)
+ (BOOL)copyItemAtPath:(NSString *)path toPath:(NSString *)toPath error:(NSError *__autoreleasing *)error {
    return [self copyItemAtPath:path toPath:toPath overwrite:NO error:error];
}

+ (BOOL)copyItemAtPath:(NSString *)path toPath:(NSString *)toPath overwrite:(BOOL)overwrite error:(NSError *__autoreleasing *)error {
    // 先要保证源文件路径存在，不然抛出异常
    if (![self isExistsAtPath:path]) {
        [NSException raise:@"非法的源文件路径" format:@"源文件路径%@不存在，请检查源文件路径", path];
        return NO;
    }
    NSString *toDirPath = [self directoryAtPath:toPath];
    if (![self isExistsAtPath:toDirPath]) {
        // 创建复制路径
        if (![self createDirectoryAtPath:toDirPath error:error]) {
            return NO;
        }
    }
    // 如果覆盖，那么先删掉原文件
    if (overwrite) {
        if ([self isExistsAtPath:toPath]) {
            [self removeItemAtPath:toPath error:error];
        }
    }
    // 复制文件
    BOOL isSuccess = [[NSFileManager defaultManager] copyItemAtPath:path toPath:toPath error:error];
    
    return isSuccess;
}

#pragma mark - 移动文件(夹)
+ (BOOL)moveItemAtPath:(NSString *)path toPath:(NSString *)toPath error:(NSError *__autoreleasing *)error {
    return [self moveItemAtPath:path toPath:toPath overwrite:NO error:error];
}

+ (BOOL)moveItemAtPath:(NSString *)path toPath:(NSString *)toPath overwrite:(BOOL)overwrite error:(NSError *__autoreleasing *)error {
    // 先要保证源文件路径存在，不然抛出异常
    if (![self isExistsAtPath:path]) {
        [NSException raise:@"非法的源文件路径" format:@"源文件路径%@不存在，请检查源文件路径", path];
        return NO;
    }
    NSString *toDirPath = [self directoryAtPath:toPath];
    if (![self isExistsAtPath:toDirPath]) {
        // 创建移动路径
        if (![self createDirectoryAtPath:toDirPath error:error]) {
            return NO;
        }
    }
    // 如果覆盖，那么先删掉原文件
    if ([self isExistsAtPath:toPath]) {
        if (overwrite) {
            [self removeItemAtPath:toPath error:error];
        }else {
            [self removeItemAtPath:path error:error];
            return YES;
        }
    }
    
    // 移动文件
    BOOL isSuccess = [[NSFileManager defaultManager] moveItemAtPath:path toPath:toPath error:error];
    
    return isSuccess;
}

#pragma mark - 写入文件内容
+ (BOOL)writeFileAtPath:(NSString *)path content:(NSObject *)content {
    return [self writeFileAtPath:path content:content error:nil];
}

+ (BOOL)writeFileAtPath:(NSString *)path content:(NSObject *)content error:(NSError *__autoreleasing *)error {
    if (!content) {
        [NSException raise:@"非法的文件内容" format:@"文件内容不能为nil"];
        return NO;
    }
    if ([self isExistsAtPath:path]) {
        if ([content isKindOfClass:[NSMutableArray class]]) {
            [(NSMutableArray *)content writeToFile:path atomically:YES];
        }else if ([content isKindOfClass:[NSArray class]]) {
            [(NSArray *)content writeToFile:path atomically:YES];
        }else if ([content isKindOfClass:[NSMutableData class]]) {
            [(NSMutableData *)content writeToFile:path atomically:YES];
        }else if ([content isKindOfClass:[NSData class]]) {
            [(NSData *)content writeToFile:path atomically:YES];
        }else if ([content isKindOfClass:[NSMutableDictionary class]]) {
            [(NSMutableDictionary *)content writeToFile:path atomically:YES];
        }else if ([content isKindOfClass:[NSDictionary class]]) {
            [(NSDictionary *)content writeToFile:path atomically:YES];
        }else if ([content isKindOfClass:[NSJSONSerialization class]]) {
            [(NSDictionary *)content writeToFile:path atomically:YES];
        }else if ([content isKindOfClass:[NSMutableString class]]) {
            [[((NSString *)content) dataUsingEncoding:NSUTF8StringEncoding] writeToFile:path atomically:YES];
        }else if ([content isKindOfClass:[NSString class]]) {
            [[((NSString *)content) dataUsingEncoding:NSUTF8StringEncoding] writeToFile:path atomically:YES];
        }else if ([content isKindOfClass:[UIImage class]]) {
            [UIImagePNGRepresentation((UIImage *)content) writeToFile:path atomically:YES];
        }else if ([content conformsToProtocol:@protocol(NSCoding)]) {
            [NSKeyedArchiver archiveRootObject:content toFile:path];
        }else {
            [NSException raise:@"非法的文件内容" format:@"文件类型%@异常，无法被处理。", NSStringFromClass([content class])];
            
            return NO;
        }
    }else {
        return NO;
    }
    return YES;
}


#pragma mark - 根据URL获取文件名
+ (NSString *)fileNameAtPath:(NSString *)path suffix:(BOOL)suffix {
    NSString *fileName = [path lastPathComponent];
    if (!suffix) {
        fileName = [fileName stringByDeletingPathExtension];
    }
    return fileName;
}

+ (NSString *)directoryAtPath:(NSString *)path {
    return [path stringByDeletingLastPathComponent];
}

+ (NSString *)suffixAtPath:(NSString *)path {
    return [path pathExtension];
}

#pragma mark - 判断文件(夹)是否存在
+ (BOOL)isExistsAtPath:(NSString *)path {
    return [[NSFileManager defaultManager] fileExistsAtPath:path];
}

+ (BOOL)isEmptyItemAtPath:(NSString *)path error:(NSError *__autoreleasing *)error {
    return ([self isFileAtPath:path error:error] &&
            [[self sizeOfItemAtPath:path error:error] intValue] == 0) ||
    ([self isDirectoryAtPath:path error:error] &&
     [[self listFilesInDirectoryAtPath:path deep:NO] count] == 0);
}

+ (BOOL)isDirectoryAtPath:(NSString *)path error:(NSError *__autoreleasing *)error {
    return ([self attributeOfItemAtPath:path forKey:NSFileType error:error] == NSFileTypeDirectory);
}

+ (BOOL)isFileAtPath:(NSString *)path error:(NSError *__autoreleasing *)error {
    return ([self attributeOfItemAtPath:path forKey:NSFileType error:error] == NSFileTypeRegular);
}

+ (BOOL)isExecutableItemAtPath:(NSString *)path {
    return [[NSFileManager defaultManager] isExecutableFileAtPath:path];
}

+ (BOOL)isReadableItemAtPath:(NSString *)path {
    return [[NSFileManager defaultManager] isReadableFileAtPath:path];
}
+ (BOOL)isWritableItemAtPath:(NSString *)path {
    return [[NSFileManager defaultManager] isWritableFileAtPath:path];
}

#pragma mark - 获取文件(夹)大小
+ (NSNumber *)sizeOfItemAtPath:(NSString *)path error:(NSError *__autoreleasing *)error {
    return (NSNumber *)[self attributeOfItemAtPath:path forKey:NSFileSize error:error];
}

+ (NSNumber *)sizeOfFileAtPath:(NSString *)path error:(NSError *__autoreleasing *)error {
    if ([self isFileAtPath:path error:error]) {
        return [self sizeOfItemAtPath:path error:error];
    }
    return nil;
}

+ (NSNumber *)sizeOfDirectoryAtPath:(NSString *)path error:(NSError *__autoreleasing *)error {
    if ([self isDirectoryAtPath:path error:error]) {
        NSNumber *size = [self sizeOfItemAtPath:path error:error];
        double sizeValue = [size doubleValue];
        
        NSArray *subPaths = [self listFilesInDirectoryAtPath:path deep:YES];
        for (NSUInteger i = 0; i < subPaths.count; i++) {
            NSString *subPath = [subPaths objectAtIndex:i];
            NSNumber *subPathSize = [self sizeOfItemAtPath:subPath error:error];
            sizeValue += [subPathSize doubleValue];
        }
        return [NSNumber numberWithDouble:sizeValue];
    }
    return nil;
}

+ (NSString *)sizeFormattedOfItemAtPath:(NSString *)path error:(NSError *__autoreleasing *)error {
    NSNumber *size = [self sizeOfItemAtPath:path error:error];
    if (!size) {
        return [self sizeFormatted:size];
    }
    return nil;
}

+ (NSString *)sizeFormattedOfFileAtPath:(NSString *)path error:(NSError *__autoreleasing *)error {
    NSNumber *size = [self sizeOfFileAtPath:path error:error];
    if (!size) {
        return [self sizeFormatted:size];
    }
    return nil;
}

+ (NSString *)sizeFormattedOfDirectoryAtPath:(NSString *)path error:(NSError *__autoreleasing *)error {
    NSNumber *size = [self sizeOfDirectoryAtPath:path error:error];
    if (!size) {
        return [self sizeFormatted:size];
    }
    return nil;
}


#pragma mark - 获取文件属性
+ (id)attributeOfItemAtPath:(NSString *)path forKey:(NSString *)key error:(NSError *__autoreleasing *)error {
    return [[self attributesOfItemAtPath:path error:error] objectForKey:key];
}

+ (NSDictionary *)attributesOfItemAtPath:(NSString *)path error:(NSError *__autoreleasing *)error {
    return [[NSFileManager defaultManager] attributesOfItemAtPath:path error:error];
}

#pragma mark - 遍历文件夹
+ (NSArray *)listFilesInDirectoryAtPath:(NSString *)path deep:(BOOL)deep {
    NSArray *listArr;
    NSError *error;
    NSFileManager *manager = [NSFileManager defaultManager];
    if (deep) {
        // 深遍历
        NSArray *deepArr = [manager subpathsOfDirectoryAtPath:path error:&error];
        if (!error) {
            listArr = deepArr;
        }else {
            listArr = nil;
        }
    }else {
        // 浅遍历
        NSArray *shallowArr = [manager contentsOfDirectoryAtPath:path error:&error];
        if (!error) {
            listArr = shallowArr;
        }else {
            listArr = nil;
        }
    }
    return listArr;
}

+ (NSArray *)listFilesInHomeDirectoryByDeep:(BOOL)deep {
    return [self listFilesInDirectoryAtPath:[self homeDirectory] deep:deep];
}

+ (NSArray *)listFilesInLibraryDirectoryByDeep:(BOOL)deep {
    return [self listFilesInDirectoryAtPath:[self libraryDirectory] deep:deep];
}

+ (NSArray *)listFilesInDocumentDirectoryByDeep:(BOOL)deep {
    return [self listFilesInDirectoryAtPath:[self documentsDirectory] deep:deep];
}

+ (NSArray *)listFilesInTmpDirectoryByDeep:(BOOL)deep {
    return [self listFilesInDirectoryAtPath:[self temporaryDirectory] deep:deep];
}

+ (NSArray *)listFilesInCachesDirectoryByDeep:(BOOL)deep {
    return [self listFilesInDirectoryAtPath:[self cachesDirectory] deep:deep];
}

#pragma mark - private methods
+ (BOOL)isNotError:(NSError * __autoreleasing *)error {
    return ((error == nil) || ((*error) == nil));
}

+ (NSString *)sizeFormatted:(NSNumber *)size {
    double convertedValue = [size doubleValue];
    NSUInteger multiplyFactor = 0;
    
    NSArray *tokens = @[@"bytes", @"KB", @"MB", @"GB", @"TB"];
    
    while(convertedValue > 1024){
        convertedValue /= 1024;
        
        multiplyFactor++;
    }
    
    NSString *sizeFormat = ((multiplyFactor > 1) ? @"%4.2f %@" : @"%4.0f %@");
    
    return [NSString stringWithFormat:sizeFormat, convertedValue, tokens[multiplyFactor]];
}


@end
