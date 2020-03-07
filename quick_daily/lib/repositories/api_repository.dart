import 'dart:async';
import 'package:http/http.dart' as http;
import 'package:quick_daily/models/team.dart';
import 'package:quick_daily/models/user.dart';
import 'package:random_string/random_string.dart';

class ApiRepository {
  Future<String> authenticate({String username, String password}) async {
    await Future.delayed(Duration(seconds: 1));
    return 'token';
  }

  Future<void> deleteToken() async {
    /// delete from keystore/keychain
    await Future.delayed(Duration(seconds: 1));
    return;
  }

  Future<void> persistToken(String token) async {
    /// write to keystore/keychain
    await Future.delayed(Duration(seconds: 1));
    return;
  }

  Future<bool> hasToken() async {
    /// read from keystore/keychain
    await Future.delayed(Duration(seconds: 1));
    return false;
  }

  Future<List<Team>> getTeams() async {
    List<Team> teams = new List<Team>();
    teams.add(Team(
        id: 1,
        name: "Team A",
        description: "Work in Poznań",
        imageUrl:
            "https://d36tnp772eyphs.cloudfront.net/blogs/1/2018/02/Taj-Mahal.jpg"));

    teams.add(Team(
        id: 2,
        name: "Team B",
        description: "Work in Home",
        imageUrl:
            "https://d36tnp772eyphs.cloudfront.net/blogs/1/2016/03/petra-jordan9.jpg"));

    teams.add(Team(
        id: 3,
        name: "Team C",
        description: "Holidays",
        imageUrl:
            "https://d36tnp772eyphs.cloudfront.net/blogs/1/2018/02/Machu-Picchu-around-sunset.jpg"));

    await Future.delayed(Duration(seconds: 1));
    return teams;
  }

  Future<User> getUserByUid(String uid) async {
    User user = new User(
        id: 1,
        externalId: uid,
        name: "John " + randomString(10),
        description: "Holidays",
        imageUrl:
            "https://d36tnp772eyphs.cloudfront.net/blogs/1/2018/02/Machu-Picchu-around-sunset.jpg");
    await Future.delayed(Duration(seconds: 1));
    return user;
  }
}
