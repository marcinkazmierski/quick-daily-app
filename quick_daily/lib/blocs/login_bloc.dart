import 'dart:async';
import 'dart:io';
import 'package:equatable/equatable.dart';
import 'package:bloc/bloc.dart';
import 'package:quick_daily/repositories/api_repository.dart';
import 'package:quick_daily/blocs/authentication_bloc.dart';

///STATE
abstract class LoginState extends Equatable {
  const LoginState();

  @override
  List<Object> get props => [];
}

class LoginInitial extends LoginState {}

class LoginLoading extends LoginState {}

class LoginFailure extends LoginState {
  final String error;

  const LoginFailure({this.error});

  @override
  List<Object> get props => [error];

  @override
  String toString() => 'LoginFailure { error: $error }';
}

///EVENT
abstract class LoginEvent extends Equatable {
  const LoginEvent();
}

class LoginButtonPressed extends LoginEvent {
  final String username;
  final String password;

  const LoginButtonPressed({
    this.username,
    this.password,
  });

  @override
  List<Object> get props => [username, password];

  @override
  String toString() =>
      'LoginButtonPressed { username: $username, password: $password }';
}

/// BLOC
class LoginBloc extends Bloc<LoginEvent, LoginState> {
  final ApiRepository apiRepository;
  final AuthenticationBloc authenticationBloc;

  LoginBloc({
    this.apiRepository,
    this.authenticationBloc,
  })  : assert(apiRepository != null),
        assert(authenticationBloc != null);

  @override
  LoginState get initialState => LoginInitial();

  @override
  Stream<LoginState> mapEventToState(LoginEvent event) async* {
    if (event is LoginButtonPressed) {
      yield LoginLoading();

      try {
        final token = await apiRepository.authenticate(
          username: event.username,
          password: event.password,
        );

        authenticationBloc.add(LoggedIn(token: token));
        yield LoginInitial();
      } on SocketException catch (error) {
        yield LoginFailure(error: "No internet is available");
      } catch (error) {
        yield LoginFailure(error: error.toString());
      }
    }
  }
}
