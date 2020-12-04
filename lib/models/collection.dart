import 'package:otraku/enums/list_sort_enum.dart';
import 'package:otraku/enums/media_list_status_enum.dart';
import 'package:otraku/models/entry_list.dart';
import 'package:otraku/models/page_data/edit_entry.dart';
import 'package:otraku/models/sample_data/media_entry.dart';

class Collection {
  final Function updateHandle;
  final Function fetchHandle;
  final int userId;
  final bool ofAnime;
  final bool completedListIsSplit;
  final String scoreFormat;
  final List<EntryList> lists;
  ListSort _sort;
  int _listIndex = 0;
  String _search;

  Collection({
    this.updateHandle,
    this.fetchHandle,
    this.userId,
    this.ofAnime,
    this.completedListIsSplit,
    this.scoreFormat,
    this.lists,
    initialSort,
  }) {
    sort = initialSort;
  }

  int get listIndex => _listIndex;

  set listIndex(int value) {
    if (value < 0 || value >= lists.length || value == _listIndex) return;
    _listIndex = value;
    updateHandle();
  }

  String get search => _search;

  set search(String value) {
    if (value == null || value.trim() == '') {
      _search = null;
    } else {
      _search = value.trim();
    }
    updateHandle();
  }

  ListSort get sort => _sort;

  set sort(ListSort value) {
    _sort = value;
    sortLists(lists, _sort);
    updateHandle();
  }

  List<String> get listNames {
    List<String> names = [];
    for (final list in lists) names.add(list.name);
    return names;
  }

  List<int> get listEntryCounts {
    List<int> counts = [];
    for (final list in lists) counts.add(list.entries.length);
    return counts;
  }

  String get currentListName => lists[_listIndex].name;

  int get currentEntryCount => lists[_listIndex].entries.length;

  int get totalEntryCount {
    int count = 0;
    for (final list in lists)
      if (list.status != null) count += list.entries.length;
    return count;
  }

  List<MediaEntry> get entries {
    if (_search == null) return [...lists[_listIndex].entries];

    List<MediaEntry> entries = [];
    for (final entry in lists[_listIndex].entries) {
      if (entry.title.toLowerCase().contains(search.toLowerCase()))
        entries.add(entry);
    }

    return entries;
  }

  void updateEntry(
    EditEntry original,
    EditEntry changed,
    MediaEntry entry,
    List<String> newCustomLists,
  ) {
    removeEntry(original, cleanUp: false);

    List<EntryList> updatedLists = [];

    if (!changed.hiddenFromStatusLists) {
      for (final list in lists) {
        if (completedListIsSplit &&
            changed.status == MediaListStatus.COMPLETED) {
          if (list.splitCompletedListFormat == entry.format) {
            list.entries.add(entry);
            updatedLists.add(list);
            break;
          }
        } else {
          if (!list.isCustomList && list.status == changed.status) {
            list.entries.add(entry);
            updatedLists.add(list);
            break;
          }
        }
      }

      if (updatedLists.length == 0) {
        fetchHandle();
        return;
      }
    }

    for (final list in lists) {
      if (list.isCustomList) {
        for (int i = 0; i < newCustomLists.length; i++) {
          if (list.name.toLowerCase() == newCustomLists[i].toLowerCase()) {
            list.entries.add(entry);
            updatedLists.add(list);
            newCustomLists.removeAt(i--);
            break;
          }
        }
      }
    }

    if (newCustomLists.length > 0) {
      fetchHandle();
      return;
    }

    for (int i = 0; i < lists.length; i++) {
      if (lists[i].entries.length == 0) {
        listIndex = _listIndex - 1;
        lists.removeAt(i--);
      }
    }

    sortLists(updatedLists, _sort);

    updateHandle();
  }

