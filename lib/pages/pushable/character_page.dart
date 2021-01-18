import 'package:fluentui_icons/fluentui_icons.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:otraku/controllers/config.dart';
import 'package:otraku/tools/navigation/bubble_tabs.dart';
import 'package:otraku/tools/navigation/person_header.dart';
import 'package:otraku/controllers/character.dart';
import 'package:otraku/tools/layouts/connections_grid.dart';
import 'package:otraku/tools/overlays/option_sheet.dart';
import 'package:otraku/tools/overlays/sort_sheet.dart';

class CharacterPage extends StatelessWidget {
  final int id;
  final String imageUrl;

  CharacterPage(this.id, this.imageUrl);

  @override
  Widget build(BuildContext context) {
    final character = Get.find<Character>(tag: id.toString());

    return Scaffold(
      body: SafeArea(
        child: CustomScrollView(
          physics: Config.PHYSICS,
          slivers: [
            Obx(() => PersonHeader(
                  character.person,
                  imageUrl,
                  character.toggleFavourite,
                )),
            Obx(() {
              if (character.person == null) return const SliverToBoxAdapter();
              return PersonInfo(character.person);
            }),
            Obx(() {
              if (character.person == null) return const SliverToBoxAdapter();

              return SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.only(bottom: 15),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      if (character.anime.items.isNotEmpty &&
                          character.manga.items.isNotEmpty)
                        BubbleTabs(
                          options: const ['Anime', 'Manga'],
                          values: const [true, false],
                          initial: true,
                          onNewValue: (value) => character.onAnime = value,
                          onSameValue: (_) {},
                        )
                      else
                        const SizedBox(),
                      Row(
                        children: [
                          if (character.availableLanguages.length > 1)
                            IconButton(
                              icon: const Icon(Icons.language),
                              onPressed: () => showModalBottomSheet(
                                context: context,
                                builder: (_) => OptionSheet(
                                  title: 'Language',
                                  options: character.availableLanguages,
                                  index: character.languageIndex,
                                  onTap: (index) => character.staffLanguage =
                                      character.availableLanguages[index],
                                ),
                                backgroundColor: Colors.transparent,
                                isScrollControlled: true,
                              ),
                            ),
                          IconButton(
                            icon: const Icon(
                              FluentSystemIcons.ic_fluent_arrow_sort_filled,
                            ),
                            onPressed: () => showModalBottomSheet(
                              context: context,
                              builder: (_) => MediaSortSheet(
                                character.sort,
                                (sort) => character.sort = sort,
                              ),
                              backgroundColor: Colors.transparent,
                              isScrollControlled: true,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              );
            }),
            Obx(() {
              final connectionList =
                  character.onAnime ? character.anime : character.manga;

              if (connectionList == null || connectionList.items.isEmpty)
                return const SliverToBoxAdapter();

              return SliverPadding(
                padding: const EdgeInsets.symmetric(horizontal: 10),
                sliver: ConnectionsGrid(
                  connections: connectionList.items,
                  loadMore: () {
                    if (connectionList.hasNextPage) character.fetchPage();
                  },
                  preferredSubtitle: character.staffLanguage,
                ),
              );
            }),
          ],
        ),
      ),
    );
  }
}
