import 'package:openfoodfacts/openfoodfacts.dart';

class OpenFoodFactsService {
  Future<List<Product>> searchProducts(String query) async {
    final ProductSearchQueryConfiguration configuration =
        ProductSearchQueryConfiguration(
      parametersList: <Parameter>[
        SearchTerms(terms: [query]),
      ],
      version: ProductQueryVersion.v3,
    );

    final SearchResult result = await OpenFoodAPIClient.searchProducts(
      null,
      configuration,
    );

    return result.products ?? [];
  }
}
