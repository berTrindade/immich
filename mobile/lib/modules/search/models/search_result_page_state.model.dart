import 'dart:convert';

import 'package:collection/collection.dart';
import 'package:immich_mobile/shared/models/immich_asset.model.dart';

class SearchResultPageState {
  final bool isLoading;
  final bool isSuccess;
  final bool isError;
  final List<ImmichAsset> searchResult;

  SearchResultPageState({
    required this.isLoading,
    required this.isSuccess,
    required this.isError,
    required this.searchResult,
  });

  SearchResultPageState copyWith({
    bool? isLoading,
    bool? isSuccess,
    bool? isError,
    List<ImmichAsset>? searchResult,
  }) {
    return SearchResultPageState(
      isLoading: isLoading ?? this.isLoading,
      isSuccess: isSuccess ?? this.isSuccess,
      isError: isError ?? this.isError,
      searchResult: searchResult ?? this.searchResult,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'isLoading': isLoading,
      'isSuccess': isSuccess,
      'isError': isError,
      'searchResult': searchResult.map((x) => x.toMap()).toList(),
    };
  }

  factory SearchResultPageState.fromMap(Map<String, dynamic> map) {
    return SearchResultPageState(
      isLoading: map['isLoading'] ?? false,
      isSuccess: map['isSuccess'] ?? false,
      isError: map['isError'] ?? false,
      searchResult: List<ImmichAsset>.from(map['searchResult']?.map((x) => ImmichAsset.fromMap(x))),
    );
  }

  String toJson() => json.encode(toMap());

  factory SearchResultPageState.fromJson(String source) => SearchResultPageState.fromMap(json.decode(source));

  @override
  String toString() {
    return 'SearchresultPageState(isLoading: $isLoading, isSuccess: $isSuccess, isError: $isError, searchResult: $searchResult)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    final listEquals = const DeepCollectionEquality().equals;

    return other is SearchResultPageState &&
        other.isLoading == isLoading &&
        other.isSuccess == isSuccess &&
        other.isError == isError &&
        listEquals(other.searchResult, searchResult);
  }

  @override
  int get hashCode {
    return isLoading.hashCode ^ isSuccess.hashCode ^ isError.hashCode ^ searchResult.hashCode;
  }
}
