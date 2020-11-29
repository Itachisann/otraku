import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:otraku/controllers/collections.dart';
import 'package:otraku/tools/headers/collection_header.dart';
import 'package:otraku/tools/layouts/media_list.dart';
import 'package:otraku/tools/headers/headline_header.dart';

class CollectionsTab extends StatelessWidget {
  final int otherUserId;
  final bool ofAnime;

  CollectionsTab({
    @required this.otherUserId,
    @required this.ofAnime,
    @required key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    Get.find<Collections>().assignCollection(
      ofAnime,
      otherUserId,
    );
    final scrollCtrl = ScrollController();

    return CustomScrollView(
      physics: const BouncingScrollPhysics(
        parent: AlwaysScrollableScrollPhysics(),
      ),
      controller: scrollCtrl,
      slivers: [
        HeadlineHeader('${ofAnime ? 'Anime' : 'Manga'} List', false),
        CollectionHeader(scrollCtrl),
        MediaList(ofAnime),
        SliverToBoxAdapter(
          child: const SizedBox(height: 50),
        ),
      ],
    );
  }
}

class CollectionDrawer extends StatelessWidget {
  const CollectionDrawer();

  @override
  Widget build(BuildContext context) {
    final collection = Get.find<Collections>().collection;
    final names = collection.listNames;
    final counts = collection.listEntryCounts;
    final selected = collection.listIndex;

    return SafeArea(
      child: Container(
        width: MediaQuery.of(context).size.width - 100,
        padding: const EdgeInsets.only(left: 20),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              Theme.of(context).backgroundColor,
              Theme.of(context).backgroundColor.withAlpha(0),
            ],
          ),
        ),
        child: ListView(
          physics: const BouncingScrollPhysics(),
          padding: const EdgeInsets.symmetric(vertical: 35),
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 15),
              child: Text(
                '${collection.totalEntryCount} Total',
                style: Theme.of(context).textTheme.headline4,
              ),
            ),
            for (int i = 0; i < names.length; i++)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 15),
                child: GestureDetector(
                  onTap: () {
                    Navigator.pop(context);
                    if (i != selected) collection.listIndex = i;
                  },
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(names[i],
                          style: i != selected
                              ? Theme.of(context).textTheme.headline3
                              : Theme.of(context).textTheme.headline2),
                      Text(
                        counts[i].toString(),
                        style: Theme.of(context).textTheme.headline4,
                      )
                    ],
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
