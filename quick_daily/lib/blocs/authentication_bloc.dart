import 'package:equatable/equatable.dart';
import 'package:bloc/bloc.dart';
import 'dart:async';
import 'package:quick_daily/repositories/api_repository.dart';

abstract class AuthenticationState extends Equatable {
  @override
  List<Object> get props => [];
}

// uninitialized - waiting to see if the user is authenticated or not on app start.
// loading - waiting to persist/delete a token
// authenticated - successfully authenticated
// unauthenticated - not authenticated

// if the authentication state was uninitialized, the user might be seeing a splash screen.
// if the authentication state was loading, the user might be seeing a progress indicator.
// if the authentication state was authenticated, the user might see a home screen.
// if the authentication state was unauthenticated, the user might see a login form.

//yield definition:
//By marking a function as async* we are able to use the yield keyword and return a Stream of data. In the above example, we are returning a Stream of integers up to the max integer parameter.
//Every time we yield in an async* function we are pushing that piece of data through the Stream.

/// STATES
class AuthenticationUninitialized extends AuthenticationState {}

class AuthenticationAuthenticated extends AuthenticationState {}

class AuthenticationUnauthenticated extends AuthenticationState {}

class AuthenticationLoading extends AuthenticationState {}

/// EVENTS
abstract class AuthenticationEvent extends Equatable {
  const AuthenticationEvent();

  @override
  List<Object> get props => [];
}

class AppStarted extends AuthenticationEvent {}

class LoggedIn extends AuthenticationEvent {
  final String token;

  const LoggedIn({this.token});

  @override
  List<Object> get props => [token];

  @override
  String toString() => 'LoggedIn { token: $token }';
}

class LoggedOut extends AuthenticationEvent {}

/// BLOC
class AuthenticationBloc
    extends Bloc<AuthenticationEvent, AuthenticationState> {
  final ApiRepository apiRepository;

  AuthenticationBloc({this.apiRepository}) : assert(apiRepository != null);

  @override
  AuthenticationState get initialState => AuthenticationUninitialized();

  @override
  Stream<AuthenticationState> mapEventToState(
      AuthenticationEvent event) async* {
    if (event is AppStarted) {
      final bool hasToken = await apiRepository.hasToken();

      if (hasToken) {
        yield AuthenticationAuthenticated();
      } else {
        yield AuthenticationUnauthenticated();
      }
    }

    if (event is LoggedIn) {
      yield AuthenticationLoading();
      await apiRepository.persistToken(event.token);
      yield AuthenticationAuthenticated();
    }

    if (event is LoggedOut) {
      yield AuthenticationLoading();
      await apiRepository.deleteToken();
      yield AuthenticationUnauthenticated();
    }
  }
}
