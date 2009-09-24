@interface OAuthCustom : NSObject { }

+ (NSString*)theKey;
+ (NSString*)secret;
+ (NSString*)devServer;
+ (NSString*)devNetworks;
+ (BOOL)callbackTokenInURL;

@end
