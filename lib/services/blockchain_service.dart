import 'package:ethers/ethers.dart';
import 'package:web3dart/web3dart.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../config/env.dart';

class BlockchainService {
  late Web3Client _web3Client;
  String _providerUrl = 'https://mainnet.infura.io/v3/${Env.infuraProjectId}';

  BlockchainService() {
    _web3Client = Web3Client(_providerUrl, http.Client());
  }

  Future<BigInt> getGasPrice() async {
    return await _web3Client.getGasPrice();
  }

  Future<double> getEthBalance(String address) async {
    final balance = await _web3Client.getBalance(
      await _web3Client.credentialsFromPrivateKey(address),
    );
    return balance.getValueInUnit(EtherUnit.ether);
  }

  Future<double> getTokenBalance({
    required String address,
    required String tokenAddress,
    required int decimals,
  }) async {
    final contract = _web3Client.contract(
      AbiContract(_erc20Abi),
      EthereumAddress.fromHex(tokenAddress),
    );
    final balance = await contract.call('balanceOf', [EthereumAddress.fromHex(address)]);
    return (balance[0] as BigInt).toDouble() / (10 ^ decimals);
  }

  Future<String> sendTransaction({
    required String privateKey,
    required String toAddress,
    required double amount,
    BigInt? gasPrice,
    BigInt? gasLimit,
  }) async {
    final credentials = await _web3Client.credentialsFromPrivateKey(privateKey);
    final transaction = Transaction(
      to: EthereumAddress.fromHex(toAddress),
      value: EtherAmount.fromUnitAndValue(EtherUnit.ether, amount),
      gasPrice: gasPrice ?? await getGasPrice(),
      gasLimit: gasLimit ?? BigInt.from(21000),
    );
    final receipt = await _web3Client.sendTransaction(credentials, transaction, chainId: 1);
    return receipt;
  }

  Future<String> deployContract({
    required String privateKey,
    required String bytecode,
    required List<dynamic> constructorArgs,
  }) async {
    final credentials = await _web3Client.credentialsFromPrivateKey(privateKey);
    final contract = await _web3Client.deployContract(
      AbiContract([]),
      credentials,
      bytecode,
      constructorArgs,
      gasPrice: await getGasPrice(),
    );
    return contract.contractAddress!;
  }

  Future<dynamic> callContract({
    required String contractAddress,
    required String method,
    required List<dynamic> args,
    String? privateKey,
  }) async {
    final contract = _web3Client.contract(
      AbiContract(_erc20Abi),
      EthereumAddress.fromHex(contractAddress),
    );
    if (privateKey != null) {
      final credentials = await _web3Client.credentialsFromPrivateKey(privateKey);
      return await contract.method(method, args, credentials: credentials);
    } else {
      return await contract.call(method, args);
    }
  }

  Future<TransactionReceipt?> getTransactionReceipt(String txHash) async {
    return await _web3Client.getTransactionReceipt(txHash);
  }

  Stream<Map<String, dynamic>> listenToEvents({
    required String contractAddress,
    required String eventName,
  }) {
    final contract = _web3Client.contract(
      AbiContract(_erc20Abi),
      EthereumAddress.fromHex(contractAddress),
    );
    return contract.events(eventName).map((event) => event.toString());
  }

  Future<Map<String, dynamic>> getNFTContract(String contractAddress) async {
    final response = await http.get(
      Uri.parse('https://api.opensea.io/api/v1/asset_contract/$contractAddress'),
      headers: {'X-API-KEY': Env.openSeaApiKey ?? ''},
    );
    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    }
    return {};
  }

  final List<dynamic> _erc20Abi = [
    {
      'constant': true,
      'inputs': [{'name': '_owner', 'type': 'address'}],
      'name': 'balanceOf',
      'outputs': [{'name': 'balance', 'type': 'uint256'}],
      'type': 'function',
    },
    {
      'constant': false,
      'inputs': [
        {'name': '_to', 'type': 'address'},
        {'name': '_value', 'type': 'uint256'},
      ],
      'name': 'transfer',
      'outputs': [{'name': 'success', 'type': 'bool'}],
      'type': 'function',
    },
    {
      'constant': true,
      'inputs': [],
      'name': 'decimals',
      'outputs': [{'name': '', 'type': 'uint8'}],
      'type': 'function',
    },
    {
      'constant': true,
      'inputs': [],
      'name': 'symbol',
      'outputs': [{'name': '', 'type': 'string'}],
      'type': 'function',
    },
  ];
}