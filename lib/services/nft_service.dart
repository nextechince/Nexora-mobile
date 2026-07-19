import 'package:web3dart/web3dart.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class NFTService {
  Future<List<Map<String, dynamic>>> getNFTs(String address) async {
    final response = await http.get(
      Uri.parse('https://api.alchemy.com/nft/v3/your-api-key/nft/$address/nfts'),
    );
    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return (data['nfts'] as List).map((nft) => {
        'contract_address': nft['contract']['address'],
        'token_id': nft['id']['tokenId'],
        'name': nft['title'] ?? 'Unnamed NFT',
        'description': nft['description'] ?? '',
        'image_url': nft['media'][0]['gateway'] ?? '',
        'owner': address,
        'attributes': nft['metadata']['attributes'] ?? [],
        'floor_price': _getFloorPrice(nft['contract']['address']),
      }).toList();
    }
    return [];
  }

  Future<Map<String, dynamic>> getNFTDetail(
    String contractAddress,
    String tokenId,
  ) async {
    final response = await http.get(
      Uri.parse('https://api.alchemy.com/nft/v3/your-api-key/nft/$contractAddress/$tokenId'),
    );
    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    }
    return {};
  }

  double _getFloorPrice(String contractAddress) {
    // Implement floor price retrieval
    return 0.0;
  }

  Future<String> transferNFT({
    required String fromAddress,
    required String toAddress,
    required String contractAddress,
    required String tokenId,
    required String privateKey,
  }) async {
    // Implement NFT transfer
    return '0xtxhash...';
  }

  Future<Map<String, dynamic>> getCollection(String contractAddress) async {
    final response = await http.get(
      Uri.parse('https://api.opensea.io/api/v1/collection/${contractAddress.toLowerCase()}'),
      headers: {'X-API-KEY': Env.openSeaApiKey},
    );
    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    }
    return {};
  }

  Future<Map<String, dynamic>> getMarketData(String contractAddress) async {
    final response = await http.get(
      Uri.parse('https://api.opensea.io/api/v1/asset/${contractAddress}/stats'),
      headers: {'X-API-KEY': Env.openSeaApiKey},
    );
    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    }
    return {};
  }

  Future<bool> verifyOwnership(String address, String contractAddress, String tokenId) async {
    final nfts = await getNFTs(address);
    return nfts.any((nft) => nft['contract_address'] == contractAddress && nft['token_id'] == tokenId);
  }

  Future<Map<String, dynamic>> getRoyaltyInfo(String contractAddress) async {
    final response = await http.get(
      Uri.parse('https://api.opensea.io/api/v1/asset/${contractAddress}/royalty'),
      headers: {'X-API-KEY': Env.openSeaApiKey},
    );
    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    }
    return {'royalty': 0.0};
  }
}