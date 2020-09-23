#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface LYH5PayView : UIView

/**
 
 1、调用支付之前，需要到微信和支付宝开发者中心配置授权域名(必须的)，授权一级域名，一级域名下面的子域名可以得到和一级域名相同的权限；
 2、到Target -> Info -> URL Types添加URL Schcemes 为授权域名；
 3、在plist文件中的LSApplicationQueriesSchemes下设置白名单wechat和alipay；
 4、不需要导入微信和支付宝SDK，也不需要到微信和支付宝开发者中心创建应用，大大缩短开发周期，和减少App包的大小；
 5、LYH5PayView初始化时需要传入授权域名，否则无法正常打开微信或者支付宝的付款页面；
 6、根据后台返回参数类型调用参数url或html。
 7、调用示例：
 
 LYH5PayView *pay = [[LYH5PayView alloc]initWithDomain:@"www.egc56.com"];
 [self.view addSubview:pay];
 pay.url = @"";
 pay.html = @"";
 
 */

/// 初始化方法
/// @param domainName 支付授权域名
-(instancetype)initWithDomain:(NSString *)domainName;

/// webView加载的url地址
@property (nonatomic, copy) NSString *url;

/// webView加载的html代码
@property (nonatomic, copy) NSString *html;

@end

NS_ASSUME_NONNULL_END
