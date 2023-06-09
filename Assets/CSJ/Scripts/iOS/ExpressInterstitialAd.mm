//------------------------------------------------------------------------------
// Copyright (c) 2018-2019 Beijing Bytedance Technology Co., Ltd.
// All Right Reserved.
// Unauthorized copying of this file, via any medium is strictly prohibited.
// Proprietary and confidential.
//------------------------------------------------------------------------------

#import <BUAdSDK/BUAdSDK.h>
#import "UnityAppController.h"
#import "AdSlot.h"
static const char* AutonomousStringCopy_Express(const char* string);

const char* AutonomousStringCopy_Express(const char* string)
{
    if (string == NULL) {
        return NULL;
    }
    
    char* res = (char*)malloc(strlen(string) + 1);
    strcpy(res, string);
    return res;
}


typedef void(*ExpressAd_OnLoad)(void* expressAd, int context);
typedef void(*ExpressAd_OnLoadError)(int errCode,const char* errMsg,int context);
typedef void(*ExpressAd_WillShow)(int context);
typedef void(*ExpressAd_DidClick)(int context);
typedef void(*ExpressAd_DidClose)(int context);
typedef void(*ExpressAd_DidRemove)(int context);
typedef void(*ExpressAd_RenderFailed)(int errCode,const char* errMsg,int context);
typedef void(*ExpressAd_RenderSuccess)(void* expressAd,int context);

@interface ExpressInterstitialAd : NSObject<BUNativeExpresInterstitialAdDelegate,BUAdObjectProtocol>

@property (nonatomic, strong) BUNativeExpressInterstitialAd *interstitialAd;
@property (nonatomic, assign) float adWidth;
@property (nonatomic, assign) float adHeight;

@property (nonatomic, assign) int loadContext;
@property (nonatomic, assign) int listenContext;

@property (nonatomic, assign) ExpressAd_OnLoad onLoad;
@property (nonatomic, assign) ExpressAd_OnLoadError onLoadError;
@property (nonatomic, assign) ExpressAd_WillShow willShow;
@property (nonatomic, assign) ExpressAd_DidClick didClick;
@property (nonatomic, assign) ExpressAd_DidClose didClose;
@property (nonatomic, assign) ExpressAd_DidRemove didRemove;
@property (nonatomic, assign) ExpressAd_RenderFailed renderFailed;
@property (nonatomic, assign) ExpressAd_RenderSuccess renderSuccess;
@end


@implementation ExpressInterstitialAd
#pragma ---BUNativeExpresInterstitialAdDelegate
- (void)nativeExpresInterstitialAdDidLoad:(BUNativeExpressInterstitialAd *)interstitialAd {
    if (self.onLoad) {
        self.onLoad((__bridge void*)self, self.loadContext);
    }
}

- (void)nativeExpresInterstitialAd:(BUNativeExpressInterstitialAd *)interstitialAd didFailWithError:(NSError *)error {
    if (self.onLoadError) {
        self.onLoadError((int)error.code,[[error localizedDescription] UTF8String],self.loadContext);
    }
}

- (void)nativeExpresInterstitialAdRenderSuccess:(BUNativeExpressInterstitialAd *)interstitialAd {
    if (self.renderSuccess) {
       self.renderSuccess((__bridge void*)self, self.loadContext);
    }
}

- (void)nativeExpresInterstitialAdRenderFail:(BUNativeExpressInterstitialAd *)interstitialAd error:(NSError *)error {
    if (self.renderFailed) {
        self.renderFailed((int)error.code,[[error localizedDescription] UTF8String],self.loadContext);
    }
}

- (void)nativeExpresInterstitialAdWillVisible:(BUNativeExpressInterstitialAd *)interstitialAd {
    if (self.willShow) {
        self.willShow(self.listenContext);
    }
}

- (void)nativeExpresInterstitialAdDidClick:(BUNativeExpressInterstitialAd *)interstitialAd {
    if (self.didClick) {
        self.didClick(self.listenContext);
    }
}

- (void)nativeExpresInterstitialAdWillClose:(BUNativeExpressInterstitialAd *)interstitialAd {
}

- (void)nativeExpresInterstitialAdDidClose:(BUNativeExpressInterstitialAd *)interstitialAd {
    if (self.didClose) {
        self.didClose(self.listenContext);
    }
}

- (id<BUAdClientBiddingProtocol>)adObject {
    return self.interstitialAd;
}

@end

#if defined (__cplusplus)
extern "C" {
#endif
    void UnionPlatform_ExpressInterstitialsAd_Load(
                                      AdSlotStruct *adSlot,
                                      ExpressAd_OnLoad onLoad,
                                      ExpressAd_OnLoadError onLoadError,
                                      ExpressAd_RenderSuccess renderSuccess,
                                      ExpressAd_RenderFailed renderFailed,
                                      int context) {
                                          
        CGFloat newWidth = adSlot->viewWidth/[UIScreen mainScreen].scale;
        CGFloat newHeight = adSlot-> viewHeight/[UIScreen mainScreen].scale;
        ExpressInterstitialAd *instance = [[ExpressInterstitialAd alloc] init];;
        instance.interstitialAd = [[BUNativeExpressInterstitialAd alloc] initWithSlotID:[[NSString alloc] initWithUTF8String:adSlot->slotId?:""] adSize:CGSizeMake(newWidth,newHeight)];
        instance.interstitialAd.delegate = instance;
        
        instance.onLoad = onLoad;
        instance.onLoadError = onLoadError;
        instance.loadContext = context;
        instance.renderSuccess = renderSuccess;
        instance.renderFailed =renderFailed;
        [instance.interstitialAd loadAdData];
        
        (__bridge_retained void*)instance;
    }
    
    void UnionPlatform_ExpressInterstitialsAd_SetInteractionListener(
                                                        void* expressAdPtr,
                                                        ExpressAd_WillShow willShow,
                                                        ExpressAd_DidClick didClick,
                                                        ExpressAd_DidClose didClose,
                                                        int context) {
        
        ExpressInterstitialAd *expressInterstitialAd = (__bridge ExpressInterstitialAd*)expressAdPtr;
        expressInterstitialAd.willShow = willShow;
        expressInterstitialAd.didClick = didClick;
        expressInterstitialAd.didClose = didClose;
        expressInterstitialAd.listenContext = context;
    }
    
    void UnionPlatform_ExpressInterstitialsAd_Show(void* expressAdPtr, float originX, float originY) {
        ExpressInterstitialAd *expressInterstitialAd = (__bridge ExpressInterstitialAd*)expressAdPtr;
        [expressInterstitialAd.interstitialAd showAdFromRootViewController:GetAppController().rootViewController];
    }
    
    void UnionPlatform_ExpressInterstitialAd_Dispose(void* expressAdPtr) {
        (__bridge_transfer ExpressInterstitialAd*)expressAdPtr;
    }

#if defined (__cplusplus)
}
#endif
