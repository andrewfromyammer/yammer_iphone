#import "ImageCache.h"
#import "LocalStorage.h"
#import "OAuthGateway.h"

@implementation ImageCache

+ (NSData*)getOrLoadImage:(NSDictionary*)attachment key:(NSString*)key path:(NSString*)path {
  NSString* filename = [NSString stringWithFormat:@"%@%@/%@", [LocalStorage localPath], path, [attachment objectForKey:@"id"]];
  
  if ([[NSFileManager defaultManager] fileExistsAtPath:filename]) {
    return [[NSFileManager defaultManager] contentsAtPath:filename];    
  }
  
  NSData* data = [OAuthGateway httpDataGet:[[attachment objectForKey:@"image"] objectForKey:key]];
  
  if (data == nil)
    return nil;
  if ([data length] == 0)
    return nil;
  
  [ImageCache deleteOldestFile:[NSString stringWithFormat:@"%@%@", [LocalStorage localPath], path]];
  [[NSFileManager defaultManager] createFileAtPath:filename contents:data attributes:nil];
  return data;
}

+ (void)deleteOldestFile:(NSString *)path {
  NSFileManager *fileManager = [NSFileManager defaultManager];
  NSArray *list = [fileManager directoryContentsAtPath:path];
  NSMutableDictionary *hash = [NSMutableDictionary dictionary];
  if ([list count] > 500) {
    int i =0;
    for (i=0; i<[list count]; i++) {
      NSString *file = [list objectAtIndex:i];
      
      NSDictionary *fileAttributes = [fileManager fileAttributesAtPath:
                                      [path stringByAppendingPathComponent:file] 
                                                          traverseLink:YES];
      [hash setObject:file forKey:[NSNumber numberWithDouble: [[fileAttributes objectForKey:NSFileModificationDate] timeIntervalSince1970]]];
    }
    NSError *error;
    NSArray *sortedArray = [[hash allKeys] sortedArrayUsingSelector:@selector(compare:)];
    [fileManager removeItemAtPath:[path stringByAppendingPathComponent:[hash objectForKey:[sortedArray objectAtIndex:0]]]
                            error:&error];
  }  
}

@end