  void removeEntry(EditEntry entry, {bool cleanUp = true}) {
    List<String> customLists = [];
    for (final tuple in entry.customLists)
      if (tuple.item2) customLists.add(tuple.item1.toLowerCase());

    for (final list in lists) {
      if (!entry.hiddenFromStatusLists && entry.status == list.status) {
        for (int i = 0; i < list.entries.length; i++) {
          if (entry.mediaId == list.entries[i].mediaId) {
            list.entries.removeAt(i);
            break;
          }
        }
      } else if (list.isCustomList &&
          customLists.contains(list.name.toLowerCase())) {
        for (int i = 0; i < list.entries.length; i++) {
          if (entry.mediaId == list.entries[i].mediaId) {
            list.entries.removeAt(i);
            break;
          }
        }
      }
    }

    if (cleanUp) {
      for (int i = 0; i < lists.length; i++) {
        if (lists[i].entries.length == 0) {
          listIndex = _listIndex - 1;
          lists.removeAt(i--);
        }
      }
      updateHandle();
    }
  }

  static void sortLists(List<EntryList> entryLists, ListSort sorting) {
    switch (sorting) {
      case ListSort.TITLE:
        for (final list in entryLists)
          list.entries.sort((a, b) => a.title.compareTo(b.title));
        break;
      case ListSort.TITLE_DESC:
        for (final list in entryLists)
          list.entries.sort((a, b) => b.title.compareTo(a.title));
        break;
      case ListSort.SCORE:
        for (final list in entryLists)
          list.entries.sort((a, b) {
            int comparison = a.score.compareTo(b.score);
            if (comparison != 0) return comparison;
            return a.title.compareTo(b.title);
          });
        break;
      case ListSort.SCORE_DESC:
        for (final list in entryLists)
          list.entries.sort((a, b) {
            int comparison = b.score.compareTo(a.score);
            if (comparison != 0) return comparison;
            return a.title.compareTo(b.title);
          });
        break;
      case ListSort.UPDATED_AT:
        for (final list in entryLists)
          list.entries.sort((a, b) {
            int comparison = a.updatedAt.compareTo(b.updatedAt);
            if (comparison != 0) return comparison;
            return a.title.compareTo(b.title);
          });
        break;
      case ListSort.UPDATED_AT_DESC:
        for (final list in entryLists)
          list.entries.sort((a, b) {
            int comparison = b.updatedAt.compareTo(a.updatedAt);
            if (comparison != 0) return comparison;
            return a.title.compareTo(b.title);
          });
        break;
      case ListSort.CREATED_AT:
        for (final list in entryLists)
          list.entries.sort((a, b) {
            int comparison = a.createdAt.compareTo(b.createdAt);
            if (comparison != 0) return comparison;
            return a.title.compareTo(b.title);
          });
        break;
      case ListSort.CREATED_AT_DESC:
        for (final list in entryLists)
          list.entries.sort((a, b) {
            int comparison = b.createdAt.compareTo(a.createdAt);
            if (comparison != 0) return comparison;
            return a.title.compareTo(b.title);
          });
        break;
      case ListSort.PROGRESS:
        for (final list in entryLists)
          list.entries.sort((a, b) {
            int comparison = a.progress.compareTo(b.progress);
            if (comparison != 0) return comparison;
            return a.title.compareTo(b.title);
          });
        break;
      case ListSort.PROGRESS_DESC:
        for (final list in entryLists)
          list.entries.sort((a, b) {
            int comparison = b.progress.compareTo(a.progress);
            if (comparison != 0) return comparison;
            return a.title.compareTo(b.title);
          });
        break;
      case ListSort.REPEAT:
        for (final list in entryLists)
          list.entries.sort((a, b) {
            int comparison = a.repeat.compareTo(b.repeat);
            if (comparison != 0) return comparison;
            return a.title.compareTo(b.title);
          });
        break;
      case ListSort.REPEAT_DESC:
        for (final list in entryLists)
          list.entries.sort((a, b) {
            int comparison = b.repeat.compareTo(a.repeat);
            if (comparison != 0) return comparison;
            return a.title.compareTo(b.title);
          });
        break;
      default:
        break;
    }
  }
}
