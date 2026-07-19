import 'dart:convert';
import 'package:web3dart/web3dart.dart';
import 'package:walletconnect_dart/walletconnect_dart.dart';
import 'package:http/http.dart' as http;

class CryptoService {
  late Web3Client _web3Client;
  WalletConnect? _walletConnect;

  CryptoService() {
    _web3Client = Web3Client('https://mainnet.infura.io/v3/${Env.infuraProjectId}', http.Client());
  }

  Future<WalletConnect> connectMetaMask() async {
    final connector = WalletConnect(
      bridge: 'https://bridge.walletconnect.org',
      clientMeta: const PeerMeta(
        name: 'NEXORA CHQT',
        description: 'NEXORA Crypto Wallet',
        url: 'https://nexora.app',
        icons: ['https://nexora.app/icon.png'],
      ),
    );
    _walletConnect = connector;
    await connector.createSession();
    return connector;
  }

  Future<double> getEthBalance(String address) async {
    final balance = await _web3Client.getBalance(await _web3Client.credentialsFromPrivateKey(address));
    return balance.getValueInUnit(EtherUnit.ether);
  }

  Future<double> getTokenBalance(String address, String tokenContract) async {
    // Implement ERC20 balance
    return 0.0;
  }

  Future<String> sendEth({
    required String privateKey,
    required String toAddress,
    required double amount,
  }) async {
    final credentials = await _web3Client.credentialsFromPrivateKey(privateKey);
    final transaction = Transaction(
      to: EthereumAddress.fromHex(toAddress),
      value: EtherAmount.fromUnitAndValue(EtherUnit.ether, amount),
      gasPrice: await _web3Client.getGasPrice(),
    );
    final receipt = await _web3Client.sendTransaction(credentials, transaction, chainId: 1);
    return receipt;
  }

  Future<String> sendToken({
    required String privateKey,
    required String toAddress,
    required double amount,
    required String tokenContract,
  }) async {
    // Implement ERC20 transfer
    return '0x...';
  }

  Future<List<Map<String, dynamic>>> getTransactionHistory(String address) async {
    return [];
  }

  String generateReceiveQR(String address, double amount) {
    return 'ethereum:$address?amount=$amount';
  }

  Future<bool> verifyTransaction(String txHash) async {
    final receipt = await _web3Client.getTransactionReceipt(txHash);
    return receipt != null && receipt.status == 1;
  }

  Future<BigInt> getGasPrice() async {
    return await _web3Client.getGasPrice();
  }

  Future<int> estimateGas(String from, String to, double amount) async {
    return 21000;
  }
}