abstract class FavItem {
  bool getFav();
  void addFav();
  void removeFav();
}

List<T> sortFavItems<T extends FavItem>(List<T> items) {
    // Crea una copia de la lista original
    List<T> sortedItems = List.from(items);

    // Ordena la nueva lista
    sortedItems.sort((itemA, itemB) {
      final isAFav = itemA.getFav();
      final isBFav = itemB.getFav();
      if (isAFav && !isBFav) {
        return -1; // itemA va antes
      } else if (!isAFav && isBFav) {
        return 1; // itemB va antes
      } else {
        return 0;
      }
    });

    // Devuelve la lista ordenada
    return sortedItems;
  }