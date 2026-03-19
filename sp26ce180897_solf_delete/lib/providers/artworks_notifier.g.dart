// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'artworks_notifier.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(ArtworksNotifier)
final artworksProvider = ArtworksNotifierProvider._();

final class ArtworksNotifierProvider
    extends $AsyncNotifierProvider<ArtworksNotifier, List<Artwork>> {
  ArtworksNotifierProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'artworksProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$artworksNotifierHash();

  @$internal
  @override
  ArtworksNotifier create() => ArtworksNotifier();
}

String _$artworksNotifierHash() => r'd064cc5c5d1bb68a79a48dabfb05a8e15b8cdef5';

abstract class _$ArtworksNotifier extends $AsyncNotifier<List<Artwork>> {
  FutureOr<List<Artwork>> build();
  @$mustCallSuper
  @override
  void runBuild() {
    final ref = this.ref as $Ref<AsyncValue<List<Artwork>>, List<Artwork>>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<AsyncValue<List<Artwork>>, List<Artwork>>,
              AsyncValue<List<Artwork>>,
              Object?,
              Object?
            >;
    element.handleCreate(ref, build);
  }
}
