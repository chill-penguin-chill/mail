import 'dart:io';

import 'package:ab_shared/components/app/ab_navbar.dart';
import 'package:mail/blocs/app/app.bloc.dart';
import 'package:ab_shared/blocs/auth/auth.bloc.dart';
import 'package:ab_shared/components/responsive_stateful_widget.dart';
import 'package:ab_shared/components/widgets/elevated_container.dart';
import 'package:ab_shared/pages/auth/login_or_register_modal.dart';
import 'package:ab_shared/pages/paywall/paywall_utils.dart';
import 'package:ab_shared/services/device_info.service.dart';
import 'package:ab_shared/services/encryption.service.dart';
import 'package:ab_shared/utils/constants.dart';
import 'package:ab_shared/utils/shortcuts.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_side_menu/flutter_side_menu.dart';
import 'package:macos_window_utils/widgets/titlebar_safe_area.dart';
import 'package:mail/main.dart';
import 'package:mail/utils/nav_constants.dart';

class AppLayout extends ResponsiveStatefulWidget {
  const AppLayout({super.key});

  @override
  AppLayoutState createState() => AppLayoutState();
}

class AppLayoutState extends ResponsiveState<AppLayout> {
  bool _isLoginModalVisible = false;
  final SideMenuController _secondarySideMenuController = SideMenuController();
  final SideMenuController _primarySideMenuController = SideMenuController();

