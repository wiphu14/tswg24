import 'dart:io';

import 'package:checkofficer/states/authen.dart';
import 'package:checkofficer/states/list_guest.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';

List<GetPage<dynamic>>? getPages = [
  GetPage(name: '/authen', page: () => const Authen()),
  GetPage(name: '/listGuest', page: () => const ListGuest() ),
];
String? initialRoute;

Future<void> main() async {
  HttpOverrides.global = MyHttpOverride();

  WidgetsFlutterBinding.ensureInitialized();

  await GetStorage.init().then((value) {
    var result =   GetStorage().read('api');
  print('## result --> $result');

  if (result == null) {
    // ยังไม่ได้ Login
    initialRoute = '/authen';
    runApp(const MyApp());
  } else {
    // Login แล้ว
    initialRoute = '/listGuest';
    runApp(const MyApp());
  }





  },);



  



  
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    SystemChrome.setPreferredOrientations(
        [DeviceOrientation.portraitUp, DeviceOrientation.portraitDown]);
    return GetMaterialApp(
      debugShowCheckedModeBanner: false,
      // home: const Authen(),

      getPages: getPages,
      initialRoute: initialRoute,

      theme: ThemeData(
        useMaterial3: true,
      ),
    );
  }
}

class MyHttpOverride extends HttpOverrides {
  @override
  HttpClient createHttpClient(SecurityContext? context) {
    return super.createHttpClient(context)
      ..badCertificateCallback = (cert, host, port) => true;
  }
}
