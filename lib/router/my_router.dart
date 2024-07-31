import 'package:auto_share/authentication/auth_notifier.dart';
import 'package:auto_share/authentication/forgot_password_screen.dart';
import 'package:auto_share/authentication/login_screen.dart';
import 'package:auto_share/authentication/signup/signup_screens.dart';
import 'package:auto_share/owner/owner_screens_manager.dart';
import 'package:auto_share/owner/screens/add_new_car_page.dart';
import 'package:auto_share/owner/screens/add_new_offer_page.dart';
import 'package:auto_share/owner/screens/update_car_page.dart';
import 'package:auto_share/owner/screens/offer_details_page.dart';
import 'package:auto_share/renter/renter_screens_manager.dart';
import 'package:auto_share/router/route_constants.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:auto_share/database/models/car.dart';
import 'package:auto_share/database/models/offer.dart';
import 'package:auto_share/general/screens/account_details_page.dart';
import 'package:auto_share/general/screens/rental_history_page.dart';
import 'package:provider/provider.dart';
import 'package:auto_share/owner/screens/car_details_page.dart';


class RouterArgs {
  RouterArgs({required Map<String, TextEditingController> controllerMap, required int pageIndex}) :
        _controllerMap = controllerMap,
        _pageIndex = pageIndex;

  final Map<String, TextEditingController> _controllerMap;
  final int _pageIndex;

  Map<String, TextEditingController> get controllerMap => _controllerMap;
  int get pageIndex => _pageIndex;
}


class MyRouter{

  MyRouter();

