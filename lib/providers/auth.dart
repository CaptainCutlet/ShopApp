import 'dart:convert';
import 'dart:async';

import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:intl/intl.dart';

import '../models/http_exception.dart';

class Auth with ChangeNotifier {
  String? _token;
  DateTime? _expiryDate;
  String? _userId;
  Timer? _authTimer;

  bool get isLoggedIn {
    // ignore: unnecessary_null_comparison
    return _token != null;
  }

  String? get token {
    // ignore: unnecessary_null_comparison
    if (_expiryDate != null &&
        _token != null &&
        _expiryDate!.isAfter(DateTime.now())) {
      return _token;
    }
    return '';
  }

  String? get userId {
    return _userId;
  }

  Future<void> _authenticate(
      String email, String password, String urlSegment) async {
    final url = Uri.parse(
        'https://identitytoolkit.googleapis.com/v1/accounts:$urlSegment?key=AIzaSyCnVc72fMnPlF11_1OnVA5Zt2J-a85hE6s');
    try {
      final response = await http.post(
        url,
        body: json.encode(
          {
            'password': password,
            'email': email,
            'returnSecureToken': true,
          },
        ),
      );
      final responseDecoded = json.decode(response.body);
      if (responseDecoded['error'] != null) {
        throw HttpException(responseDecoded['error']['message']);
      }
      _token = responseDecoded['idToken'];
      _userId = responseDecoded['localId'];
      _expiryDate = DateTime.now().add(
        Duration(
          seconds: int.parse(responseDecoded['expiresIn']),
        ),
      );
      autoLogout();
      notifyListeners();
      final sharedPreferences = await SharedPreferences.getInstance();
      final userData = json.encode(
        {
          'token': _token,
          'userId': _userId,
          'expiryDate': _expiryDate!.toIso8601String(),
        },
      );
      sharedPreferences.setString('userData', userData);
    } catch (error) {
      throw error;
    }

    notifyListeners();
  }

  Future<void> signup(String email, String password) async {
    return _authenticate(email, password, 'signUp');
  }

  Future<void> login(String email, String password) async {
    return _authenticate(email, password, 'signInWithPassword');
  }

  Future<bool> tryAutoLogin() async {
    final sharedPreferences = await SharedPreferences.getInstance();
    if (sharedPreferences.containsKey('userData') == false) {
      return false;
    }
    final extractedUserData =
        json.decode(sharedPreferences.getString('userData')!)
            as Map<String, String>;
    final expiryDate = DateTime.parse(extractedUserData['expiryDate']!);
    if (expiryDate.isBefore(DateTime.now())) {
      return false;
    }
    _token = extractedUserData['token'];
    _expiryDate = expiryDate;
    _userId = extractedUserData['userId'];
    autoLogout();
    notifyListeners();
    return true;
  }

  Future<void> logout() async {
    _token = null;
    _userId = null;
    _expiryDate = null;
    if (_authTimer != null) {
      _authTimer!.cancel();
      _authTimer = null;
    }
    notifyListeners();
    final sharedPreferences = await SharedPreferences.getInstance();
    sharedPreferences.clear();
  }

  void autoLogout() {
    if (_authTimer != null) {
      _authTimer!.cancel();
    }
    final expiryTime = _expiryDate!.difference(DateTime.now()).inSeconds;
    _authTimer = Timer(Duration(seconds: expiryTime), logout);
  }
}
