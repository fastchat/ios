//
//  STKWebKitViewController.m
//  STKWebKitViewController
//
//  Created by Marc on 03.09.14.
//  Copyright (c) 2014 sticksen. All rights reserved.
//

#import "STKWebKitViewController.h"

@interface STKWebKitViewController ()

@property(nonatomic) NSMutableArray *viewConstraints;
@property(nonatomic) UIColor *savedNavigationbarTintColor;
@property(nonatomic) UIColor *savedToolbarTintColor;

@property(nonatomic) NSURLRequest *request;

@property (nonatomic) BOOL toolbarWasHidden;
@end

@implementation STKWebKitViewController

- (instancetype)init
{
    return [self initWithURL:nil];
}

- (instancetype)initWithAddress:(NSString *)urlString
{
    return [self initWithURL:[NSURL URLWithString:urlString]];
}

- (instancetype)initWithURL:(NSURL *)url
{
    return [self initWithURL:url userScript:nil];
}

- (instancetype)initWithURL:(NSURL *)url userScript:(WKUserScript *)script
{
    return [self initWithRequest:[NSURLRequest requestWithURL:url] userScript:script];
}

- (instancetype)initWithAddress:(NSString *)string userScript:(WKUserScript *)script
{
    return [self initWithURL:[NSURL URLWithString:string] userScript:script];
}

- (instancetype)initWithRequest:(NSURLRequest *)request
{
    return [self initWithRequest:request userScript:nil];
}

- (instancetype)initWithRequest:(NSURLRequest *)request userScript:(WKUserScript *)script
{
    if (self = [super init]) {
        NSAssert([[UIDevice currentDevice].systemVersion floatValue] >= 8.0, @"WKWebView is available since iOS8. Use UIWebView, if you´re running an older version");
        NSAssert([NSThread isMainThread], @"WebKit is not threadsafe and this function is not executed on the main thread");
        
        self.request = request;
        if (script) {
            WKUserContentController *userContentController = [[WKUserContentController alloc] init];
            [userContentController addUserScript:script];
            WKWebViewConfiguration *configuration = [[WKWebViewConfiguration alloc] init];
            configuration.userContentController = userContentController;
            _webView = [[WKWebView alloc] initWithFrame:CGRectZero configuration:configuration];
        } else {
            _webView = [[WKWebView alloc] initWithFrame:CGRectZero];
        }
        _webView.navigationDelegate = self;
        [self.view addSubview:_webView];
    }
    return self;

}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    NSAssert(self.navigationController, @"STKWebKitViewController needs to be contained in a UINavigationController. If you are presenting STKWebKitViewController modally, use STKModalWebKitViewController instead.");
    
    [self.view setNeedsUpdateConstraints];
    self.toolbarWasHidden = self.navigationController.isToolbarHidden;
    [self.navigationController setToolbarHidden:NO animated:YES];
    [self fillToolbar];
    
    self.savedNavigationbarTintColor = self.navigationController.navigationBar.barTintColor;
    self.savedToolbarTintColor = self.navigationController.toolbar.barTintColor;
    
    if (self.toolbarTintColor) {
        self.navigationController.toolbar.barTintColor = self.toolbarTintColor;
        self.navigationController.toolbar.backgroundColor = self.toolbarTintColor;
        self.navigationController.toolbar.tintColor = [UIColor whiteColor];
    }
    if (self.navigationBarTintColor) {
        self.navigationController.navigationBar.barTintColor = self.navigationBarTintColor;
    }

    [self addObserver:self forKeyPath:@"webView.title" options:NSKeyValueObservingOptionNew context:NULL];
    [self addObserver:self forKeyPath:@"webView.loading" options:NSKeyValueObservingOptionNew context:NULL];
    [self addObserver:self forKeyPath:@"webView.estimatedProgress" options:NSKeyValueObservingOptionNew context:NULL];

    if (self.request) {
        [self.webView loadRequest:self.request];
    }
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    
    self.navigationController.navigationBar.barTintColor = self.savedNavigationbarTintColor;
    [self.navigationController setToolbarHidden:self.toolbarWasHidden];
    self.navigationController.toolbar.barTintColor = self.savedToolbarTintColor;

    [self removeObserver:self forKeyPath:@"webView.title"];
    [self removeObserver:self forKeyPath:@"webView.loading"];
    [self removeObserver:self forKeyPath:@"webView.estimatedProgress"];
}

