import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:RehAssistant/pages/login_page.dart';
import 'package:RehAssistant/pages/root_page.dart';
import 'package:RehAssistant/services/authentication.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:in_app_purchase/in_app_purchase.dart';
import 'package:in_app_purchase_android/in_app_purchase_android.dart';
import 'package:provider/provider.dart';
//import 'package:in_app_purchase_android/in_app_purchase_android.dart';
import 'package:RehAssistant/services/notification_helper.dart';
// Import the firebase_core plugin
import 'package:firebase_core/firebase_core.dart';

final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
    FlutterLocalNotificationsPlugin();
NotificationAppLaunchDetails notificationAppLaunchDetails;

// Gives the option to override in tests.
class IAPConnection {
  static InAppPurchase _instance;
  static set instance(InAppPurchase value) {
    _instance = value;
  }

  static InAppPurchase get instance {
    _instance ??= InAppPurchase.instance;
    return _instance;
  }
}

Future<void> main()async {
  if (defaultTargetPlatform == TargetPlatform.android) {
    InAppPurchaseAndroidPlatformAddition.enablePendingPurchases();
  }
  
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  // notificationAppLaunchDetails =
  //     await flutterLocalNotificationsPlugin.getNotificationAppLaunchDetails();
  // await initNotifications(flutterLocalNotificationsPlugin);
  requestIOSPermissions(flutterLocalNotificationsPlugin);
  runApp(MyApp());
  
  
}



class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        //0xff3876C3
        primarySwatch: MaterialColor(0xff1e49af, color),
      ),
      home: new RootPage(auth: new Auth()));
  }
}
Map<int, Color> color =
{
50:Color(0xff3876C3),
100:Color(0xff3876C3),
200:Color(0xff3876C3),
300:Color(0xff3876C3),
400:Color(0xff3876C3),
500:Color(0xff3876C3),
600:Color(0xff3876C3),
700:Color(0xff3876C3),
800:Color(0xff3876C3),
900:Color(0xff3876C3),
};