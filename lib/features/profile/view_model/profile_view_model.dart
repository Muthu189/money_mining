import 'package:flutter/material.dart';
import '../../../core/api/api_exception.dart';
import '../data/profile_repository.dart';
import '../data/user_model.dart';

class ProfileViewModel extends ChangeNotifier {
  final ProfileRepository _profileRepository;

  UserModel? _user;
  bool _isLoading = false;
  String? _error;

  UserModel? get user => _user;
  bool get isLoading => _isLoading;
  String? get error => _error;

  ProfileViewModel(this._profileRepository);

  Future<void> fetchUserInfo() async {
    _setLoading(true);
    _error = null;
    try {
      _user = await _profileRepository.fetchUserInfo();
    } on ApiException catch (e) {
      _error = e.message;
    } catch (e) {
      _error = 'Something went wrong. Please try again.';
    } finally {
      _setLoading(false);
    }
  }

  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }
}
