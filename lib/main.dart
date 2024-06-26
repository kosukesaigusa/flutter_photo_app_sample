import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

void main() {
  runApp(const ProviderScope(child: MaterialApp(home: MainApp())));
}

enum ImageSize { medium, large }

class MainApp extends HookWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    final imagesCount = useState<int>(5);
    final rowsCount = useState<int>(2);
    final optimize = useState<bool>(false);
    final imageSize = useState<ImageSize>(ImageSize.medium);
    return Scaffold(
      appBar: AppBar(
        title: Text('表示件数：${imagesCount.value} 件'),
      ),
      body: GridView.builder(
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: rowsCount.value,
          crossAxisSpacing: 4,
          mainAxisSpacing: 4,
        ),
        itemCount: imagesCount.value,
        itemBuilder: (context, index) {
          final imageUrl =
              'https://photo-app-sample-image-worker.saigusa758cloudy.workers.dev'
              '/${imageSize.value.name}'
              '/${(index + 1).toString().padLeft(3, '0')}.JPG?optimize=${optimize.value}';
          return CachedNetworkImage(
            imageUrl: imageUrl,
            imageBuilder: (context, imageProvider) => AspectRatio(
              aspectRatio: 1,
              child: Image(
                image: imageProvider,
                fit: BoxFit.cover,
              ),
            ),
            placeholder: (_, __) => ColoredBox(
              color: Colors.grey[100]!,
              child: const AspectRatio(aspectRatio: 1),
            ),
            errorWidget: (_, __, ___) => ColoredBox(
              color: Colors.grey[100]!,
              child: const AspectRatio(
                aspectRatio: 1,
                child: Center(child: Icon(Icons.error)),
              ),
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          if (rowsCount.value < 5) {
            rowsCount.value = rowsCount.value + 1;
          } else {
            rowsCount.value = 1;
          }
          ScaffoldMessenger.of(context)
            ..removeCurrentSnackBar()
            ..showSnackBar(
              SnackBar(
                content: Text('列数を ${rowsCount.value} に変更しました。'),
              ),
            );
        },
        child: const Icon(Icons.grid_view_rounded),
      ),
      bottomNavigationBar: BottomAppBar(
        color: Colors.white,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            SegmentedButton<ImageSize>(
              segments: const [
                ButtonSegment<ImageSize>(
                  value: ImageSize.medium,
                  label: Text('中'),
                ),
                ButtonSegment<ImageSize>(
                  value: ImageSize.large,
                  label: Text('大'),
                ),
              ],
              selected: {imageSize.value},
              onSelectionChanged: (value) {
                imageSize.value = value.first;
                ScaffoldMessenger.of(context)
                  ..removeCurrentSnackBar()
                  ..showSnackBar(
                    SnackBar(
                      content: Text('画像サイズを ${value.first.name} に変更しました。'),
                    ),
                  );
              },
            ),
            const VerticalDivider(),
            Switch(
              value: optimize.value,
              onChanged: (value) {
                optimize.value = value;
                if (value) {
                  ScaffoldMessenger.of(context)
                    ..removeCurrentSnackBar()
                    ..showSnackBar(
                      const SnackBar(content: Text('画像サイズ・クオリティの最適化を有効にしました。')),
                    );
                } else {
                  ScaffoldMessenger.of(context)
                    ..removeCurrentSnackBar()
                    ..showSnackBar(
                      const SnackBar(content: Text('画像サイズ・クオリティの最適化を無効にしました。')),
                    );
                }
              },
            ),
            const VerticalDivider(),
            IconButton(
              onPressed: () {
                if (imagesCount.value > 0) {
                  imagesCount.value = imagesCount.value - 5;
                } else {
                  ScaffoldMessenger.of(context)
                    ..removeCurrentSnackBar()
                    ..showSnackBar(
                      const SnackBar(content: Text('これ以上減らせません。')),
                    );
                }
              },
              icon: const Icon(
                Icons.remove,
              ),
            ),
            IconButton(
              onPressed: () {
                if (imagesCount.value < 100) {
                  imagesCount.value = imagesCount.value + 5;
                } else {
                  ScaffoldMessenger.of(context)
                    ..removeCurrentSnackBar()
                    ..showSnackBar(
                      const SnackBar(content: Text('これ以上増やせません。')),
                    );
                }
              },
              icon: const Icon(Icons.add),
            ),
            const VerticalDivider(),
            IconButton(
              onPressed: () async {
                await DefaultCacheManager().emptyCache();
                if (!context.mounted) {
                  return;
                }
                ScaffoldMessenger.of(context)
                  ..removeCurrentSnackBar()
                  ..showSnackBar(
                    const SnackBar(content: Text('キャッシュをクリアしました。')),
                  );
              },
              icon: const Icon(Icons.cached),
            ),
          ],
        ),
      ),
    );
  }
}
