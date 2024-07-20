import 'dart:async';
import 'dart:io' show Platform;
import 'dart:math';
import 'package:get/get.dart';
import 'package:applovin_max/applovin_max.dart';
import 'package:flutter/material.dart';
import 'package:flutter_device_id/flutter_device_id.dart';
import 'package:starbucks/common/constant/constant.dart';

final RxInt adLimit = 3.obs; // [adLimit] times user can show rewarded watching ad without premium

/// HIDE ADS FROM WHOLE APP [showAds] false
final RxBool showAds = true.obs;

class ApplovinAds {
  // TODO:[ANDROID] add meta data ---> android/app/src/main/AndroidManifest.xml
  /*
       <meta-data android:name="applovin.sdk.key"
             android:value="APPLOVIN SDK KEY FROM MAX DASHBOARD"/>
         <!-- Sample AdMob app ID: ca-app-pub-3940256099942544~3347511713 -->
         <meta-data
             android:name="com.google.android.gms.ads.APPLICATION_ID"
             android:value="GOOGLE ADMOB APP ID"/>
 */

  /// applovin sdk key
  static final String _sdkKey = "ccMGe6gxIrwPp2KuCSu4vpGVCzCTAf25RKl07y6UG23zbOSvJrcLf9y1yVl3Lqc9lynM4do3mDukidN9_vT1c1";
  static final MaxNativeAdViewController maxNativeAdViewController = MaxNativeAdViewController();

  /// ad unit id
  static final String interstitialAdUnitId = Platform.isIOS ? "ead29965f0c4d712" : "";
  static final String bannerAdUnitId = Platform.isIOS ? "ce755d5098c45e44" : "";
  static final String rewardedAdUnitId = Platform.isIOS ? "946d93eeb38d80d2" : "";
  static final String nativeAdUnitId = Platform.isIOS ? "a905e079a7bb0be5" : "";

  static final int maxExponentialRetryCount = 6;

  /// Create states
  static int interstitialRetryAttempt = 0;
  static int rewardedAdRetryAttempt = 0;
  static RxBool isInitialized = false.obs;

  static double mediaViewAspectRatio = 16 / 9;

  /// initialize applovin ads sdk
  static Future<void> initAds() async {
    if (showAds.value) {
      final MaxConfiguration? configuration = await AppLovinMAX.initialize(_sdkKey);
      if (configuration != null) {
        isInitialized.value = true;
        print("ApplovinMAX SDK Initialized: ${configuration.countryCode}");
      }
      if (isInitialized.value) {
        final String? advertisingId = await FlutterDeviceId().getDeviceId();
        print('Hello advertisingId $advertisingId');
        AppLovinMAX.setTestDeviceAdvertisingIds([advertisingId]);
        AppLovinMAX.loadInterstitial(interstitialAdUnitId);
        AppLovinMAX.loadRewardedAd(rewardedAdUnitId);
      }
      attachAdListeners();
    }
  }

  /// show banner applovin ads in app
  static Widget showBannerAds() {
    return Obx(() {
      isInitialized.value;
      if (isInitialized.value) {
        return MaxAdView(
          adUnitId: bannerAdUnitId,
          adFormat: AdFormat.banner,
          listener: AdViewAdListener(onAdLoadedCallback: (ad) {
            print('Banner widget ad loaded from ${ad.networkName}');
          }, onAdLoadFailedCallback: (adUnitId, error) {
            print('Banner widget ad failed to load with error code ${error.code} and message: ${error.message}');
          }, onAdClickedCallback: (ad) {
            print('Banner widget ad clicked');
          }, onAdExpandedCallback: (ad) {
            print('Banner widget ad expanded');
          }, onAdCollapsedCallback: (ad) {
            print('Banner widget ad collapsed');
          }, onAdRevenuePaidCallback: (ad) {
            print('Banner widget ad revenue paid: ${ad.revenue}');
          }),
        );
      } else {
        return SizedBox.shrink();
      }
    });
  }