  @override
  void initState() {
    context.read<AuthBloc>().add(const RefreshUser());
    PaywallUtils.resetPaywall(
      prefs: prefs!,
    );

    if (context.read<AuthBloc>().state.user != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) async {
        if (context.read<AuthBloc>().state.user?.devices == null) {
          context.read<AuthBloc>().state.user?.devices = [];
        }
        final deviceInfoService = DeviceInfoService();
        final userDeviceInfo = await deviceInfoService.getDeviceInfo();

        if (!context.mounted) return;
        // ignore: use_build_context_synchronously
        context.read<AuthBloc>().add(
              UpdateUserDevice(
                // ignore: use_build_context_synchronously
                context.read<AuthBloc>().state.user!,
                userDeviceInfo,
              ),
            );
        // }
      });
    }
    super.initState();
  }

  @override
  Widget buildMobile(BuildContext context) {
    return BlocBuilder<AppCubit, AppState>(
      builder: (context, appState) {
        return BlocBuilder<AuthBloc, AuthState>(
            builder: (context, authState) {
          _runAppInitAndChecks(
              context: context, appState: appState, authState: authState);
        
          // get the secondary section based on the selected primary menu
          final secondarySection = $navConstants
              .secondaryMenuSections(context)
              .where(
                (section) =>
                    (section.key as ValueKey).value ==
                    appState.primaryMenuSelectedKey,
              )
              .firstOrNull;
        
          var primaryMenuItem = $navConstants
              .primaryMenuItems(context)
              .where((item) =>
                  (item.key as ValueKey).value ==
                  appState.primaryMenuSelectedKey)
              .firstOrNull;
          // by default, the primary menu is selected
          Widget? body = primaryMenuItem?.body;
          AppBar? appBar = primaryMenuItem?.appBar;
        
          // select the items if there's a secondary menu and a secondary menu item is selected
          if (secondarySection != null &&
              secondarySection.items.isNotEmpty &&
              appState.secondaryMenuSelectedKey != '') {
            body = secondarySection.items
                .where((item) =>
                    (item.key as ValueKey).value ==
                    appState.secondaryMenuSelectedKey)
                .firstOrNull
                ?.body;
        
            final secondaryAppBar = secondarySection.items
                .where((item) =>
                    (item.key as ValueKey).value ==
                    appState.secondaryMenuSelectedKey)
                .firstOrNull
                ?.appBar;
        
            // use the secondary appBar if it exists, else let the parent appBar
            if (secondaryAppBar != null) {
              appBar = secondaryAppBar;
            }
          }
        
          return Flex(
            direction: Axis.horizontal,
            children: [
              Expanded(
                child: Stack(
                  children: [
                    Scaffold(
                      // if there's secondary, show the secondary item appBar
                      // else show the primary appBar
                      appBar: appBar,
                      backgroundColor: getTheme(context).surface,
                      body: body,
                    ),
                    Positioned(
                      bottom: $constants.insets.lg,
                      left: 0,
                      right: 0,
                      child: Padding(
                        padding: EdgeInsets.symmetric(horizontal: $constants.insets.md),
                        child: ABNavbar(
                          backgroundColor: getTheme(context).surfaceContainer,
                        onPrimaryMenuSelected: (key) {
                          context.read<AppCubit>().changePrimaryMenuSelectedKey(
                                key: key,
                              );
                        },
                        onSecondaryMenuSelected: (key) {
                          context.read<AppCubit>().changeSecondaryMenuSelectedKey(
                                key: key,
                              );
                        },
                        destinations: $navConstants
                            .primaryMenuItems(context)
                            .take(5)
                            .toList(),
                        primaryMenuKey: appState.primaryMenuSelectedKey,
                                          ),
                      ),
                    ), 
                  ],
                ),
              )
            ],
          );
        });
      },
    );
  }

  @override
  Widget buildDesktop(BuildContext context) {
    return BlocBuilder<AppCubit, AppState>(
      builder: (context, appState) {
        return BlocBuilder<AuthBloc, AuthState>(
            builder: (context, authState) {
          _runAppInitAndChecks(
              context: context, appState: appState, authState: authState);
        
          // get the secondary section based on the selected primary menu
          final secondarySection = $navConstants
              .secondaryMenuSections(context)
              .where(
                (section) =>
                    (section.key as ValueKey).value ==
                    appState.primaryMenuSelectedKey,
              )
              .firstOrNull;
        
          // by default, the primary menu is selected
          Widget? body = $navConstants
              .primaryMenuItems(context)
              .where((item) =>
                  (item.key as ValueKey).value ==
                  appState.primaryMenuSelectedKey)
              .firstOrNull
              ?.body;
          AppBar? appBar = $navConstants
              .primaryMenuItems(context)
              .where((item) =>
                  (item.key as ValueKey).value ==
                  appState.primaryMenuSelectedKey)
              .firstOrNull
              ?.appBar;
        
          // on desktop, move the 4th primary menu item to the end of the list
          final primaryMenuItems =
              $navConstants.primaryMenuItems(context).toList();
          if (primaryMenuItems.length > 4) {
            final itemToMove = primaryMenuItems.removeAt(4);
            primaryMenuItems.add(itemToMove);
          }
        
          // select the items if there's a secondary menu and a secondary menu item is selected
          if (secondarySection != null &&
              secondarySection.items.isNotEmpty &&
              appState.secondaryMenuSelectedKey != '') {
            body = secondarySection.items
                .where((item) =>
                    (item.key as ValueKey).value ==
                    appState.secondaryMenuSelectedKey)
                .firstOrNull
                ?.body;
        
            final secondaryAppBar = secondarySection.items
                .where((item) =>
                    (item.key as ValueKey).value ==
                    appState.secondaryMenuSelectedKey)
                .firstOrNull
                ?.appBar;
        
            // use the secondary appBar if it exists, else let the parent appBar
            if (secondaryAppBar != null) {
              appBar = secondaryAppBar;
            }
          }
        
          final renderedBody = Flex(
            direction: Axis.horizontal,
            children: [
              // primary menu items
              Padding(
                padding: EdgeInsets.all($constants.insets.xs),
                child: ElevatedContainer(
                  child: ClipRRect(
                    borderRadius:
                        BorderRadius.circular($constants.corners.sm),
                    child: SideMenu(
                      controller: _primarySideMenuController,
                      mode: SideMenuMode.open,
                      minWidth: getSize(context).width * 0.08,
                      backgroundColor: getTheme(context).surfaceContainer,
                      hasResizer: false,
                      hasResizerToggle: false,
                      builder: (data) {
                        return SideMenuData(
                          header: Padding(
                            padding:
                                EdgeInsets.only(top: $constants.insets.xs),
                            child: ElevatedContainer(
                              width: 50,
                              height: 50,
                              child: ClipRRect(
                                  borderRadius: BorderRadius.circular(
                                    $constants.corners.md,
                                  ),
                                  child: Image.asset(
                                      "assets/images/appicon.png")),
                            ),
                          ),
                          customChild: SingleChildScrollView(
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                SizedBox(
                                  height: $constants.insets.xs,
                                ),
                                ...primaryMenuItems.map((item) => Column(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        if (item.separatorBefore != true)
                                          SizedBox(
                                            height: $constants.insets.xxs,
                                          ),
                                        if (item.separatorBefore == true)
                                          Padding(
                                            padding: EdgeInsets.symmetric(
                                              horizontal:
                                                  $constants.insets.sm,
                                            ),
                                            child: Divider(
                                              color: Colors.grey.shade300,
                                              thickness: 2,
                                            ),
                                          ),
                                        GestureDetector(
                                          onTap: () {
                                            if (item.onTap != null) {
                                              item.onTap!(0);
                                              return;
                                            }
                                            context
                                                .read<AppCubit>()
                                                .changePrimaryMenuSelectedKey(
                                                  key: (item.key as ValueKey)
                                                      .value,
                                                );
                                            if (item.mainSecondaryKey !=
                                                null) {
                                              context
                                                  .read<AppCubit>()
                                                  .changeSecondaryMenuSelectedKey(
                                                    key: item
                                                        .mainSecondaryKey!,
                                                  );
                                            }
                                          },
                                          child: Padding(
                                            padding: EdgeInsets.symmetric(
                                                horizontal:
                                                    $constants.insets.sm),
                                            child: Row(
                                              children: [
                                                Column(
                                                  mainAxisSize:
                                                      MainAxisSize.min,
                                                  children: [
                                                    Container(
                                                      width: 40,
                                                      height: 40,
                                                      decoration:
                                                          BoxDecoration(
                                                        border: appState
                                                                    .primaryMenuSelectedKey ==
                                                                (item.key
                                                                        as ValueKey)
                                                                    .value
                                                            ? Border.all(
                                                                color: Colors
                                                                    .grey
                                                                    .shade500,
                                                                width: 1,
                                                              )
                                                            : null,
                                                        color: item.color !=
                                                                null
                                                            ? item.color!
                                                                .withValues(
                                                                    alpha:
                                                                        0.1)
                                                            : Colors
                                                                .grey.shade500
                                                                .withValues(
                                                                    alpha:
                                                                        0.2),
                                                        borderRadius:
                                                            BorderRadius
                                                                .circular(
                                                                    $constants
                                                                        .corners
                                                                        .lg),
                                                      ),
                                                      child: item.initialsOnly ==
                                                              true
                                                          ? Center(
                                                              child: Text(
                                                                _getInitials(
                                                                    item.label),
                                                                style: getTextTheme(
                                                                        context)
                                                                    .bodyLarge!
                                                                    .copyWith(
                                                                      fontWeight:
                                                                          FontWeight.bold,
                                                                      color: item.color !=
                                                                              null
                                                                          ? item.color!
                                                                          : Colors.grey.shade800,
                                                                    ),
                                                              ),
                                                            )
                                                          : IconTheme(
                                                              data:
                                                                  IconThemeData(
                                                                color: item.color !=
                                                                        null
                                                                    ? item
                                                                        .color!
                                                                    : Colors
                                                                        .grey
                                                                        .shade800,
                                                              ),
                                                              child: isApple(
                                                                      context)
                                                                  ? Icon(item
                                                                      .cupertinoIcon)
                                                                  : Icon(item
                                                                      .icon)),
                                                    ),
                                                  ],
                                                ),
                                                SizedBox(
                                                  width: $constants.insets.sm,
                                                ),
                                                Text(item.label)
                                              ],
                                            ),
                                          ),
                                        ),
                                      ],
                                    ))
                              ],
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ),
              ),
              Expanded(
                child: Flex(
                  direction: Axis.horizontal,
                  children: [
                    // secodary menu items
                    if (secondarySection != null &&
                        secondarySection.items.isNotEmpty)
                      SizedBox(
                        width: 80,
                        child: SideMenu(
                          controller: _secondarySideMenuController,
                          minWidth: getSize(context).width * 0.08,
                          hasResizer: false,
                          hasResizerToggle: false,
                          builder: (data) {
                            return SideMenuData(
                              customChild: SingleChildScrollView(
                                child: Column(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    SizedBox(
                                      height: $constants.insets.sm,
                                    ),
                                    ...secondarySection.items.map((item) =>
                                        Column(
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            if (item.separatorBefore != true)
                                              SizedBox(
                                                height: $constants.insets.xxs,
                                              ),
                                            if (item.separatorBefore == true)
                                              Padding(
                                                padding: EdgeInsets.symmetric(
                                                  horizontal:
                                                      $constants.insets.sm,
                                                ),
                                                child: Divider(
                                                  color: Colors.grey.shade300,
                                                  thickness: 2,
                                                ),
                                              ),
                                            GestureDetector(
                                              onTap: () {
                                                if (item.onTap != null) {
                                                  item.onTap!(0);
                                                } else {
                                                  context
                                                      .read<AppCubit>()
                                                      .changeSecondaryMenuSelectedKey(
                                                        key: (item.key
                                                                as ValueKey)
                                                            .value,
                                                      );
                                                }
                                                if (!isDesktop(context)) {
                                                  Navigator.of(context).pop();
                                                }
                                              },
                                              child: Column(
                                                mainAxisSize:
                                                    MainAxisSize.min,
                                                children: [
                                                  Container(
                                                    width: 50,
                                                    height: 50,
                                                    decoration: BoxDecoration(
                                                      border: appState
                                                                  .secondaryMenuSelectedKey ==
                                                              (item.key
                                                                      as ValueKey)
                                                                  .value
                                                          ? Border.all(
                                                              color: Colors
                                                                  .grey
                                                                  .shade500,
                                                              width: 1,
                                                            )
                                                          : null,
                                                      color: item.color !=
                                                              null
                                                          ? item.color!
                                                              .withValues(
                                                                  alpha: 0.1)
                                                          : Colors
                                                              .grey.shade500
                                                              .withValues(
                                                                  alpha: 0.2),
                                                      borderRadius:
                                                          BorderRadius
                                                              .circular(
                                                                  $constants
                                                                      .corners
                                                                      .lg),
                                                    ),
                                                    child: item.initialsOnly ==
                                                            true
                                                        ? Center(
                                                            child: Text(
                                                              _getInitials(
                                                                  item.label),
                                                              style: getTextTheme(
                                                                      context)
                                                                  .bodyLarge!
                                                                  .copyWith(
                                                                    fontWeight:
                                                                        FontWeight
                                                                            .bold,
                                                                    color: item.color !=
                                                                            null
                                                                        ? item
                                                                            .color!
                                                                        : Colors
                                                                            .grey
                                                                            .shade800,
                                                                  ),
                                                            ),
                                                          )
                                                        : IconTheme(
                                                            data:
                                                                IconThemeData(
                                                              color: item.color !=
                                                                      null
                                                                  ? item
                                                                      .color!
                                                                  : Colors
                                                                      .grey
                                                                      .shade800,
                                                            ),
                                                            child: isApple(
                                                                    context)
                                                                ? Icon(item
                                                                    .cupertinoIcon)
                                                                : Icon(item
                                                                    .icon)),
                                                  ),
                                                ],
                                              ),
                                            ),
                                          ],
                                        ))
                                  ],
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                    Expanded(
                      child: Scaffold(
                        // if there's secondary, show the secondary item appBar
                        // else show the primary appBar
                        appBar: appBar,
                        // if there's secondary, show the secondary item body
                        // else show the primary item body
                        body: body,
                      ),
                    ),
                  ],
                ),
              )
            ],
          );
        
          if (!kIsWeb && Platform.isMacOS) {
            return TitlebarSafeArea(child: renderedBody);
          }
          return SafeArea(child: renderedBody);
        });
      },
    );
  }

  _runAppInitAndChecks({
    required BuildContext context,
    required AppState appState,
    required AuthState authState,
  }) {
    if (authState is LoggedIn) {
      encryptionService ??= EncryptionService(
        userSalt: authState.user!.keySet.salt,
        prefs: prefs!,
        userKey: userKey,
        agePublicKey: agePublicKey,
      );
      if (isPaymentSupported()) revenueCatService?.logIn(authState.user!.id!);
    }

    // if the user is logged out, show the login modal
    if (authState is LoggedOut && !_isLoginModalVisible) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (isPaymentSupported()) revenueCatService?.logOut();
        _showLoginModal(context);
      });
    }
  }

  void _showLoginModal(BuildContext context) {
    if (kIsWeb || Platform.isMacOS || Platform.isWindows || Platform.isLinux) {
      showDialog(
          context: context,
          barrierDismissible: false,
          builder: (context) => Dialog(
                child: SizedBox(
                  width: getSize(context).width * 0.5,
                  child: LoginOrRegisterModal(
                    encryptionService: encryptionService!,
                    globalApiClient: globalApiClient!,
                    prefs: prefs!,
                    env: env!,
                    onAuthSuccess: () => setState(() {
                      _isLoginModalVisible = false;
                    }),
                  ),
                ),
              ));
    } else {
      showModalBottomSheet(
        isDismissible: false,
        isScrollControlled: true,
        enableDrag: false,
        context: context,
        builder: (context) => SizedBox(
          height: getSize(context).height * 0.88,
          child: LoginOrRegisterModal(
            encryptionService: encryptionService,
            globalApiClient: globalApiClient,
            prefs: prefs!,
            env: env!,
            onAuthSuccess: () => setState(() {
              _isLoginModalVisible = false;
            }),
          ),
        ),
      );
    }
    setState(() {
      _isLoginModalVisible = true;
    });
  }

  String _getInitials(String name) {
    if (name.isEmpty) return '';

    return name
        .trim()
        .split(' ')
        .where((word) => word.isNotEmpty)
        .take(3)
        .map((word) => word[0].toUpperCase())
        .join();
  }
}
