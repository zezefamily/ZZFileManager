//
//  ZZFileManager.h
//  TestDemo
//
//  Created by wenmei on 2020/5/30.
//  Copyright © 2020 wenmei. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface ZZFileManager : NSObject

+ (id)defalutFileManager;

#pragma mark - 日志信息
/*
 操作日志
 
 @param enable      是否禁止日志输出
 @param object      日志输出的对象
 */
- (void)enableLog:(BOOL)enable;

+ (void)DYLog:(id)object;

#pragma mark - 系统目录

/*
 获取对应的系统目录
 */

//absoulate directory

+ (NSString *)documentDirPath;

+ (NSString *)cachesDirPath;

+ (NSString *)mainBundleDirPath;

+ (NSString *)libraryDirPath;

+ (NSString *)applicationSupportDirPath;

+ (NSString *)temporaryDirPath;

// relative  directory

+ (NSString *)documentDirPathWithPath:(NSString *)path;

+ (NSString *)cachesDirPathWithPath:(NSString *)path;

+ (NSString *)mainBundleDirPathWithPath:(NSString *)path;

+ (NSString *)libraryDirPathWithPath:(NSString *)path;

+ (NSString *)applicationSupportDirPathWithPath:(NSString *)path;

+ (NSString *)temporaryDirPathWithPath:(NSString *)path;

+(NSString *)pathForPlistNamed:(NSString *)name;

#pragma mark - 创建目录
/*
 根据目录路径创建文件目录
 
 @param path                        目录路径
 @param attributes                  目录属性
 @param IntermediateDirectories     (NO:要创建的目录不能存在，YES：不管目录是否存在，仍创建）
 @param error                       错误信息
 @return 是否创建成功
 */

+ (BOOL)createDirectoryWithDirPath:(NSString *)path;

+ (BOOL)createDirectoryWithDirPath:(NSString *)path attributes:(NSDictionary*)attributes;

+ (BOOL)createDirectoryWithDirPath:(NSString *)path attributes:(NSDictionary*)attributes error:(NSError **)error;

+ (BOOL)createDirectoryWithDirPath:(NSString *)path withIntermediateDirectories:(BOOL)IntermediateDirectories attributes:(NSDictionary*)attributes error:(NSError **)error;

/*
 根据文件路径 创建目录
 @param path        文件路径
 @param error       错误信息
 @return            返回创建结果
 */

+(BOOL)createDirectoriesForFileWithPath:(NSString *)path;

+(BOOL)createDirectoriesForFileWithPath:(NSString *)path error:(NSError **)error;

#pragma mark - 创建文件
/*
 创建文件
 
 @param path                需要创建的文件路径
 @param content             创建文件时 初始化写入的内容
 @param overwrite           已经存在文件，重写文件内容
 @param attributes          设置文件属性
 @param error               错误信息
 @return 返回创建的 文件路径
 */

+ (BOOL)createFileWithPath:(NSString *)path;

+ (BOOL)createFileWithPath:(NSString *)path content:(id)content;

+ (BOOL)createFileWithPath:(NSString *)path content:(id)content overwrite:(BOOL)overwrite;

+ (BOOL)createFileWithPath:(NSString *)path content:(id)content overwrite:(BOOL)overwrite attributes:(NSDictionary*)attributes;

+ (BOOL)createFileWithPath:(NSString *)path content:(id)content overwrite:(BOOL)overwrite attributes:(NSDictionary *)attributes error:(NSError **)error;

#pragma mark - 文件属性
/*
 @param path        文件路径
 @param error       错误信息
 @param key         对应的文件某一属性（大小、类型等）
 常用文件属性：
 NSFileType                  文件类型
 NSFileCreationDate          文件创建日期
 NSFileModificationDate      文件修改时间
 NSFileSize                  文件大小
 
 @return            返回文件属性字典，或者对应某一属性的值
 
 */

+ (NSDictionary *)attributesOfFileWithPath:(NSString *)path;

+ (NSDictionary *)attributesOfFileWithPath:(NSString *)path error:(NSError **)error;

+ (id)attributeOfFileWithPath:(NSString *)path forKey:(NSString *)key;

+ (id)attributeOfFileWithPath:(NSString *)path forKey:(NSString *)key error:(NSError **)error;


#pragma mark - 获取文件列表

/*
 @param path            目录路径
 @param deep            是否递归遍历所有子目录
 @param extension       根据文件扩展名匹配
 @param suffix          根据 后缀 进行匹配
 @param prefix          根据 前缀 进行匹配
 
 @return                返回搜寻的 文件路径列表
 
 */

