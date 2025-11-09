import 'dart:convert';
import 'dart:typed_data';
import 'package:crypto/crypto.dart';
import 'package:encrypt/encrypt.dart' as encrypt_lib;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:logger/logger.dart';

/// Service for handling all encryption operations
/// Uses AES-256-GCM for encryption
class EncryptionService {
  static final EncryptionService _instance = EncryptionService._internal();
  factory EncryptionService() => _instance;
  EncryptionService._internal();

  final _secureStorage = const FlutterSecureStorage();
  final _logger = Logger();

  static const String _masterKeyKey = 'master_encryption_key';
  static const String _saltKey = 'encryption_salt';

  encrypt_lib.Key? _masterKey;
  String? _salt;

  /// Initialize encryption service
  Future<void> initialize() async {
    try {
      // Try to load existing master key
      final existingKey = await _secureStorage.read(key: _masterKeyKey);
      final existingSalt = await _secureStorage.read(key: _saltKey);

      if (existingKey != null) {
        _masterKey = encrypt_lib.Key.fromBase64(existingKey);
        _salt = existingSalt;
        _logger.i('Encryption service initialized with existing key');
      } else {
        // Generate new master key
        await _generateNewMasterKey();
        _logger.i('Encryption service initialized with new key');
      }
    } catch (e) {
      _logger.e('Error initializing encryption service', error: e);
      rethrow;
    }
  }

  /// Alias for initialize (for compatibility)
  Future<void> init() async {
    await initialize();
  }

  /// Generate a new master encryption key
  Future<void> _generateNewMasterKey() async {
    try {
      _masterKey = encrypt_lib.Key.fromSecureRandom(32); // 256 bits
      _salt = _generateSalt();

      await _secureStorage.write(
        key: _masterKeyKey,
        value: _masterKey!.base64,
      );
      await _secureStorage.write(
        key: _saltKey,
        value: _salt,
      );
    } catch (e) {
      _logger.e('Error generating master key', error: e);
      rethrow;
    }
  }

  /// Generate a random salt
  String _generateSalt({int length = 32}) {
    final random = encrypt_lib.Key.fromSecureRandom(length);
    return random.base64;
  }

  /// Encrypt a string
  Future<String> encryptString(String plainText) async {
    try {
      if (_masterKey == null) {
        await initialize();
      }

      final iv = encrypt_lib.IV.fromSecureRandom(16);
      final encrypter = encrypt_lib.Encrypter(
        encrypt_lib.AES(_masterKey!, mode: encrypt_lib.AESMode.gcm),
      );

      final encrypted = encrypter.encrypt(plainText, iv: iv);

      // Combine IV and encrypted data
      final combined = '${iv.base64}:${encrypted.base64}';
      return combined;
    } catch (e) {
      _logger.e('Error encrypting string', error: e);
      rethrow;
    }
  }

  /// Decrypt a string
  Future<String> decryptString(String encryptedText) async {
    try {
      if (_masterKey == null) {
        await initialize();
      }

      // Split IV and encrypted data
      final parts = encryptedText.split(':');
      if (parts.length != 2) {
        throw Exception('Invalid encrypted data format');
      }

      final iv = encrypt_lib.IV.fromBase64(parts[0]);
      final encrypted = encrypt_lib.Encrypted.fromBase64(parts[1]);

      final encrypter = encrypt_lib.Encrypter(
        encrypt_lib.AES(_masterKey!, mode: encrypt_lib.AESMode.gcm),
      );

      final decrypted = encrypter.decrypt(encrypted, iv: iv);
      return decrypted;
    } catch (e) {
      _logger.e('Error decrypting string', error: e);
      rethrow;
    }
  }

  /// Encrypt bytes (for files)
  Future<Uint8List> encryptBytes(Uint8List plainBytes) async {
    try {
      if (_masterKey == null) {
        await initialize();
      }

      final iv = encrypt_lib.IV.fromSecureRandom(16);
      final encrypter = encrypt_lib.Encrypter(
        encrypt_lib.AES(_masterKey!, mode: encrypt_lib.AESMode.gcm),
      );

      final encrypted = encrypter.encryptBytes(plainBytes, iv: iv);

      // Prepend IV to encrypted data
      final result = Uint8List(iv.bytes.length + encrypted.bytes.length);
      result.setAll(0, iv.bytes);
      result.setAll(iv.bytes.length, encrypted.bytes);

      return result;
    } catch (e) {
      _logger.e('Error encrypting bytes', error: e);
      rethrow;
    }
  }

  /// Decrypt bytes (for files)
  Future<Uint8List> decryptBytes(Uint8List encryptedBytes) async {
    try {
      if (_masterKey == null) {
        await initialize();
      }

      // Extract IV (first 16 bytes)
      final iv = encrypt_lib.IV(encryptedBytes.sublist(0, 16));
      final encrypted = encrypt_lib.Encrypted(encryptedBytes.sublist(16));

      final encrypter = encrypt_lib.Encrypter(
        encrypt_lib.AES(_masterKey!, mode: encrypt_lib.AESMode.gcm),
      );

      final decrypted = encrypter.decryptBytes(encrypted, iv: iv);
      return Uint8List.fromList(decrypted);
    } catch (e) {
      _logger.e('Error decrypting bytes', error: e);
      rethrow;
    }
  }

  /// Hash a password with salt using SHA-256
  String hashPassword(String password, {String? customSalt}) {
    try {
      final salt = customSalt ?? _salt ?? _generateSalt();
      final bytes = utf8.encode(password + salt);
      final digest = sha256.convert(bytes);
      return '${digest.toString()}:$salt';
    } catch (e) {
      _logger.e('Error hashing password', error: e);
      rethrow;
    }
  }

  /// Verify a password against a hash
  bool verifyPassword(String password, String hashedPassword) {
    try {
      final parts = hashedPassword.split(':');
      if (parts.length != 2) {
        return false;
      }

      final hash = parts[0];
      final salt = parts[1];

      final bytes = utf8.encode(password + salt);
      final digest = sha256.convert(bytes);

      return digest.toString() == hash;
    } catch (e) {
      _logger.e('Error verifying password', error: e);
      return false;
    }
  }

  /// Generate a secure random PIN
  String generateSecurePin(int length) {
    final random = encrypt_lib.Key.fromSecureRandom(length);
    final bytes = random.bytes;

    // Convert bytes to digits
    final pin = bytes.take(length).map((b) => b % 10).join();
    return pin;
  }

  /// Clear all encryption keys (use with caution!)
  Future<void> clearKeys() async {
    try {
      await _secureStorage.delete(key: _masterKeyKey);
      await _secureStorage.delete(key: _saltKey);
      _masterKey = null;
      _salt = null;
      _logger.w('All encryption keys cleared');
    } catch (e) {
      _logger.e('Error clearing keys', error: e);
      rethrow;
    }
  }

  /// Check if master key exists
  Future<bool> hasMasterKey() async {
    final key = await _secureStorage.read(key: _masterKeyKey);
    return key != null;
  }
}
