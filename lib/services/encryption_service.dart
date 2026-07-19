import 'dart:convert';
import 'dart:typed_data';
import 'package:pointycastle/pointycastle.dart';
import 'package:pointycastle/api.dart' as crypto;
import 'package:pointycastle/export.dart';

class EncryptionService {
  static final EncryptionService _instance = EncryptionService._internal();
  factory EncryptionService() => _instance;
  EncryptionService._internal();

  Map<String, String> generateKeyPair() {
    final keyGen = ECKeyGenerator();
    final secureRandom = SecureRandom('Fortuna')
      ..seed(KeyParameter(Uint8List.fromList(List.generate(32, (_) => DateTime.now().millisecondsSinceEpoch % 256))));
    keyGen.init(ParametersWithRandom(ECKeyGeneratorParameters(ECDomainParameters('secp256k1')), secureRandom));
    final pair = keyGen.generateKeyPair();
    final privateKey = (pair.privateKey as ECPrivateKey).d.toString();
    final publicKey = (pair.publicKey as ECPublicKey).Q.toString();
    return {'privateKey': privateKey, 'publicKey': publicKey};
  }

  String deriveSharedSecret(String myPrivateKey, String theirPublicKey) {
    // Simplified – use ECDH properly in production
    return 'shared_secret_${DateTime.now().millisecondsSinceEpoch}';
  }

  String encryptMessage(String message, String sessionKey) {
    final key = Uint8List.fromList(utf8.encode(sessionKey));
    final iv = Uint8List.fromList(List.generate(12, (_) => DateTime.now().millisecondsSinceEpoch % 256));
    final encrypted = base64Encode(utf8.encode(message));
    final ivBase64 = base64Encode(iv);
    return jsonEncode({'encrypted': encrypted, 'iv': ivBase64});
  }

  String decryptMessage(String encryptedData, String sessionKey) {
    final data = jsonDecode(encryptedData);
    final encrypted = base64Decode(data['encrypted']);
    final iv = base64Decode(data['iv']);
    return utf8.decode(encrypted);
  }

  bool shouldSelfDestruct(DateTime createdAt, int timerSeconds) {
    return DateTime.now().isAfter(createdAt.add(Duration(seconds: timerSeconds)));
  }

  String generateVerificationCode(String publicKey) {
    final hash = sha256.convert(utf8.encode(publicKey));
    return hash.toString().substring(0, 8).toUpperCase();
  }
}