+ (NSArray *)filesInDirectoryWithPath:(NSString *)path;

+ (NSArray *)filesInDirectoryWithPath:(NSString *)path deep:(BOOL)deep;

+ (NSArray *)filesInDirectoryWithPath:(NSString *)path withExtension:(NSString *)extension;

+ (NSArray *)filesInDirectoryWithPath:(NSString *)path withExtension:(NSString *)extension deep:(BOOL)deep;

+ (NSArray *)filesInDirectoryWithPath:(NSString *)path withSuffix:(NSString *)suffix;

+ (NSArray *)filesInDirectoryWithPath:(NSString *)path withSuffix:(NSString *)suffix deep:(BOOL)deep;

+ (NSArray *)filesInDirectoryWithPath:(NSString *)path withPrefix:(NSString *)prefix;

+ (NSArray *)filesInDirectoryWithPath:(NSString *)path withPrefix:(NSString *)prefix deep:(BOOL)deep;


#pragma mark - 删除文件/目录
/*
 删除某目录下符合条件的文件列表
 
 @param path        目录路径
 @param error       错误信息
 @param extension   文件扩展名
 @param prefix      前缀
 @param suffix      后缀
 
 @return  返回删除结果
 
 */

+ (BOOL)removeFilesInDirectoryWithPath:(NSString *)path;

+ (BOOL)removeFilesInDirectoryWithPath:(NSString *)path error:(NSError **)error;

+ (BOOL)removeFilesInDirectoryWithPath:(NSString *)path extension:(NSString *)extension;

+ (BOOL)removeFilesInDirectoryWithPath:(NSString *)path extension:(NSString *)extension error:(NSError **)error;

+ (BOOL)removeFilesInDirectoryWithPath:(NSString *)path prefix:(NSString *)prefix;

+ (BOOL)removeFilesInDirectoryWithPath:(NSString *)path prefix:(NSString *)prefix error:(NSError **)error;

+ (BOOL)removeFilesInDirectoryWithPath:(NSString *)path suffix:(NSString *)suffix;

+ (BOOL)removeFilesInDirectoryWithPath:(NSString *)path suffix:(NSString *)suffix  error:(NSError **)error;

/*
 批量删除文件
 
 @param paths       文件路径数组
 @param error       错误信息
 
 @return            返回删除结果
 
 */
+ (BOOL)removeFilesWithPaths:(NSArray *)paths;

+ (BOOL)removeFilesWithPaths:(NSArray *)paths error:(NSError **)error;

/*
 删除文件
 @param path    文件路径
 @param error   错误信息
 
 @return  删除结果
 */

+ (BOOL)removeFileWithPath:(NSString *)path;

+ (BOOL)removeFileWithPath:(NSString *)path error:(NSError **)error;

+ (BOOL)removeDirectoryWithPath:(NSString *)path;

+ (BOOL)removeDirectoryWithPath:(NSString *)path error:(NSError **)error;


#pragma mark - 复制文件
/*
 复制文件
 @param path        原始路径
 @param toPath      目标路径
 @param overwrite   是否覆盖
 @param error       错误信息
 
 @return 返回拷贝结果
 
 */

+ (BOOL)copyFileFromPath:(NSString *)path toPath:(NSString *)toPath;

+ (BOOL)copyFileFromPath:(NSString *)path toPath:(NSString *)toPath error:(NSError **)error;

+ (BOOL)copyFileFromPath:(NSString *)path toPath:(NSString *)toPath overwrite:(BOOL)overwrite;

+ (BOOL)copyFileFromPath:(NSString *)path toPath:(NSString *)toPath overwrite:(BOOL)overwrite error:(NSError **)error;


#pragma mark - 移动文件
/*
 移动文件
 
 @param path        原始路径
 @param toPath      目的路径
 @param overwrite   是否覆盖
 @param error       错误信息
 
 @return   返回操作结果
 */
+ (BOOL)moveFileFromPath:(NSString *)path toPath:(NSString *)toPath;

+ (BOOL)moveFileFromPath:(NSString *)path toPath:(NSString *)toPath overwrite:(BOOL)overwrite;

+ (BOOL)moveFileFromPath:(NSString *)path toPath:(NSString *)toPath error:(NSError **)error;

+ (BOOL)moveFileFromPath:(NSString *)path toPath:(NSString *)toPath overwrite:(BOOL)overwrite error:(NSError **)error;


