import 'package:flutter/material.dart';
import 'package:bloc/bloc.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:quick_daily/ui/login_page.dart';
import 'package:quick_daily/repositories/api_repository.dart';
import 'package:quick_daily/blocs/authentication_bloc.dart';
import 'package:quick_daily/ui/splash_page.dart';
import 'package:quick_daily/common/loading_indicator.dart';
import 'package:quick_daily/ui/teams_page.dart';

class SimpleBlocDelegate extends BlocDelegate {
  @override
  void onEvent(Bloc bloc, Object event) {
    super.onEvent(bloc, event);
    print(event);
  }

  @override
  void onTransition(Bloc bloc, Transition transition) {
    super.onTransition(bloc, transition);
    print(transition);
  }

  @override
  void onError(Bloc bloc, Object error, StackTrace stacktrace) {
    super.onError(bloc, error, stacktrace);
    print(error);
  }
}

void main() {
  BlocSupervisor.delegate = SimpleBlocDelegate();
  final apiRepository = ApiRepository();
  runApp(
    BlocProvider<AuthenticationBloc>(
      create: (context) {
        AuthenticationBloc auth =
            AuthenticationBloc(apiRepository: apiRepository);
        auth.add(AppStarted());
        return auth;
      },
      child: App(apiRepository: apiRepository),
    ),
  );
}

class App extends StatelessWidget {
  final ApiRepository apiRepository;

  App({Key key, this.apiRepository}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: BlocBuilder<AuthenticationBloc, AuthenticationState>(
        builder: (context, state) {
          if (state is AuthenticationAuthenticated) {
            return TeamsPage();
          }
          if (state is AuthenticationUnauthenticated) {
            return LoginPage(apiRepository: apiRepository);
          }
          if (state is AuthenticationLoading) {
            return LoadingIndicator();
          }
          return SplashPage();
        },
      ),
    );
  }
}
