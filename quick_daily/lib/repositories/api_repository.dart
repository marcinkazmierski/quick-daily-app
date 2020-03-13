import 'dart:async';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:quick_daily/common/exceptions/validator_exception.dart';
import 'package:quick_daily/common/keystore.dart';
import 'package:quick_daily/models/team.dart';
import 'package:quick_daily/models/user.dart';
import 'package:random_string/random_string.dart';
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

    String userToken = '';
    await Keystore().get(USER_AUTH_TOKEN).then((token) {
      userToken = token.toString();
    });

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
