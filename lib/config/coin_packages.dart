class CoinPackage {
  final int coins;
  final String priceNaira;
  final String priceUSD;
  const CoinPackage({required this.coins, required this.priceNaira, this.priceUSD = ''});
}

final List<CoinPackage> coinPackages = [
  const CoinPackage(coins: 50, priceNaira: '₦1,500'),
  const CoinPackage(coins: 100, priceNaira: '₦2,000'),
  const CoinPackage(coins: 150, priceNaira: '₦2,500'),
  const CoinPackage(coins: 200, priceNaira: '₦3,000'),
  const CoinPackage(coins: 300, priceNaira: '₦4,000'),
  const CoinPackage(coins: 500, priceNaira: '₦6,000'),
  const CoinPackage(coins: 800, priceNaira: '₦8,000'),
  const CoinPackage(coins: 1000, priceNaira: '₦10,000'),
  const CoinPackage(coins: 2000, priceNaira: '₦18,000'),
  const CoinPackage(coins: 5000, priceNaira: '₦40,000'),
  const CoinPackage(coins: 10000, priceNaira: '₦75,000'),
];

const Map<int, int> premiumCoinCost = {
  1: 200,
  6: 700,
  12: 2000,
};