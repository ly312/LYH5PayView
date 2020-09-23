#import "LYH5PayView.h"
#import <WebKit/WebKit.h>

@interface LYH5PayView ()<WKUIDelegate,WKNavigationDelegate>

//域名
@property (nonatomic, copy) NSString *domainName;

//加载支付网页
@property (nonatomic, strong) WKWebView *wkWView;

@end

@implementation LYH5PayView

-(instancetype)initWithDomain:(NSString *)domainName{
    
    self = [super init];
    if (self) {
        _domainName = domainName;
        [self addSubview:self.wkWView];
    }
    return self;
    
}

#pragma mark - WKWebViewLazy
-(WKWebView *)wkWView{
    if (!_wkWView) {
        WKWebViewConfiguration *config = [[WKWebViewConfiguration alloc]init];
        CGRect frame = CGRectMake(0, 0, 1, 1);
        _wkWView = [[WKWebView alloc]initWithFrame:frame configuration:config];
        _wkWView.UIDelegate = self;
        _wkWView.navigationDelegate = self;
        _wkWView.allowsBackForwardNavigationGestures = YES;
        _wkWView.backgroundColor = UIColor.clearColor;
    }
    return _wkWView;
}

#pragma mark - WKWebViewDelegate
-(void)webView:(WKWebView *)webView decidePolicyForNavigationAction:(WKNavigationAction *)navigationAction decisionHandler:(void (^)(WKNavigationActionPolicy))decisionHandler{
    
    NSURL *url = navigationAction.request.URL;
    NSString *urlString = url.absoluteString;
    NSString *scheme = url.scheme;
    //微信支付
    if ([urlString containsString:@"https://wx.tenpay.com/"] || [scheme isEqualToString:@"weixin"]) {
        
        if ([scheme isEqualToString:@"weixin"]) {
            [self applicationOpenUrl:url];
        }
        
        NSDictionary *headers = [navigationAction.request allHTTPHeaderFields];
        NSString *refererString = [headers objectForKey:@"Referer"];
        if (refererString.length == 0) {
            
            dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
                dispatch_async(dispatch_get_main_queue(), ^{
                    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url cachePolicy:NSURLRequestUseProtocolCachePolicy timeoutInterval:60.0];
                    //设置授权域名
                    [request setValue:[NSString stringWithFormat:@"%@://",self.domainName] forHTTPHeaderField:@"Referer"];
                    [webView loadRequest:request];
                });
            });
            
        }
        decisionHandler(WKNavigationActionPolicyAllow);
        
    }
    //支付宝支付
    else if ([scheme isEqualToString:@"alipay"]) {
        
        //1、以？号来切割字符串
        NSArray *paramArray = [urlString componentsSeparatedByString:@"?"];
        NSString *firstObject = paramArray.firstObject;
        NSString *lastObject = paramArray.lastObject;
        //2、将截取以后的字符串编码处理
        NSMutableString *decodeString = [NSMutableString stringWithString:[self decoderString:lastObject]];
        //3、替换里面的默认Scheme为自己的Scheme
        NSString *replaceString = [decodeString stringByReplacingOccurrencesOfString:@"alipays" withString:self.domainName];
        //4、把处理后的字符串和？之前的数据拼接，就得到了最终的字符串
        NSString *resultString = [NSString stringWithFormat:@"%@?%@",firstObject, [self encoderString:replaceString]];
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            
            //判断是否安装支付宝APP，安装则跳转，否则下载支付宝
            if ([[UIApplication sharedApplication] canOpenURL:[NSURL URLWithString:resultString]]) {
                [self applicationOpenUrl:[NSURL URLWithString:resultString]];
            } else {
                //未安装支付宝, 自行处理
                NSString *alipayUrl = @"itms://itunes.apple.com/cn/app/支付宝-让生活更简单/id333206289?mt=8";
                alipayUrl = [alipayUrl stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet URLQueryAllowedCharacterSet]];
                [self applicationOpenUrl:[NSURL URLWithString:alipayUrl]];
            }
            
        });
        decisionHandler(WKNavigationActionPolicyCancel);
        
    }
    //其他
    else {
        decisionHandler(WKNavigationActionPolicyAllow);
    }
    
}

#pragma mark - 字符串编码解码
-(NSString *)encoderString:(NSString *)string{
    NSString *characters = @"?!@#$^&%*+,:;='\"`<>()[]{}/\\| ";
    NSCharacterSet *set = [[NSCharacterSet characterSetWithCharactersInString:characters] invertedSet];
    return [string stringByAddingPercentEncodingWithAllowedCharacters:set];
}

-(NSString *)decoderString:(NSString *)string{
    NSMutableString *mutString = [NSMutableString stringWithString:string];
    [mutString replaceOccurrencesOfString:@"+" withString:@"" options:NSLiteralSearch range:NSMakeRange(0, [mutString length])];
    return [mutString stringByRemovingPercentEncoding];
}

#pragma mark - App跳转
-(void)applicationOpenUrl:(NSURL *)url {
    
    UIApplication *application = [UIApplication sharedApplication];
    if([application respondsToSelector:@selector(openURL:options:completionHandler:)]) {
        [application openURL:url
                     options:@{}
           completionHandler:^(BOOL success) {
            NSLog(@"Open %@: %d",url,success);
        }];
    }
    
}

#pragma mark - 加载webView
-(void)setUrl:(NSString *)url{
    NSURLRequest *request = [NSURLRequest requestWithURL:[NSURL URLWithString:url]];
    [self.wkWView loadRequest:request];
}

-(void)setHtml:(NSString *)html{
    [self.wkWView loadHTMLString:html baseURL:nil];
}

@end
