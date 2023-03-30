// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'package:hooks_riverpod/hooks_riverpod.dart';

class SearchOptions {
  final String searchWord;
  final bool caseSensitive;
  SearchOptions(
    this.searchWord,
    this.caseSensitive,
  );

  SearchOptions copyWith({
    String? searchWord,
    bool? caseSensitive,
    bool? filterEnabled,
  }) {
    return SearchOptions(
      searchWord ?? this.searchWord,
      caseSensitive ?? this.caseSensitive,
    );
  }

  @override
  String toString() =>
      'SearchOptions(searchWord: $searchWord, caseSensitive: $caseSensitive, )';
}

class SearchOptionsNotifier extends Notifier<SearchOptions> {
  @override
  SearchOptions build() {
    return SearchOptions('', false);
  }

  Future<void> setSearchWord(String newString) async {
    state = state.copyWith(searchWord: newString);
  }

  Future<void> setCaseSensitiv(bool newBool) async {
    state = state.copyWith(caseSensitive: newBool);
  }
}

final searchOptionsProvider =
    NotifierProvider<SearchOptionsNotifier, SearchOptions>(
        SearchOptionsNotifier.new);
