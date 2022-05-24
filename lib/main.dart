import 'package:bloc/bloc.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:project_udemy/compomats/shared_componat/bloc_observer.dart';
import 'package:project_udemy/compomats/shared_componat/componat.dart';
import 'package:project_udemy/compomats/shared_componat/constan.dart';
import 'package:project_udemy/layout/social_app/cubit/cubit.dart';
import 'package:project_udemy/layout/social_app/cubit/states.dart';
import 'package:project_udemy/layout/social_app/social_layout.dart';
import 'package:project_udemy/moudules/social_app/social_login/social_login_screen.dart';
import 'package:project_udemy/styles/themes.dart';
import 'network/local/shared_preferences.dart';
import 'network/remote/dio_helper.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  // dah lazm 3sahan ana 3amlt await ll cachehelper we tlama 3mlt await lazm a3ml async lle main
  // fa lazm a3ml eli fo2 deh 3shan 3shan dah byt2ked en kul 7aga hena fel method 5last
  // we b3den y3ml run ll app
  await Firebase.initializeApp();

  DioHelper.init();
  await CacheHelper.init();
// Bloc.observer =MyBlocObserver();

  //deh 3shan lw 3yaz a5leh yb3t ll user eli da5l dah
  var token = await FirebaseMessaging.instance.getToken();
  print(token);
  FirebaseMessaging.onMessage.listen((event) {
    print(event.data.toString());
    showToast(text: 'onMessage', state: ToastStates.SUCCESS);
  });

  FirebaseMessaging.onMessageOpenedApp.listen((event) {
    print(event.data.toString());
    showToast(text: 'Opened app', state: ToastStates.SUCCESS);
  });

  BlocOverrides.runZoned(
    () {
      // CounterCubit();

      bool? isDark = CacheHelper.getData(key: 'isDark');

      Widget? widget;

      //dol bto3 l app shop eli t7t dol
      // bool? onBoarding = CacheHelper.getData(key: 'onBoarding');
      //
      //  token = CacheHelper.getData(key: 'token');
      // if (onBoarding != null )
      // {
      //   if (token != null) widget = ShopLayout();
      //
      //   else widget = ShopLoginScreen();
      // }else{
      //   widget = OnBoradingScreen();
      // }

      uId = CacheHelper.getData(key: 'uId');
      if (uId != null) {
        widget = SocialLayout();
      } else {
        widget = SocialLoginScreen();
      }

      runApp(MyApp(
        isDark: isDark,
        startWidget: widget,
      ));
    },
    blocObserver: MyBlocObserver(),
  );
}

class MyApp extends StatelessWidget {
  bool? isDark;
  Widget? startWidget;

  MyApp({this.isDark, this.startWidget});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
        providers: [
          BlocProvider(
            create: (BuildContext context) => SocialCubit()
              ..getUserData()
              ..getPosts()
              ..changeAppMode(fromShared: isDark),
            // ..changeAppMode(fromShared: isDark)
          ),
        ],
        child: BlocConsumer<SocialCubit, SocialStates>(
            listener: (context, state) {},
            builder: (context, state) {
              return MaterialApp(
                debugShowCheckedModeBanner: false,
                theme: lightTheme,
                darkTheme: darkTheme,
                themeMode:
                    // ThemeMode.light,
                    SocialCubit.get(context).isDark
                        ? ThemeMode.dark
                        : ThemeMode.light,
                home:
                    //SocialLoginScreen()
                    startWidget,
              );
            }));
  }
}
