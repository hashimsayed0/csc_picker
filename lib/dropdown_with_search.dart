import 'dart:math' as math;
import 'package:flutter/material.dart';

class DropdownWithSearch<T> extends StatelessWidget {
  final String title;
  final String placeHolder;
  final T selected;
  final List items;
  final EdgeInsets? selectedItemPadding;
  final TextStyle? selectedItemStyle;
  final TextStyle? dropdownHeadingStyle;
  final TextStyle? itemStyle;
  final BoxDecoration? decoration, disabledDecoration;
  final double? searchBarRadius;
  final double? dialogRadius;
  final bool disabled;
  final String label;

  final Function onChanged;

  const DropdownWithSearch(
      {Key? key,
      required this.title,
      required this.placeHolder,
      required this.items,
      required this.selected,
      required this.onChanged,
      this.selectedItemPadding,
      this.selectedItemStyle,
      this.dropdownHeadingStyle,
      this.itemStyle,
      this.decoration,
      this.disabledDecoration,
      this.searchBarRadius,
      this.dialogRadius,
      required this.label,
      this.disabled = false})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final borderColor = colorScheme.onSurface.withValues(alpha: 0.2);

    return AbsorbPointer(
      absorbing: disabled,
      child: GestureDetector(
        onTap: () {
          showModalBottomSheet(
            context: context,
            isScrollControlled: true,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.vertical(
                top: Radius.circular(dialogRadius ?? 14),
              ),
            ),
            builder: (context) => SearchBottomSheet(
              placeHolder: placeHolder,
              title: title,
              searchInputRadius: searchBarRadius,
              sheetRadius: dialogRadius,
              titleStyle: dropdownHeadingStyle,
              itemStyle: itemStyle,
              items: items,
            ),
          ).then((value) {
            onChanged(value);
          });
        },
        child: Container(
          padding: EdgeInsets.all(15),
          decoration: !disabled
              ? decoration ??
                  BoxDecoration(
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: Theme.of(context)
                          .colorScheme
                          .outline
                          .withValues(alpha: 0.3),
                      width: 1.0,
                    ),
                    color: Theme.of(context)
                        .colorScheme
                        .surface
                        .withValues(alpha: 0.8),
                  )
              : disabledDecoration ??
                  BoxDecoration(
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: Theme.of(context)
                          .colorScheme
                          .outline
                          .withValues(alpha: 0.2),
                      width: 1.0,
                    ),
                    color: Theme.of(context)
                        .colorScheme
                        .surface
                        .withValues(alpha: 0.4),
                  ),
          child: Row(
            children: [
              Expanded(
                  child: Text(selected.toString(),
                      overflow: TextOverflow.ellipsis,
                      style: selectedItemStyle ?? TextStyle(fontSize: 14))),
              Icon(Icons.keyboard_arrow_down_rounded)
            ],
          ),
        ),
      ),
    );
  }
}

class SearchBottomSheet extends StatefulWidget {
  final String title;
  final String placeHolder;
  final List items;
  final TextStyle? titleStyle;
  final TextStyle? itemStyle;
  final double? searchInputRadius;
  final double? sheetRadius;

  const SearchBottomSheet({
    Key? key,
    required this.title,
    required this.placeHolder,
    required this.items,
    this.titleStyle,
    this.searchInputRadius,
    this.sheetRadius,
    this.itemStyle,
  }) : super(key: key);

  @override
  _SearchBottomSheetState createState() => _SearchBottomSheetState();
}

class _SearchBottomSheetState extends State<SearchBottomSheet> {
  TextEditingController textController = TextEditingController();
  late List filteredList;

  @override
  void initState() {
    filteredList = widget.items;
    textController.addListener(() {
      setState(() {
        if (textController.text.isEmpty) {
          filteredList = widget.items;
        } else {
          filteredList = widget.items
              .where((element) => element
                  .toString()
                  .toLowerCase()
                  .contains(textController.text.toLowerCase()))
              .toList();
        }
      });
    });
    super.initState();
  }

