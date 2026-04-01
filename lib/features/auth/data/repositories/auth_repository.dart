import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:cpc_clean_user/core/constants/app_strings.dart';
import 'package:cpc_clean_user/core/constants/firebase_constants.dart';

/// Custom exception for authentication errors with user-facing messages.
sealed class AuthException implements Exception {
  final String message;
  const AuthException(this.message);

  @override
  String toString() => message;
}

class CarNotFoundException extends AuthException {
  const CarNotFoundException() : super(AppStrings.errorCarNotRegistered);
}

class InvalidPasswordException extends AuthException {
  const InvalidPasswordException() : super(AppStrings.errorInvalidPassword);
}

class CarInactiveException extends AuthException {
  const CarInactiveException() : super(AppStrings.errorCarInactive);
}

class AuthNetworkException extends AuthException {
  const AuthNetworkException() : super(AppStrings.errorNetworkFailed);
}

class AuthPermissionDeniedException extends AuthException {
  const AuthPermissionDeniedException()
    : super(AppStrings.errorPermissionDenied);
}

/// Keys used for secure local storage.
class _StorageKeys {
  static const agentName = 'agent_name';
  static const carNumber = 'car_number';
}

/// Repository responsible for authentication logic using
/// Firestore `cars` collection and local secure storage.
class AuthRepository {
  final FirebaseFirestore _firestore;
  final FlutterSecureStorage _secureStorage;

  AuthRepository({
    FirebaseFirestore? firestore,
    FlutterSecureStorage? secureStorage,
  }) : _firestore = firestore ?? FirebaseFirestore.instance,
       _secureStorage = secureStorage ?? const FlutterSecureStorage();

  // ─── Public API ────────────────────────────────────────────────

  /// Authenticates the agent by verifying credentials against the
  /// Firestore `cars` collection (Doc ID = [carNumber]).
  ///
  /// On success: saves credentials locally and updates the car document
  /// with the current agent name.
  Future<bool> login({
    required String agentName,
    required String carNumber,
    required String password,
  }) async {
    try {
      final carDoc = await _firestore
          .collection(FirebaseCollections.cars)
          .doc(carNumber)
          .get();

      if (!carDoc.exists || carDoc.data() == null) {
        throw const CarNotFoundException();
      }

      final data = carDoc.data()!;

      // Validate password
      final storedPassword = data['password'] as String? ?? '';
      if (storedPassword != password) {
        throw const InvalidPasswordException();
      }

      // Validate active status
      final isActive = data['isActive'] as bool? ?? false;
      if (!isActive) {
        throw const CarInactiveException();
      }

      // ── Success: persist locally & update Firestore ──
      await _firestore
          .collection(FirebaseCollections.cars)
          .doc(carNumber)
          .update({
            'currentAgentName': agentName,
            'lastLoginAt': FieldValue.serverTimestamp(),
          });

      await _secureStorage.write(key: _StorageKeys.agentName, value: agentName);
      await _secureStorage.write(key: _StorageKeys.carNumber, value: carNumber);

      return true;
    } on AuthException {
      rethrow; // Already a user-facing exception
    } on FirebaseException catch (e) {
      if (e.code == 'permission-denied') {
        throw const AuthPermissionDeniedException();
      }
      throw const AuthNetworkException();
    } catch (_) {
      throw const AuthNetworkException();
    }
  }

  /// Checks if the car is still active in Firestore.
  /// Returns `true` only if the document exists AND `isActive == true`.
  Future<bool> checkCarStatus(String carNumber) async {
    try {
      final carDoc = await _firestore
          .collection(FirebaseCollections.cars)
          .doc(carNumber)
          .get();

      if (!carDoc.exists || carDoc.data() == null) return false;

      return carDoc.data()!['isActive'] as bool? ?? false;
    } catch (_) {
      return false; // Fail-safe: treat as inactive on error
    }
  }

  /// Clears all locally stored credentials.
  Future<void> logout() async {
    await _secureStorage.deleteAll();
  }

  /// Reads the stored car number from secure storage.
  /// Returns `null` if no session exists.
  Future<String?> getSavedCarNumber() async {
    return _secureStorage.read(key: _StorageKeys.carNumber);
  }

  /// Reads the stored agent name from secure storage.
  Future<String?> getSavedAgentName() async {
    return _secureStorage.read(key: _StorageKeys.agentName);
  }
}
