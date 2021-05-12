//
//  YKFileManager.h
//  ComponentDemo
//
//  Created by Kevin on 2021/5/12.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface YKFileManager : NSObject

#pragma mark - 获取沙盒目录
/// 根目录路径
+ (NSString *)homeDirectory;
/// Documents目录路径:用于存储用户数据,可通过配置实现iTunes共享文件,并且可被iTunes备份。
+ (NSString *)documentsDirectory;
/// Library目录路径:苹果不建议在该目录下保存任何用户相关数据，而是保存APP运行需要的修改数据;默认有Caches、Preferences两个子目录。
+ (NSString *)libraryDirectory;
/// Libarary/Preferences目录路径:用户偏好存储目录，在使用NSUserDefaults或者CFPreferences接口保存的数据保存在该目录下，编程人员不需要对该目录进行管理。在iTunes和iCloud备份时会备份该目录。
+ (NSString *)preferencesDirectory;
/// Libarary/Caches目录路径:建议保存数据缓存使用。在用户的磁盘空间已经使用完毕时有可能删除该目录下的文件，在APP使用期间不会删除，APP没有运行时系统有可能进行删除。需要持久化的数据建议不要保存在该目录下，以免系统强制删除。
+ (NSString *)cachesDirectory;
/// temporary目录路径:苹果建议该目录用来保存临时使用的数据，编程人员应该在数据长时间内不使用时主动删除该目录下的文件，在APP没有运行期间，系统可能删除该目录下的文件。在iTunes和iCloud备份时不会备份该目录。
+ (NSString *)temporaryDirectory;

#pragma mark - 创建文件(夹)
// 创建文件夹(错误信息error)
+ (BOOL)createDirectoryAtPath:(NSString *)path error:(NSError **)error;
// 创建文件(错误信息error)
+ (BOOL)createFileAtPath:(NSString *)path error:(NSError **)error;
// 创建文件，是否覆盖(错误信息error)
+ (BOOL)createFileAtPath:(NSString *)path overwrite:(BOOL)overwrite error:(NSError **)error;
// 创建文件，写入文件内容(错误信息error),此方法会讲path后缀作为文件名存储
+ (BOOL)createFileAtPath:(NSString *)path content:(nullable NSObject *)content error:(NSError **)error;
// 创建文件，写入文件内容，是否覆盖(错误信息error)
+ (BOOL)createFileAtPath:(NSString *)path content:(nullable NSObject *)content overwrite:(BOOL)overwrite error:(NSError **)error;
// 获取创建文件时间(错误信息error)
+ (NSDate *)creationDateOfItemAtPath:(NSString *)path error:(NSError **)error;
// 获取文件修改时间(错误信息error)
+ (NSDate *)modificationDateOfItemAtPath:(NSString *)path error:(NSError **)error;

#pragma mark - 删除文件(夹)
// 删除文件(错误信息error)
+ (BOOL)removeItemAtPath:(NSString *)path error:(NSError **)error;
// 清空Caches文件夹
+ (BOOL)clearCachesDirectory;
// 清空tmp文件夹
+ (BOOL)clearTmpDirectory;

#pragma mark - 复制文件(夹)
// 复制文件(错误信息error)
+ (BOOL)copyItemAtPath:(NSString *)path toPath:(NSString *)toPath error:(NSError **)error;
// 复制文件，是否覆盖(错误信息error)
+ (BOOL)copyItemAtPath:(NSString *)path toPath:(NSString *)toPath overwrite:(BOOL)overwrite error:(NSError **)error;

#pragma mark - 移动文件(夹)
// 移动文件(错误信息error)
+ (BOOL)moveItemAtPath:(NSString *)path toPath:(NSString *)toPath error:(NSError **)error;
// 移动文件，是否覆盖(错误信息error)
+ (BOOL)moveItemAtPath:(NSString *)path toPath:(NSString *)toPath overwrite:(BOOL)overwrite error:(NSError **)error;