  @override
  void dispose() {
    textController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final bottomViewInset = MediaQuery.of(context).viewInsets.bottom;
    final borderColor = colorScheme.onSurface.withValues(alpha: 0.2);
    final sheetBackgroundColor =
        Theme.of(context).bottomSheetTheme.backgroundColor ??
            colorScheme.surfaceContainerHighest.withValues(alpha: 0.1);
    final actionsBackgroundColor =
        colorScheme.surfaceContainerHighest.withValues(alpha: 0.3);

    return Padding(
      padding: EdgeInsets.only(bottom: bottomViewInset),
      child: DraggableScrollableSheet(
        initialChildSize: 0.6,
        minChildSize: 0.3,
        maxChildSize: 0.9,
        expand: false,
        builder: (context, scrollController) {
          return Container(
            clipBehavior: Clip.antiAlias,
            decoration: BoxDecoration(
              color: sheetBackgroundColor,
              borderRadius: BorderRadius.vertical(top: Radius.circular(12)),
            ),
            child: CustomScrollView(
              controller: scrollController,
              slivers: [
                SliverPersistentHeader(
                  pinned: true,
                  delegate: _PinnedSearchHeaderDelegate(
                    height: 128,
                    child: Material(
                      color: sheetBackgroundColor,
                      child: Container(
                        decoration: BoxDecoration(
                          color: sheetBackgroundColor,
                          border: Border(
                            bottom: BorderSide(
                              color:
                                  colorScheme.onSurface.withValues(alpha: 0.06),
                            ),
                          ),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            Container(
                              padding: const EdgeInsets.only(top: 14),
                              child: Center(
                                child: Container(
                                  width: 60,
                                  height: 6,
                                  decoration: BoxDecoration(
                                    color: colorScheme.onSurface
                                        .withValues(alpha: 0.3),
                                    borderRadius: BorderRadius.circular(2),
                                  ),
                                ),
                              ),
                            ),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Container(
                                  margin: EdgeInsets.symmetric(horizontal: 16),
                                  child: Text(
                                    widget.title,
                                    style: widget.titleStyle ??
                                        TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.bold,
                                        ),
                                  ),
                                ),
                                IconButton(
                                  icon: Icon(Icons.close),
                                  onPressed: () {
                                    FocusScope.of(context).unfocus();
                                    Navigator.pop(context);
                                  },
                                ),
                              ],
                            ),
                            Container(
                              padding: const EdgeInsets.only(top: 10),
                              child: TextField(
                                autofocus: true,
                                decoration: InputDecoration(
                                  prefixIcon: Icon(Icons.search),
                                  hintText: widget.placeHolder,
                                  border: UnderlineInputBorder(
                                    borderSide: BorderSide(
                                      color: borderColor,
                                    ),
                                  ),
                                  enabledBorder: UnderlineInputBorder(
                                    borderSide: BorderSide(
                                      color: borderColor,
                                    ),
                                  ),
                                  focusedBorder: UnderlineInputBorder(
                                    borderSide: BorderSide(
                                      color: borderColor,
                                    ),
                                  ),
                                  disabledBorder: UnderlineInputBorder(
                                    borderSide: BorderSide(
                                      color: borderColor,
                                    ),
                                  ),
                                  errorBorder: UnderlineInputBorder(
                                    borderSide: BorderSide(
                                      color: borderColor,
                                    ),
                                  ),
                                  focusedErrorBorder: UnderlineInputBorder(
                                    borderSide: BorderSide(
                                      color: borderColor,
                                    ),
                                  ),
                                ),
                                style:
                                    widget.itemStyle ?? TextStyle(fontSize: 14),
                                controller: textController,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
                SliverList(
                  delegate: SliverChildBuilderDelegate(
                    (context, index) {
                      return Container(
                        color: actionsBackgroundColor,
                        child: InkWell(
                          onTap: () {
                            FocusScope.of(context).unfocus();
                            Navigator.pop(context, filteredList[index]);
                          },
                          child: Padding(
                            padding: const EdgeInsets.symmetric(
                                vertical: 12, horizontal: 18),
                            child: Text(
                              filteredList[index].toString(),
                              style:
                                  widget.itemStyle ?? TextStyle(fontSize: 14),
                            ),
                          ),
                        ),
                      );
                    },
                    childCount: filteredList.length,
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

class _PinnedSearchHeaderDelegate extends SliverPersistentHeaderDelegate {
  final double height;
  final Widget child;

  _PinnedSearchHeaderDelegate({
    required this.height,
    required this.child,
  });

  @override
  double get minExtent => height;

  @override
  double get maxExtent => height;

  @override
  Widget build(
      BuildContext context, double shrinkOffset, bool overlapsContent) {
    return child;
  }

  @override
  bool shouldRebuild(covariant _PinnedSearchHeaderDelegate oldDelegate) {
    return oldDelegate.height != height || oldDelegate.child != child;
  }
}
