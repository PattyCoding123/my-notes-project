extension Filter<T> on Stream<List<T>> {
  // The filter function will take a "where" test and will
  // map all items in a list into a stream event. Each item will be filtered
  // using the .where method of an iterable and the "where" test.
  // It will put the elements of the item into a list before mapping them.
  // T is passed as the parameter in the "where" test, and the "where" test
  // must return a boolean.
  Stream<List<T>> filter(bool Function(T) where) =>
      map((items) => items.where(where).toList());
}
