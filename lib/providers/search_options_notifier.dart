// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'package:hooks_riverpod/hooks_riverpod.dart';

class SearchOptions {
  final String searchItems;
  final bool caseSensitive;
  final bool wholeWord;
  SearchOptions(
    this.searchItems,
    this.caseSensitive,
    this.wholeWord,
  );

  SearchOptions copyWith({
    String? searchItems,
    bool? caseSensitive,
    bool? wholeWord,
  }) {
    return SearchOptions(
      searchItems ?? this.searchItems,
      caseSensitive ?? this.caseSensitive,
      wholeWord ?? this.wholeWord,
    );
  }

  @override
  String toString() =>
      'SearchOptions(searchItems: $searchItems, caseSensitive: $caseSensitive, )';
}

class SearchOptionsNotifier extends Notifier<SearchOptions> {
  @override
  SearchOptions build() {
    return SearchOptions('', false, false);
  }

  Future<void> setSearchItems(String newString) async {
    state = state.copyWith(searchItems: newString);
  }

  Future<void> setCaseSensitiv(bool newBool) async {
    state = state.copyWith(caseSensitive: newBool);
  }

  Future<void> setWholeWord(bool newBool) async {
    state = state.copyWith(wholeWord: newBool);
  }

}

final searchOptionsProvider =
    NotifierProvider<SearchOptionsNotifier, SearchOptions>(
        SearchOptionsNotifier.new);