#pragma mark - 写入文件内容
// 写入文件内容
+ (BOOL)writeFileAtPath:(NSString *)path content:(NSObject *)content;
// 写入文件内容(错误信息error)
+ (BOOL)writeFileAtPath:(NSString *)path content:(NSObject *)content error:(NSError **)error;

#pragma mark - 根据URL获取文件名
// 根据文件路径获取文件名称，是否需要后缀
+ (NSString *)fileNameAtPath:(NSString *)path suffix:(BOOL)suffix;
// 获取文件所在的文件夹路径
+ (NSString *)directoryAtPath:(NSString *)path;
// 根据文件路径获取文件扩展类型
+ (NSString *)suffixAtPath:(NSString *)path;

#pragma mark - 判断文件(夹)是否存在
// 判断文件路径是否存在
+ (BOOL)isExistsAtPath:(NSString *)path;
// 判断路径是否为空,判空条件是文件大小为0，或者是文件夹下没有子文件(错误信息error)
+ (BOOL)isEmptyItemAtPath:(NSString *)path error:(NSError **)error;
// 判断目录是否是文件夹(错误信息error)
+ (BOOL)isDirectoryAtPath:(NSString *)path error:(NSError **)error;
// 判断目录是否是文件(错误信息error)
+ (BOOL)isFileAtPath:(NSString *)path error:(NSError **)error;
// 判断目录是否可以执行
+ (BOOL)isExecutableItemAtPath:(NSString *)path;
// 判断目录是否可读
+ (BOOL)isReadableItemAtPath:(NSString *)path;
// 判断目录是否可写
+ (BOOL)isWritableItemAtPath:(NSString *)path;

#pragma mark - 获取文件(夹)大小
// 获取目录大小(错误信息error)
+ (NSNumber *)sizeOfItemAtPath:(NSString *)path error:(NSError **)error;
// 获取文件大小(错误信息error)
+ (NSNumber *)sizeOfFileAtPath:(NSString *)path error:(NSError **)error;
// 获取文件夹大小(错误信息error)
+ (NSNumber *)sizeOfDirectoryAtPath:(NSString *)path error:(NSError **)error;

// 获取目录大小，返回格式化后的数值(错误信息error)
+ (NSString *)sizeFormattedOfItemAtPath:(NSString *)path error:(NSError **)error;
// 获取文件大小，返回格式化后的数值(错误信息error)
+ (NSString *)sizeFormattedOfFileAtPath:(NSString *)path error:(NSError **)error;
// 获取文件夹大小，返回格式化后的数值(错误信息error)
+ (NSString *)sizeFormattedOfDirectoryAtPath:(NSString *)path error:(NSError **)error;

#pragma mark - 获取文件属性
// 根据key获取文件某个属性(错误信息error)
+ (id)attributeOfItemAtPath:(NSString *)path forKey:(NSString *)key error:(NSError **)error;
// 获取文件属性集合(错误信息error)
+ (NSDictionary *)attributesOfItemAtPath:(NSString *)path error:(NSError **)error;

#pragma mark - 遍历文件夹
/**
 文件遍历
 @param path 目录绝对路径
 @param deep 是否深遍历 (1. 浅遍历：返回当前目录下的所有文件和文件夹；
                       2. 深遍历：返回当前目录下及子目录下的所有文件和文件夹)
 */
+ (NSArray *)listFilesInDirectoryAtPath:(NSString *)path deep:(BOOL)deep;
// 遍历沙盒主目录
+ (NSArray *)listFilesInHomeDirectoryByDeep:(BOOL)deep;
// 遍历Documents目录
+ (NSArray *)listFilesInDocumentDirectoryByDeep:(BOOL)deep;
// 遍历Library目录
+ (NSArray *)listFilesInLibraryDirectoryByDeep:(BOOL)deep;
// 遍历Caches目录
+ (NSArray *)listFilesInCachesDirectoryByDeep:(BOOL)deep;
// 遍历tmp目录
+ (NSArray *)listFilesInTmpDirectoryByDeep:(BOOL)deep;

@end

NS_ASSUME_NONNULL_END
