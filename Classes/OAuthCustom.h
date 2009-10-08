@interface OAuthCustom : NSObject { }

+ (NSString*)theKey;
+ (NSString*)secret;
+ (NSString*)baseURL;
+ (NSString*)devServer;
+ (NSString*)devNetworks;
+ (BOOL)callbackTokenInURL;

@end
