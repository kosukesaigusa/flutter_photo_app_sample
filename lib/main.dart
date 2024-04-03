import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:gap/gap.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

void main() {
  runApp(const ProviderScope(child: MaterialApp(home: MainApp())));
}

class MainApp extends HookWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    final count = useState<int>(5);
    return Scaffold(
      appBar: AppBar(
        title: Text('表示件数：${count.value} 件'),
      ),
      body: GridView.builder(
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 5,
          crossAxisSpacing: 4,
          mainAxisSpacing: 4,
        ),
        itemCount: count.value,
        itemBuilder: (context, index) {
          final imageUrl =
              'https://photo-app-sample-image-worker.saigusa758cloudy.workers.dev/${(index + 1).toString().padLeft(3, '0')}.JPG';
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
      bottomNavigationBar: BottomAppBar(
        color: Colors.white,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            IconButton(
              onPressed: () {
                if (count.value > 0) {
                  count.value = count.value - 5;
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
            const Gap(8),
            IconButton(
              onPressed: () {
                if (count.value < 100) {
                  count.value = count.value + 5;
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
            const Gap(32),
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
              icon: const Icon(Icons.delete),
            ),
          ],
        ),
      ),
    );
  }
}
