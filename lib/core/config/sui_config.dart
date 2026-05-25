/// Sui network for mobile (matches backend + web dapp-kit).
/// Override at build: --dart-define=SUI_NETWORK=testnet
abstract final class SuiConfig {
  static const String network =
      String.fromEnvironment('SUI_NETWORK', defaultValue: 'testnet');

  static const String rpcUrl = String.fromEnvironment(
    'SUI_RPC_URL',
    defaultValue: 'https://fullnode.testnet.sui.io:443',
  );

  static const String explorerBase = String.fromEnvironment(
    'SUI_EXPLORER_BASE',
    defaultValue: 'https://suiscan.xyz/testnet',
  );

  static String get label {
    switch (network.toLowerCase()) {
      case 'mainnet':
        return 'Sui Mainnet';
      case 'devnet':
        return 'Sui Devnet';
      default:
        return 'Sui Testnet';
    }
  }

  static String txUrl(String digest) {
    final d = digest.trim();
    if (d.isEmpty) return explorerBase;
    return '$explorerBase/tx/$d';
  }
}
