#import "AutoCompleteCache.h"
#import "YammerAppDelegate.h"
#import "ImageCache.h"
#import "LocalStorage.h"

@implementation AutoCompleteCache


+ (NSString*)filename:(NSString*)prefix {
	YammerAppDelegate *yammer = (YammerAppDelegate *)[[UIApplication sharedApplication] delegate];

	return [NSString stringWithFormat:@"%@/%@_%d", 
                    AUTOCOMPLTE,
										[yammer.network_id description],
										[prefix hash]];	
}

+ (void)save:(NSString*)prefix data:(NSString*)data {
  
	NSString* directory = [NSString stringWithFormat:@"%@%@", 
										[LocalStorage localPath], 
										AUTOCOMPLTE];
	
	[ImageCache deleteOldestFile:directory];
	[LocalStorage saveFile:[AutoCompleteCache filename:prefix] data:data];
	
}

@end
