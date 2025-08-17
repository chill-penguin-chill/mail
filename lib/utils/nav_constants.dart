import 'package:ab_shared/blocs/auth/auth.bloc.dart';
import 'package:ab_shared/components/app/ab_navbar.dart';
import 'package:mail/i18n/strings.g.dart';
import 'package:mail/pages/more/more.dart';
import 'package:mail/services/sync.service.dart';
import 'package:ab_shared/utils/shortcuts.dart';
import 'package:flutter/cupertino.dart';
import 'package:ab_shared/utils/constants.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:icons_plus/icons_plus.dart';

final $navConstants = NavConstants();

@immutable
class NavConstants {
  List<NavigationSection> secondaryMenuSections(BuildContext context) => [
        const NavigationSection(
          key: Key("notes"),
          items: [],
        ),
        const NavigationSection(
          key: Key("calendar"),
          items: [],
        ),
        const NavigationSection(
          key: Key("add_task"),
          items: [],
        ),
        const NavigationSection(
          key: Key("habits"),
          items: [],
        ),
        const NavigationSection(
          key: Key("more"),
          items: [],
        ),
      ];

  // list of fixed items, limited to 5 on mobile
  // on mobile: the rest is added as a grid on the more apps page (last item to the right)
  // on desktop: the more apps page is moved at the end of the menu
  List<NavigationItem> primaryMenuItems(BuildContext context) => [
        NavigationItem(
          key: const Key("page_1"),
          icon: LineAwesome.file,
          cupertinoIcon: CupertinoIcons.doc,
          label: "Page 1",
          body: Container(),
          appBar: AppBar(
            key: const Key("page_1"),
            backgroundColor: getTheme(context).surface,
            leading: Container(),
            title: Text(
              "Page 1",
              style: getTextTheme(context).headlineSmall!.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            actions: [
              BlocBuilder<AuthBloc, AuthState>(builder: (context, authState) {
                return Container();
              }),
            ],
          ),
        ),
        NavigationItem(
          key: const Key("page_2"),
          icon: LineAwesome.search_solid,
          cupertinoIcon: CupertinoIcons.search,
          label: "Page 2",
          body: Container(),
          appBar: AppBar(
              key: const Key("page_2"),
              backgroundColor: getTheme(context).surface,
              surfaceTintColor: getTheme(context).surface,
              leading: Container(),
              title: Text(
                "Page 2",
                style: getTextTheme(context).headlineSmall!.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
              ),
              actions: [
                BlocBuilder<AuthBloc, AuthState>(builder: (context, authState) {
                  return Container();
                })
              ]),
        ),
        NavigationItem(
          key: const Key("page_3"),
          icon: LineAwesome.plus_solid,
          cupertinoIcon: CupertinoIcons.plus_circle_fill,
          label: "Page 3",
          color: getTheme(context).secondary,
          onTap: (index) {
            if (isDesktop(context)) {
              showDialog(
                  context: context,
                  builder: (context) => Dialog(
                        child: SizedBox(
                          height: getSize(context).height * 0.8,
                          width: getSize(context).width * 0.8,
                          child: ClipRRect(
                            borderRadius:
                                BorderRadius.circular($constants.corners.md),
                            child: Container(),
                          ),
                        ),
                      ));
            } else {
              Navigator.push(context,
                  MaterialPageRoute(builder: (context) => Container()));
            }
            SyncService.sync(context);
          },
        ),
        NavigationItem(
          key: const Key("page_4"),
          icon: LineAwesome.filter_solid,
          cupertinoIcon: CupertinoIcons.square_fill_line_vertical_square,
          label: "Page 4",
          body: Container(),
          appBar: AppBar(
              key: const Key("page_4"),
              backgroundColor: getTheme(context).surfaceContainer,
              leading: Container(),
              title: Text(
                "Page 4",
                style: getTextTheme(context).headlineSmall!.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
              ),
              actions: [
                BlocBuilder<AuthBloc, AuthState>(builder: (context, authState) {
                  return Container();
                })
              ]),
        ),
        NavigationItem(
          key: const Key("more"),
          icon: CupertinoIcons.ellipsis_circle_fill,
          cupertinoIcon: CupertinoIcons.ellipsis_circle_fill,
          label: context.t.more.title,
          body: const MoreApps(),
          appBar: AppBar(
              key: const Key("more"),
              backgroundColor: getTheme(context).surface,
              leading: Container(),
              title: Text(
                context.t.more.title,
                style: getTextTheme(context).headlineSmall!.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
              ),
              actions: [
                BlocBuilder<AuthBloc, AuthState>(builder: (context, authState) {
                  return Container();
                })
              ]),
        ),
      ];
}
