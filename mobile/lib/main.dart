import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:immich_mobile/constants/immich_colors.dart';
import 'package:immich_mobile/modules/backup/models/hive_backup_albums.model.dart';
import 'package:immich_mobile/modules/login/models/hive_saved_login_info.model.dart';
import 'package:immich_mobile/shared/providers/asset.provider.dart';
import 'package:immich_mobile/routing/router.dart';
import 'package:immich_mobile/routing/tab_navigation_observer.dart';
import 'package:immich_mobile/shared/providers/app_state.provider.dart';
import 'package:immich_mobile/modules/backup/providers/backup.provider.dart';
import 'package:immich_mobile/shared/providers/server_info.provider.dart';
import 'package:immich_mobile/shared/providers/websocket.provider.dart';
import 'package:immich_mobile/shared/views/immich_loading_overlay.dart';
import 'constants/hive_box.dart';

void main() async {
  await Hive.initFlutter();

  Hive.registerAdapter(HiveSavedLoginInfoAdapter());
  Hive.registerAdapter(HiveBackupAlbumsAdapter());

  await Hive.openBox(userInfoBox);
  await Hive.openBox<HiveSavedLoginInfo>(hiveLoginInfoBox);
  await Hive.openBox<HiveBackupAlbums>(hiveBackupInfoBox);

  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarIconBrightness: Brightness.light,
    ),
  );

  runApp(const ProviderScope(child: ImmichApp()));
}

class ImmichApp extends ConsumerStatefulWidget {
  const ImmichApp({Key? key}) : super(key: key);

  @override
  _ImmichAppState createState() => _ImmichAppState();
}

class _ImmichAppState extends ConsumerState<ImmichApp> with WidgetsBindingObserver {
  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    switch (state) {
      case AppLifecycleState.resumed:
        debugPrint("[APP STATE] resumed");
        ref.watch(appStateProvider.notifier).state = AppStateEnum.resumed;
        ref.watch(backupProvider.notifier).resumeBackup();
        ref.watch(websocketProvider.notifier).connect();
        ref.watch(assetProvider.notifier).getAllAsset();
        ref.watch(serverInfoProvider.notifier).getServerVersion();

        break;

      case AppLifecycleState.inactive:
        debugPrint("[APP STATE] inactive");
        ref.watch(appStateProvider.notifier).state = AppStateEnum.inactive;
        ref.watch(websocketProvider.notifier).disconnect();
        ref.watch(backupProvider.notifier).cancelBackup();

        break;

      case AppLifecycleState.paused:
        debugPrint("[APP STATE] paused");
        ref.watch(appStateProvider.notifier).state = AppStateEnum.paused;
        break;

      case AppLifecycleState.detached:
        debugPrint("[APP STATE] detached");
        ref.watch(appStateProvider.notifier).state = AppStateEnum.detached;
        break;
    }
  }

  Future<void> initApp() async {
    WidgetsBinding.instance?.addObserver(this);
  }

  @override
  initState() {
    super.initState();
    initApp().then((_) => debugPrint("App Init Completed"));
  }

  @override
  void dispose() {
    WidgetsBinding.instance?.removeObserver(this);
    super.dispose();
  }

  final _immichRouter = AppRouter();

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Stack(
        children: [
          MaterialApp.router(
            title: 'Immich',
            debugShowCheckedModeBanner: false,
            theme: ThemeData(
              brightness: Brightness.light,
              primarySwatch: Colors.indigo,
              fontFamily: 'WorkSans',
              snackBarTheme: const SnackBarThemeData(contentTextStyle: TextStyle(fontFamily: 'WorkSans')),
              scaffoldBackgroundColor: immichBackgroundColor,
              appBarTheme: const AppBarTheme(
                backgroundColor: immichBackgroundColor,
                foregroundColor: Colors.indigo,
                elevation: 1,
                centerTitle: true,
                systemOverlayStyle: SystemUiOverlayStyle.dark,
              ),
            ),
            routeInformationParser: _immichRouter.defaultRouteParser(),
            routerDelegate: _immichRouter.delegate(navigatorObservers: () => [TabNavigationObserver(ref: ref)]),
          ),
          const ImmichLoadingOverlay(),
        ],
      ),
    );
  }
}