  /// show interstital ads in app
  static Future<bool> showInterAds() async {
    if (isInitialized.value) {
      final bool isReady = await AppLovinMAX.isInterstitialReady(interstitialAdUnitId) ?? false;
      if (isReady) {
        AppLovinMAX.showInterstitial(interstitialAdUnitId);
      } else {
        print('Loading interstitial ad...');
        AppLovinMAX.loadInterstitial(interstitialAdUnitId);
      }
      return isReady;
    }
    return false;
  }

  /// show rewarded ads in app
  static Future<bool> showRewardAds() async {
    if (isInitialized.value) {
      final bool isReady = await AppLovinMAX.isRewardedAdReady(rewardedAdUnitId) ?? false;
      if (isReady) {
        AppLovinMAX.showRewardedAd(rewardedAdUnitId);
      } else {
        print('Loading rewarded ad...');
        AppLovinMAX.loadRewardedAd(rewardedAdUnitId);
      }
      return isReady;
    }
    return false;
  }

  /// show native ads in app and adjust height
  static Widget showNativeAds(double height) {
    return Obx(() {
      isInitialized.value;
      if (isInitialized.value) {
        return Container(
          margin: const EdgeInsets.all(8.0),
          height: height,
          child: MaxNativeAdView(
            adUnitId: nativeAdUnitId,
            controller: maxNativeAdViewController,
            listener: NativeAdListener(onAdLoadedCallback: (ad) {
              print('Native ad loaded from ${ad.networkName}');
              mediaViewAspectRatio = ad.nativeAd?.mediaContentAspectRatio ?? 16 / 9;
            }, onAdLoadFailedCallback: (adUnitId, error) {
              print('Native ad failed to load with error code ${error.code} and message: ${error.message}');
            }, onAdClickedCallback: (ad) {
              print('Native ad clicked');
            }, onAdRevenuePaidCallback: (ad) {
              print('Native ad revenue paid: ${ad.revenue}');
            }),
            child: Container(
              color: const Color(0xffefefef),
              padding: const EdgeInsets.all(8.0),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        padding: const EdgeInsets.all(4.0),
                        child: const MaxNativeAdIconView(width: 48, height: 48),
                      ),
                      Flexible(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.start,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            MaxNativeAdTitleView(style: TextStyle(fontFamily: "B", fontSize: 16), maxLines: 1, overflow: TextOverflow.visible),
                            MaxNativeAdAdvertiserView(style: TextStyle(fontFamily: "M", fontSize: 10), maxLines: 1, overflow: TextOverflow.fade),
                            MaxNativeAdStarRatingView(size: 10),
                          ],
                        ),
                      ),
                      const MaxNativeAdOptionsView(width: 20, height: 20),
                    ],
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      Flexible(
                        child: MaxNativeAdBodyView(style: TextStyle(fontFamily: "M", fontSize: 14), maxLines: 3, overflow: TextOverflow.ellipsis),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Expanded(
                    child: AspectRatio(aspectRatio: mediaViewAspectRatio, child: const MaxNativeAdMediaView()),
                  ),
                  SizedBox(
                    width: double.infinity,
                    child: MaxNativeAdCallToActionView(
                      style: ButtonStyle(
                        backgroundColor: WidgetStatePropertyAll<Color>(CommonColor.greenColor),
                        textStyle: WidgetStatePropertyAll<TextStyle>(TextStyle(fontSize: 15, fontFamily: "SB")),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      } else {
        return SizedBox.shrink();
      }
    });
  }

  /// applovin adk listener
  static void attachAdListeners() {
    /// Interstitial Ad Listeners
    AppLovinMAX.setInterstitialListener(InterstitialListener(
      onAdLoadedCallback: (ad) {
        // Interstitial ad is ready to be shown. AppLovinMAX.isInterstitialAdReady(_interstitial_ad_unit_id) will now return 'true'
        print('Interstitial ad loaded from ${ad.networkName}');

        // Reset retry attempt
        interstitialRetryAttempt = 0;
      },
      onAdLoadFailedCallback: (adUnitId, error) {
        // Interstitial ad failed to load
        // We recommend retrying with exponentially higher delays up to a maximum delay (in this case 64 seconds)
        interstitialRetryAttempt = interstitialRetryAttempt + 1;
        if (interstitialRetryAttempt > maxExponentialRetryCount) {
          print('Interstitial ad failed to load with code ${error.code}');
          return;
        }

        final int retryDelay = pow(2, min(maxExponentialRetryCount, interstitialRetryAttempt)).toInt();
        print('Interstitial ad failed to load with code ${error.code} - retrying in ${retryDelay}s');

        Future.delayed(Duration(milliseconds: retryDelay * 1000), () {
          print('Interstitial ad retrying to load...');
          AppLovinMAX.loadInterstitial(interstitialAdUnitId);
        });
      },
      onAdDisplayedCallback: (ad) {
        print('Interstitial ad displayed');
      },
      onAdDisplayFailedCallback: (ad, error) {
        print('Interstitial ad failed to display with code ${error.code} and message ${error.message}');
      },
      onAdClickedCallback: (ad) {
        print('Interstitial ad clicked');
      },
      onAdHiddenCallback: (ad) {
        print('Interstitial ad hidden');
        AppLovinMAX.loadInterstitial(interstitialAdUnitId);
      },
      onAdRevenuePaidCallback: (ad) {
        print('Interstitial ad revenue paid: ${ad.revenue}');
      },
    ));

    /// Rewarded Ad Listeners
    AppLovinMAX.setRewardedAdListener(RewardedAdListener(
      onAdLoadedCallback: (ad) {
        // Rewarded ad is ready to be shown. AppLovinMAX.isRewardedAdReady(_rewarded_ad_unit_id) will now return 'true'
        print('Rewarded ad loaded from ${ad.networkName}');

        // Reset retry attempt
        rewardedAdRetryAttempt = 0;
      },
      onAdLoadFailedCallback: (adUnitId, error) {
        // Rewarded ad failed to load
        // We recommend retrying with exponentially higher delays up to a maximum delay (in this case 64 seconds)
        rewardedAdRetryAttempt = rewardedAdRetryAttempt + 1;
        if (rewardedAdRetryAttempt > maxExponentialRetryCount) {
          print('Rewarded ad failed to load with code ${error.code}');
          return;
        }

        final int retryDelay = pow(2, min(maxExponentialRetryCount, rewardedAdRetryAttempt)).toInt();
        print('Rewarded ad failed to load with code ${error.code} - retrying in ${retryDelay}s');

        Future.delayed(Duration(milliseconds: retryDelay * 1000), () {
          print('Rewarded ad retrying to load...');
          AppLovinMAX.loadRewardedAd(rewardedAdUnitId);
        });
      },
      onAdDisplayedCallback: (ad) {
        print('Rewarded ad displayed');
      },
      onAdDisplayFailedCallback: (ad, error) {
        print('Rewarded ad failed to display with code ${error.code} and message ${error.message}');
      },
      onAdClickedCallback: (ad) {
        print('Rewarded ad clicked');
      },
      onAdHiddenCallback: (ad) {
        print('Rewarded ad hidden');
        AppLovinMAX.loadRewardedAd(rewardedAdUnitId);
      },
      onAdReceivedRewardCallback: (ad, reward) {
        print('Rewarded ad granted reward');
      },
      onAdRevenuePaidCallback: (ad) {
        print('Rewarded ad revenue paid: ${ad.revenue}');
      },
    ));

    /// Banner Ad Listeners
    AppLovinMAX.setBannerListener(AdViewAdListener(
      onAdLoadedCallback: (ad) {
        print('Banner ad loaded from ${ad.networkName}');
      },
      onAdLoadFailedCallback: (adUnitId, error) {
        print('Banner ad failed to load with error code ${error.code} and message: ${error.message}');
      },
      onAdClickedCallback: (ad) {
        print('Banner ad clicked');
      },
      onAdExpandedCallback: (ad) {
        print('Banner ad expanded');
      },
      onAdCollapsedCallback: (ad) {
        print('Banner ad collapsed');
      },
      onAdRevenuePaidCallback: (ad) {
        print('Banner ad revenue paid: ${ad.revenue}');
      },
    ));

    /// MREC Ad Listeners
    AppLovinMAX.setMRecListener(AdViewAdListener(onAdLoadedCallback: (ad) {
      print('MREC ad loaded from ${ad.networkName}');
    }, onAdLoadFailedCallback: (adUnitId, error) {
      print('MREC ad failed to load with error code ${error.code} and message: ${error.message}');
    }, onAdClickedCallback: (ad) {
      print('MREC ad clicked');
    }, onAdExpandedCallback: (ad) {
      print('MREC ad expanded');
    }, onAdCollapsedCallback: (ad) {
      print('MREC ad collapsed');
    }, onAdRevenuePaidCallback: (ad) {
      print('MREC ad revenue paid: ${ad.revenue}');
    }));
  }
}

// TODO: easy ads old code

// String? googleAppId = 'ca-app-pub-1031554205279977~4849970914';
// String? facebookAppId = '837404648236305';
//
// String? googleBannerAndroid;
// String? googleBannerIOS = 'ca-app-pub-1031554205279977/5420369448';
// String? facebookBannerAndroid;
// String? facebookBannerIOS = '1138984414003847_1139064633995825';
//
// String? googleInterstitialAndroid;
// String? googleInterstitialIOS = 'ca-app-pub-1031554205279977/4031713261';
// String? facebookInterstitialAndroid;
// String? facebookInterstitialIOS = '1138984414003847_1139064757329146';
//
// String? googleRewardedAndroid;
// String? googleRewardedIOS = 'ca-app-pub-1031554205279977/4107287770';
// String? facebookRewardedAndroid;
// String? facebookRewardedIOS = '1138984414003847_1139064993995789';

// final flutterDeviceIdPlugin = FlutterDeviceId();
//
// String? deviceId = await flutterDeviceIdPlugin.getDeviceId() ?? '';
// IAdIdManager adIdManager = AdsTestAdIdManager();
// print("DEVICE ID$deviceId");
// EasyAds.instance.initialize(
//   isShowAppOpenOnAppStateChange: false,
//   adIdManager,
//   adMobAdRequest: const AdRequest(),
//   admobConfiguration: RequestConfiguration(testDeviceIds: [deviceId]),
//   fbTestMode: true,
//   showAdBadge: Platform.isIOS,
//   fbiOSAdvertiserTrackingEnabled: true,
// );
// class AdsTestAdIdManager extends IAdIdManager {
//   AdsTestAdIdManager();
//
//   @override
//   AppAdIds? get fbAdIds => AppAdIds(
//         appId: facebookAppId!,
//         bannerId: Platform.isIOS ? facebookBannerIOS : facebookBannerAndroid,
//         interstitialId: Platform.isIOS ? facebookInterstitialIOS : facebookInterstitialAndroid,
//         rewardedId: Platform.isIOS ? facebookRewardedIOS : facebookRewardedAndroid,
//       );
//
//   @override
//   AppAdIds? get admobAdIds => AppAdIds(
//         appId: googleAppId!,
//         bannerId: Platform.isIOS ? googleBannerIOS : googleBannerAndroid,
//         interstitialId: Platform.isIOS ? googleInterstitialIOS : googleInterstitialAndroid,
//         rewardedId: Platform.isIOS ? googleRewardedIOS : googleRewardedAndroid,
//       );
//
//   @override
//   AppAdIds? get unityAdIds => null;
//
//   @override
//   AppAdIds? get appLovinAdIds => null;
// }
//
// /// Banner Ads
// Widget bannerAds() {
//   return EasySmartBannerAd(
//     priorityAdNetworks: [AdNetwork.facebook, AdNetwork.admob],
//     adSize: AdSize.banner,
//   );
// }
//
// /// Interstitial & Rewarded Ads
// void showAd(AdUnitType adUnitType) {
//   if (adUnitType == AdUnitType.interstitial) {
//     if (EasyAds.instance.showAd(adUnitType, adNetwork: AdNetwork.facebook))
//       ;
//     else
//       EasyAds.instance.showAd(adUnitType, adNetwork: AdNetwork.admob);
//   } else if (adUnitType == AdUnitType.rewarded) {
//     if (EasyAds.instance.showAd(adUnitType, adNetwork: AdNetwork.facebook))
//       ;
//     else
//       EasyAds.instance.showAd(adUnitType, adNetwork: AdNetwork.admob);
//   }
// }