  final GoRouter _router = GoRouter(
      errorBuilder: (context, state) => ErrorScreen(error:state.error),
      routes: <GoRoute>[
        GoRoute(
          name: RouteConstants.homeRoute,
          path: '/',
          redirect: (BuildContext context, GoRouterState state) {
            if (FirebaseAuth.instance.currentUser != null) {
              String lastMode = context.read<AuthenticationNotifier>().autoShareUser.lastMode;
              switch (lastMode){
                case 'renter':
                  return '/renter';
                case 'owner':
                  return '/owner';
                default:
                  return '/renter';
              }
            }
            return '/login';
          },
        ),
        GoRoute(
          name: RouteConstants.loginRoute,
          path: '/login',
          builder: (BuildContext context, GoRouterState state) => const LoginScreen(),
          routes: <GoRoute>[
            GoRoute(
              name: RouteConstants.forgotPassword,
              path: 'forgot_password',
              builder: (BuildContext context, GoRouterState state) => const ForgotPasswordScreen(),
            ),
            GoRoute(
              name: RouteConstants.nameSignup,
              path: 'name_su',
              builder: (BuildContext context, GoRouterState state) => NameScreen(
                routerArgs: RouterArgs(
                  controllerMap: <String, TextEditingController>{},
                  pageIndex: 1,
                ),
              ),
              routes: <GoRoute>[
                GoRoute(
                  name: RouteConstants.emailSignup,
                  path: 'email_su',
                  builder: (BuildContext context, GoRouterState state) {
                    var routerArgs = state.extra as RouterArgs;
                    return EmailScreen(
                        routerArgs: routerArgs
                    );
                  },
                  routes: <GoRoute>[
                    GoRoute(
                      name: RouteConstants.passwordSignup,
                      path: 'password_su',
                      builder: (BuildContext context, GoRouterState state) {
                        var routerArgs = state.extra as RouterArgs;
                        return PasswordScreen(routerArgs: routerArgs);
                      },
                      routes: <GoRoute>[
                        GoRoute(
                          name: RouteConstants.phoneNumberSignup,
                          path: 'phone_number_su',
                          builder: (BuildContext context, GoRouterState state) {
                            var routerArgs = state.extra as RouterArgs;
                            return PhoneNumberScreen(routerArgs: routerArgs);
                          },
                          routes: <GoRoute>[
                            GoRoute(
                              name: RouteConstants.birthdaySignup,
                              path: 'bd_su',
                              builder: (BuildContext context, GoRouterState state) {
                                var routerArgs = state.extra as RouterArgs;
                                return BirthdateScreen(routerArgs: routerArgs);
                              },
                              routes: <GoRoute>[
                                GoRoute(
                                  name: RouteConstants.licenseSignup,
                                  path: 'license_su',
                                  builder: (BuildContext context, GoRouterState state) {
                                    var routerArgs = state.extra as RouterArgs;
                                    return LicenseNumberScreen(routerArgs: routerArgs);
                                  },
                                  routes: <GoRoute>[
                                    GoRoute(
                                      name: RouteConstants.creditCardSignup,
                                      path: 'credit_card_su',
                                      builder: (BuildContext context, GoRouterState state) {
                                        var routerArgs = state.extra as RouterArgs;
                                        return CreditCardScreen(routerArgs: routerArgs);
                                      },
                                      routes: <GoRoute>[
                                        GoRoute(
                                          name: RouteConstants.profileSignup,
                                          path: 'profile_pic_su',
                                          builder: (BuildContext context, GoRouterState state) {
                                            var routerArgs = state.extra as RouterArgs;
                                            return ProfilePictureScreen(routerArgs: routerArgs);
                                          },
                                        ),
                                      ]
                                    ),
                                  ]
                                ),
                              ]
                            ),
                          ]
                        ),
                      ]
                    ),
                  ]
                ),
              ]
            ),
          ]
        ),
        GoRoute(
          name: RouteConstants.renterRoute,
          path: '/renter',
          builder: (BuildContext context, GoRouterState state) {
            Map<String,dynamic>? args = state.extra as Map<String,dynamic>?;
            return RenterScreensManager(
                initialScreenIndex: args?['initial_page_index'] as int?,
                initialTabIndex: args?['initial_tab_index'] as int?,
            );
          },
          routes: <GoRoute>[
            GoRoute(
              name: RouteConstants.renterDetails,
              path: 'details',
              builder: (BuildContext context, GoRouterState state) =>
              const AccountDetailsPage(),
            ),
            GoRoute(
              name: RouteConstants.renterRentalHistory,
              path: 'rental_history',
              builder: (BuildContext context, GoRouterState state) =>
              const RentalHistoryPage(),
            ),
          ]

        ),
        GoRoute(
          name: RouteConstants.ownerRoute,
          path: '/owner',
          builder: (BuildContext context, GoRouterState state) {
            Map<String,dynamic>? args = state.extra as Map<String,dynamic>?;
            return OwnerScreensManager(
                initialScreenIndex: args?['initial_page_index'] as int?,
                initialTabIndex: args?['initial_tab_index']as int?
            );
          },
          routes: <GoRoute>[
            GoRoute(
              name: RouteConstants.addNewOffer,
              path: 'add_new_offer',
              builder: (BuildContext context, GoRouterState state) =>
              const AddNewOfferPage(),
            ),
            GoRoute(
              name: RouteConstants.addNewCar,
              path: 'add_new_car',
              builder: (BuildContext context, GoRouterState state) =>
                  const AddNewCarPage(),
            ),
            GoRoute(
              name: RouteConstants.carDetails,
              path: 'car_details',
              builder: (BuildContext context, GoRouterState state) =>
                  CarDetailsPage(car: state.extra as Car),
              routes: <GoRoute>[
                GoRoute(
                  name: RouteConstants.updateCar,
                  path: 'update_car',
                  builder: (BuildContext context, GoRouterState state) {
                    var args = state.extra as Map<String, dynamic>;
                    Car car = args['car'] as Car;
                    Function updateCar = args['update_car'] as Function;
                    return UpdateCarPage(car: car, updateCar: updateCar);
                  },
                ),
              ]
            ),
            GoRoute(
              name: RouteConstants.offerDetails,
              path: 'offer_details',
              builder: (BuildContext context, GoRouterState state) =>
                  OfferDetailsPage(offer: state.extra as Offer),
            ),
            GoRoute(
              name: RouteConstants.ownerDetails,
              path: 'details',
              builder: (BuildContext context, GoRouterState state) =>
              const AccountDetailsPage(),
            ),
            GoRoute(
              name: RouteConstants.ownerRentalHistory,
              path: 'rental_history',
              builder: (BuildContext context, GoRouterState state) =>
              const RentalHistoryPage(),
            ),
          ]
        ),
      ]
  );

  GoRouter get router => _router;

  BuildContext? get context => _router.routerDelegate.navigatorKey.currentContext;
}


class ErrorScreen extends StatelessWidget {
  final Exception? error;
  ErrorScreen( {Key? key, required this.error}) : super(key: key);

  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      appBar: AppBar(
        title: const Text("Error"),
      ),
      body: Center(
        child: Text(
            error.toString()
        ),
      ),
    );
  }
}