- (BOOL)prefersStatusBarHidden
{
    return self.navigationController.navigationBarHidden;
}

- (UIStatusBarAnimation)preferredStatusBarUpdateAnimation
{
    return UIStatusBarAnimationSlide;
}

- (void)fillToolbar
{
    UIBarButtonItem *backItem = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"back"] style:UIBarButtonItemStylePlain target:self action:@selector(backTapped:)];
    if (self.webView.canGoBack) {
        backItem.tintColor = nil;
    } else {
        backItem.tintColor = [UIColor lightGrayColor];
    }
    
    UIBarButtonItem *forwardItem = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"forward"] style:UIBarButtonItemStylePlain target:self action:@selector(forwardTapped:)];
    if (self.webView.canGoForward) {
        forwardItem.tintColor = nil;
    } else {
        forwardItem.tintColor = [UIColor lightGrayColor];
    }
    
    UIBarButtonItem *reloadItem;
    if (self.webView.isLoading) {
        reloadItem = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"stop"] style:UIBarButtonItemStylePlain target:self action:@selector(stopTapped:)];
    } else {
        reloadItem = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"refresh"] style:UIBarButtonItemStylePlain target:self action:@selector(reloadTapped:)];
    }
    UIBarButtonItem *shareItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAction target:self action:@selector(shareTapped:)];
    UIBarButtonItem *flexibleSpaceItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil];

    [self setToolbarItems:@[flexibleSpaceItem, backItem, flexibleSpaceItem, forwardItem, flexibleSpaceItem, reloadItem, flexibleSpaceItem, shareItem, flexibleSpaceItem] animated:NO];
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context
{
    if ([keyPath isEqualToString:@"webView.title"]) {
        self.title = change[@"new"];
    } else if ([keyPath isEqualToString:@"webView.loading"]) {
        [self fillToolbar];
    } else if ([keyPath isEqualToString:@"webView.estimatedProgress"]) {

    }
}

- (void)viewDidLayoutSubviews
{
    self.webView.frame = self.view.bounds;
}

- (void)backTapped:(UIBarButtonItem *)button
{
    [self.webView goBack];
}

- (void)forwardTapped:(UIBarButtonItem *)button
{
    [self.webView goForward];
}

- (void)reloadTapped:(UIBarButtonItem *)button
{
    [self.webView reload];
}

- (void)stopTapped:(UIBarButtonItem *)button
{
    [self.webView stopLoading];
}

- (void)shareTapped:(UIBarButtonItem *)button
{
    UIActivityViewController *controller = [[UIActivityViewController alloc] initWithActivityItems:@[self.title, self.request.URL] applicationActivities:self.applicationActivities];
    [self presentViewController:controller animated:YES completion:nil];
}

#pragma mark -

- (void)webView:(WKWebView *)webView decidePolicyForNavigationAction:(WKNavigationAction *)navigationAction decisionHandler:(void (^)(WKNavigationActionPolicy))decisionHandler
{
    if (!navigationAction.targetFrame) { //this is a 'new window action' (aka target="_blank") > open this URL externally. If we´re doing nothing here, WKWebView will also just do nothing. Maybe this will change in a later stage of the iOS 8 Beta
        NSURL *url = navigationAction.request.URL;
        UIApplication *app = [UIApplication sharedApplication];
        if ([app canOpenURL:url]) {
            [app openURL:url];
        }
    }
    decisionHandler(WKNavigationActionPolicyAllow);
}

-(void)webView:(WKWebView *)webView didFinishNavigation:(WKNavigation *)navigation
{
    [self.webView.scrollView scrollRectToVisible:CGRectMake(0, 0, 1, 1) animated:NO]; //otherwise top of website is sometimes hidden under Navigation Bar
}

@end
