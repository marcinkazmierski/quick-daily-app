import 'dart:async';

import 'package:equatable/equatable.dart';
import 'package:bloc/bloc.dart';
import 'package:quick_daily/models/team.dart';
import 'package:quick_daily/models/user.dart';
import 'package:quick_daily/repositories/api_repository.dart';

///STATES
abstract class TeamsState extends Equatable {
  const TeamsState();

  @override
  List<Object> get props => [];
}

class TeamsEmpty extends TeamsState {}

class TeamsLoading extends TeamsState {}

class TeamsLoaded extends TeamsState {
  final List<Team> teams;

  const TeamsLoaded({this.teams});

  @override
  List<Object> get props => [teams];
}

class TeamsError extends TeamsState {
  final String error;

  const TeamsError({this.error});

  @override
  List<Object> get props => [error];

  @override
  String toString() => 'TeamsError { error: $error }';
}

/// EVENTS
abstract class TeamsEvent extends Equatable {
  const TeamsEvent();
}

class FetchTeams extends TeamsEvent {
  final User user;

  const FetchTeams({this.user}) : assert(user != null);

  @override
  List<Object> get props => [user];

  @override
  String toString() => 'FetchTeams { for user: ' + this.user.name + ' }';
}

/// BLOC
class TeamsBloc extends Bloc<TeamsEvent, TeamsState> {
  final ApiRepository apiRepository;

  TeamsBloc({this.apiRepository}) : assert(apiRepository != null);

  @override
  TeamsState get initialState => TeamsEmpty();

  @override
  Stream<TeamsState> mapEventToState(TeamsEvent event) async* {
    if (event is FetchTeams) {
      yield TeamsLoading();
      try {
        final List<Team> teams = await apiRepository.getTeams();
        yield TeamsLoaded(teams: teams);
      } catch (error) {
        yield TeamsError(error: error.toString());
      }
    }
  }
}