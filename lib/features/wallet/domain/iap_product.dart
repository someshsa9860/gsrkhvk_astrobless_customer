/// Represents a wallet top-up product available via in-app purchase.
/// Products are configured in Google Play Console and App Store Connect,
/// then their IDs are hard-coded here to avoid a server round-trip.
class IapProduct {
  const IapProduct({
    required this.productId,
    required this.label,
    required this.amountPaise, // wallet credit in paise (1/100 of ₹1)
    required this.displayPrice, // localized price string, e.g. "₹100"
  });

  final String productId;
  final String label;
  final int amountPaise;
  final String displayPrice;
}

/// Default product catalog — overridden at runtime with store-fetched prices.
/// Product IDs must match exactly what's configured in Play Console / App Store Connect.
const List<IapProduct> kDefaultIapProducts = [
  IapProduct(
    productId: 'wallet_topup_100',
    label: '₹100',
    amountPaise: 10000,
    displayPrice: '₹100',
  ),
  IapProduct(
    productId: 'wallet_topup_200',
    label: '₹200',
    amountPaise: 20000,
    displayPrice: '₹200',
  ),
  IapProduct(
    productId: 'wallet_topup_500',
    label: '₹500',
    amountPaise: 50000,
    displayPrice: '₹500',
  ),
  IapProduct(
    productId: 'wallet_topup_1000',
    label: '₹1,000',
    amountPaise: 100000,
    displayPrice: '₹1000',
  ),
];
