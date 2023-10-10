import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:flutter_native_splash/flutter_native_splash.dart';
import 'package:onesignal_flutter/onesignal_flutter.dart';

import 'Constant.dart';

Future main() async {
  WidgetsBinding widgetsBinding = WidgetsFlutterBinding.ensureInitialized();
  FlutterNativeSplash.preserve(widgetsBinding: widgetsBinding);

  // await Permission.camera.request();
  // await Permission.microphone.request();
  // await Permission.storage.request();
  OneSignal.initialize(oneSignalKEY);
  OneSignal.Notifications.requestPermission(true);
  if (Platform.isAndroid) {
    await AndroidInAppWebViewController.setWebContentsDebuggingEnabled(true);

    var swAvailable = await AndroidWebViewFeature.isFeatureSupported(
        AndroidWebViewFeature.SERVICE_WORKER_BASIC_USAGE);
    var swInterceptAvailable = await AndroidWebViewFeature.isFeatureSupported(
        AndroidWebViewFeature.SERVICE_WORKER_SHOULD_INTERCEPT_REQUEST);

    if (swAvailable && swInterceptAvailable) {
      AndroidServiceWorkerController serviceWorkerController =
          AndroidServiceWorkerController.instance();

      await serviceWorkerController
          .setServiceWorkerClient(AndroidServiceWorkerClient(
        shouldInterceptRequest: (request) async {
          print(request);
          return null;
        },
      ));
    }
  }

  runApp(MyApp());
  FlutterNativeSplash.remove();
}

MaterialColor mainAppColor = const MaterialColor(
  0xFF89cfbe,
  <int, Color>{
    50: Colors.transparent,
    100: Colors.transparent,
    200: Colors.transparent,
    300: Colors.transparent,
    400: Colors.transparent,
    500: Colors.transparent,
    600: Colors.transparent,
    700: Colors.transparent,
    800: Colors.transparent,
    900: Colors.transparent,
  },
);

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: mainAppColor,
      ),
      debugShowCheckedModeBanner: false,
      home: NewWidget(),
    );
  }
}

class NewWidget extends StatefulWidget {
  const NewWidget({
    Key? key,
  }) : super(key: key);

  @override
  State<NewWidget> createState() => _NewWidgetState();
}

class _NewWidgetState extends State<NewWidget> {
  bool _confirmExit = false;
  bool _snackbarClosed = true;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: WillPopScope(
        onWillPop: () async {
          if (_confirmExit && !_snackbarClosed) {
            // Kullanıcı bir kez "Evet" dedi ve SnackBar kapandı, uygulamayı kapat.
            SystemNavigator.pop();
            return true;
          } else if (!_confirmExit) {
            // Kullanıcı bir kez geri tuşuna bastı, doğrulama mesajını göster.
            _showSnackBar(context);
          }
          // Bu geri tuş olayını engelle.
          return false;
        },
        child: Padding(
          padding: MediaQuery.of(context).padding,
          child: Container(
            color: Colors.transparent,
            child: InAppWebView(
                androidOnPermissionRequest: (InAppWebViewController controller,
                    String origin, List<String> resources) async {
                  return PermissionRequestResponse(
                      resources: resources,
                      action: PermissionRequestResponseAction.GRANT);
                },
                initialOptions: InAppWebViewGroupOptions(
                  crossPlatform: InAppWebViewOptions(
                    useShouldOverrideUrlLoading: true,
                    mediaPlaybackRequiresUserGesture: false,
                    userAgent:
                        "Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/98.0.4758.102 Safari/537.36 OPR/84.0.4316.21",
                  ),
                  android: AndroidInAppWebViewOptions(
                    useHybridComposition: true,
                  ),
                  ios: IOSInAppWebViewOptions(
                    allowsInlineMediaPlayback: true,
                  ),
                ),
                initialUrlRequest: URLRequest(
                  url: Uri.parse(webViewURL),
                )),
          ),
        ),
      ),
    );
  }

  void _showSnackBar(BuildContext context) {
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(
          content: Text('Çıkmak için bir daha geri tuşuna basınız.'),
          duration: Duration(seconds: 3),
        ))
        .closed
        .then((reason) {
      // SnackBar kapandığında, _snackbarClosed değerini güncelle.
      setState(() {
        _snackbarClosed = true;
        _confirmExit = false;
      });
    });

    // SnackBar gösterildiğinde, _confirmExit değerini güncelle.
    setState(() {
      _confirmExit = true;
      _snackbarClosed = false;
    });
  }
}
