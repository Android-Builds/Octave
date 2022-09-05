import 'package:beats/pages/dashboard_page.dart';
import 'package:beats/utils/theme.dart';
import 'package:dynamic_color/dynamic_color.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hive_flutter/adapters.dart';

import 'blocs/search_bloc/search_bloc.dart';
import 'blocs/task_execution_bloc/task_execution_bloc.dart';
import 'utils/player_manager.dart';

Future<void> main() async {
  await PlayerManager.initPlayer();
  WidgetsFlutterBinding.ensureInitialized();
  await Hive.initFlutter();
  await Hive.openBox('favouritePlaylists');
  await Hive.openBox('importedPlaylists');
  // await Hive.openBox('prefs');
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    SystemChrome.setSystemUIOverlayStyle(
        const SystemUiOverlayStyle(statusBarColor: Colors.transparent));
    return MultiBlocProvider(
      providers: [
        BlocProvider(
          create: (context) => SearchBloc(),
        ),
        BlocProvider(
          create: (context) => TaskExecutionBloc(),
        ),
      ],
      child: DynamicColorBuilder(
        builder: (lightDynamic, darkDynamic) {
          return MaterialApp(
            title: 'Beats',
            theme: AppTheme.theme(lightDynamic, Brightness.light),
            darkTheme: AppTheme.theme(darkDynamic, Brightness.dark),
            debugShowCheckedModeBanner: false,
            home: const Dashboard(),
          );
        },
      ),
    );
  }
}
