import 'package:flutter/material.dart';
import 'package:otraku/enums/browsable_enum.dart';
import 'package:otraku/providers/explorable.dart';
import 'package:otraku/providers/view_config.dart';
import 'package:otraku/tools/media_indexer.dart';
import 'package:provider/provider.dart';

class ExploreGrid extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final results = Provider.of<Explorable>(context).results;

    if (results.length == 0) {
      return SliverFillRemaining(
        child: Center(
          child: Text(
            'No results',
            style: Theme.of(context).textTheme.subtitle1,
          ),
        ),
      );
    }

    if (results[0].browsable == Browsable.studios) {
      return SliverPadding(
        padding: const EdgeInsets.only(left: 10, right: 10, top: 15),
        sliver: SliverFixedExtentList(
          delegate: SliverChildBuilderDelegate(
            (_, index) => MediaIndexer(
              itemType: results[index].browsable,
              id: results[index].id,
              heroTitle: results[index].title,
              child: Hero(
                tag: results[index].id,
                child: Container(
                  child: Text(
                    results[index].title,
                    style: Theme.of(context).textTheme.headline3,
                    maxLines: 2,
                  ),
                ),
              ),
            ),
            childCount: results.length,
          ),
          itemExtent: 60,
        ),
      );
    }

    return SliverPadding(
      padding: const EdgeInsets.only(left: 10, right: 10, top: 15),
      sliver: SliverGrid(
        delegate: SliverChildBuilderDelegate(
          (_, index) => MediaIndexer(
            itemType: results[index].browsable,
            id: results[index].id,
            child: _SimpleGridTile(
              mediaId: results[index].id,
              text: results[index].title,
              imageUrl: results[index].imageUrl,
            ),
          ),
          childCount: results.length,
        ),
        gridDelegate: SliverGridDelegateWithMaxCrossAxisExtent(
          maxCrossAxisExtent: ViewConfig.tileConfiguration.tileWidth,
          mainAxisSpacing: 10,
          crossAxisSpacing: 10,
          childAspectRatio: ViewConfig.tileConfiguration.tileWHRatio,
        ),
      ),
    );
  }
}

class _SimpleGridTile extends StatelessWidget {
  final int mediaId;
  final String text;
  final String imageUrl;

  _SimpleGridTile({
    @required this.mediaId,
    @required this.text,
    @required this.imageUrl,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: ViewConfig.tileConfiguration.tileWidth,
      height: ViewConfig.tileConfiguration.tileHeight,
      child: Column(
        children: [
          Hero(
            tag: mediaId,
            child: ClipRRect(
              borderRadius: ViewConfig.BORDER_RADIUS,
              child: Container(
                height: ViewConfig.tileConfiguration.tileImgHeight,
                width: ViewConfig.tileConfiguration.tileWidth,
                color: Theme.of(context).primaryColor,
                child: Image.network(
                  imageUrl,
                  fit: BoxFit.cover,
                ),
              ),
            ),
          ),
          const SizedBox(height: 10),
          Flexible(
            child: Text(
              text,
              overflow: TextOverflow.fade,
              style: Theme.of(context).textTheme.subtitle1,
            ),
          ),
        ],
      ),
    );
  }
}