#pragma mark - 文件写入
/*
 往文件写入内容
 
 @param content     需要写入的内容
 @param filePath    需要写入的文件路径
 
 @return            返回写入结果
 */

//覆盖
+ (BOOL)writeContent:(NSObject *)content path:(NSString *)path;

+ (BOOL)writeContent:(NSObject *)content path:(NSString *)path error:(NSError **)error;

//从文件尾部添加

+ (void)writeContentToEnd:(NSData *)content path:(NSString *)path;

+ (void)writeContentToEnd:(NSData *)content path:(NSString *)path error:(NSError **)error;

//从头部插入内容
+ (void)writeContentFromStart:(NSData *)content path:(NSString *)path;

+ (void)writeContentFromStart:(NSData *)content path:(NSString *)path error:(NSError **)error;

#pragma mark - 文件读取
/*
 读取文件内容
 
 @param path        需要读取的文件
 @param error       错误信息
 @return            返回对应类型的数据
 */
+ (NSString *)readContentWithPath:(NSString *)path;

+ (NSString *)readContentWithPath:(NSString *)path error:(NSError **)error;

+ (NSString *)readContentAsStringWithPath:(NSString *)path;

+ (NSString *)readContentAsStringWithPath:(NSString *)path error:(NSError **)error;

+ (NSArray *)readContentAsNSArrayWithPath:(NSString *)path;

+ (NSMutableArray *)readContentAsNSMutableArrayWithPath:(NSString *)path;

+ (NSDictionary *)readContentAsNSDictionaryWithPath:(NSString *)path;

+ (NSMutableDictionary *)readContentAsNSMutableDictionaryWithPath:(NSString *)path;

+ (NSData *)readContentAsNSDataWithPath:(NSString *)path;

+ (NSData *)readContentAsNSDataWithPath:(NSString *)path error:(NSError **)error;

+ (NSMutableData *)readContentAsNSMutableDataWithPath:(NSString *)path;

+ (NSMutableData *)readContentAsNSMutableDataWithPath:(NSString *)path error:(NSError **)error;

+ (NSObject *)readContentAsCustomModelWithPath:(NSString *)path;

+(NSJSONSerialization *)readContentAsJSONWithPath:(NSString *)path;

+(NSJSONSerialization *)readContentAsJSONWithPath:(NSString *)path error:(NSError **)error;


#pragma mark - 文件大小
/*
 计算文件大小
 
 @param path        文件路径
 @param error       错误信息
 @return            返回对应文件的大小
 
 
 */

+ (NSNumber *)sizeForFileWithPath:(NSString *)path;

+ (NSNumber *)sizeForFileWithPath:(NSString *)path error:(NSError **)error;


#pragma mark - 目录大小
/*
 计算目录大小
 
 @param path        目录路径
 @param error       错误信息
 
 @return            返回目录大小
 
 */

+ (NSNumber *)sizeForDirectoryWithPath:(NSString *)path;

+ (NSNumber *)sizeForDirectoryWithPath:(NSString *)path error:(NSError **)error;

#pragma mark  - 格式化文件大小
/*
 计算文件大小（格式化（带单位））
 
 @param size        文件大小（格式化前）
 @param path        文件路径
 @param error       错误信息
 @return            返回格式化后的文件大小
 
 */

+ (NSString *)sizeFormatted:(NSNumber *)size;

+ (NSString *)sizeFormattedForDirectoryWithPath:(NSString *)path;

+ (NSString *)sizeFormattedForDirectoryWithPath:(NSString *)path error:(NSError **)error;

+ (NSString *)sizeFormattedForFileWithPath:(NSString *)path;

+ (NSString *)sizeFormattedForFileWithPath:(NSString *)path error:(NSError **)error;


#pragma mark - 修改文件名称
/*
 
 修改文件名称
 @param path        文件路径
 @param name        新的文件名称
 @param error       错误信息
 
 @return            返回操作结果
 */

+(BOOL)renameFileWithPath:(NSString *)path withName:(NSString *)name;

+(BOOL)renameFileWithPath:(NSString *)path withName:(NSString *)name error:(NSError **)error;


#pragma mark - 辅助方法

/*
 判断文件是否存在
 
 @param path            文件路径
 @param isDirectory     是否是目录
 @return 返回文件是否存在
 */
+ (BOOL)fileExistsAtPath:(NSString *)path;

+ (BOOL)fileExistsAtPath:(NSString *)path isDirectory:(BOOL *)isDirectory;

@end

NS_ASSUME_NONNULL_END
