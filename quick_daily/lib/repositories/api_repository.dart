import 'dart:async';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:quick_daily/common/exceptions/validator_exception.dart';
import 'package:quick_daily/common/keystore.dart';
import 'package:quick_daily/models/team.dart';
import 'package:quick_daily/models/user.dart';
import 'dart:io';

class ApiRepository {
  static final USER_AUTH_TOKEN = 'user-auth-token';

  static final API_URL = 'http://192.168.1.204:8106/api/v1/'; // todo: config

  Future<String> authenticate({String username, String password}) async {
    if (username.isEmpty || password.isEmpty) {
      throw new ValidatorException("Username or password is empty!");
    }
    Map data = {'email': username, 'password': password};
    var body = json.encode(data);

    final response = await http.post(API_URL + 'auth/authenticate',
        headers: {
          HttpHeaders.contentTypeHeader: "application/json",
        },
        body: body);
    Map decoded = jsonDecode(response.body);

    if (response.statusCode == 200) {
      return decoded['token'];
    } else {
      throw Exception(decoded['error']['userMessage']);
    }
  }

  Future<void> deleteToken() async {
    /// delete from keystore/keychain
    Keystore().set(USER_AUTH_TOKEN, null);
    return;
  }

  Future<void> persistToken(String token) async {
    /// write to keystore/keychain
    Keystore().set(USER_AUTH_TOKEN, token);
    return;
  }

  Future<bool> hasToken() async {
    /// read from keystore/keychain
    bool hasToken = false;
    await Keystore().get(USER_AUTH_TOKEN).then((token) {
      hasToken = token.toString().isNotEmpty;
    });

    return hasToken;
  }

  Future<List<Team>> getTeams() async {
    List<Team> teams = new List<Team>();

    String userToken = await _getUserToken();

    final response = await http.get(API_URL + 'teams', headers: {
      HttpHeaders.contentTypeHeader: "application/json",
      "X-AUTH-TOKEN": userToken,
    });
    Map decoded = jsonDecode(response.body);

    if (response.statusCode == 200) {
      List<dynamic> list = decoded['teams'];
      teams = list.map((i) => Team.fromJson(i)).toList();
    } else {
      throw Exception(decoded['error']['userMessage']);
    }

    return teams;
  }

  Future<User> getUserByUid(String uid) async {
    String userToken = await _getUserToken();
    // await Future.delayed(Duration(seconds: 1));
    int retry = 3;
    while (retry > 0) {
      print(">>> retry: " + retry.toString());
      final response = await http.get(API_URL + 'users/' + uid, headers: {
        HttpHeaders.contentTypeHeader: "application/json",
        "X-AUTH-TOKEN": userToken,
      });
      Map decoded = jsonDecode(response.body);
      if (response.statusCode == 200) {
        return User.fromJson(decoded);
      }
      retry--;
      if (retry == 0) {
        throw Exception(decoded['error']['userMessage']);
      }
      await Future.delayed(Duration(seconds: 1));
    }

    throw Exception("Get user profile - general error!");
  }

  Future<void> initCall(Team team, String callId) async {
    if (callId.isEmpty) {
      throw new ValidatorException("callId is empty!");
    }
    String userToken = await _getUserToken();
    Map data = {'callId': callId, 'teamId': team.id};
    var body = json.encode(data);

    final response = await http.post(API_URL + 'users/call',
        headers: {
          HttpHeaders.contentTypeHeader: "application/json",
          "X-AUTH-TOKEN": userToken,
        },
        body: body);

    if (response.statusCode == 204) {
      return;
    } else {
      Map decoded = jsonDecode(response.body);
      throw Exception(decoded['error']['userMessage']);
    }
  }

  Future<String> _getUserToken() async {
    String userToken = '';
    await Keystore().get(USER_AUTH_TOKEN).then((token) {
      userToken = token.toString();
    });
    return userToken;
  }
}
