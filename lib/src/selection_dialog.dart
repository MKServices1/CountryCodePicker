import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import 'country_code.dart';
import 'country_localizations.dart';

/// selection dialog used for selection of the country code
class SelectionDialog extends StatefulWidget {
  final List<CountryCode> elements;
  final bool? showCountryOnly;
  final InputDecoration searchDecoration;
  final TextStyle? searchStyle;
  final TextStyle? textStyle;
  final BoxDecoration? boxDecoration;
  final WidgetBuilder? emptySearchBuilder;
  final bool? showFlag;
  final double flagWidth;
  final Decoration? flagDecoration;
  final Size? size;
  final bool hideSearch;
  final bool hideCloseIcon;
  final Icon? closeIcon;

  /// Background color of SelectionDialog
  final Color? backgroundColor;

  /// Boxshaow color of SelectionDialog that matches CountryCodePicker barrier color
  final Color? barrierColor;

  /// elements passed as favorite
  final List<CountryCode> favoriteElements;

  final EdgeInsetsGeometry dialogItemPadding;

  final EdgeInsetsGeometry searchPadding;

  SelectionDialog(
    this.elements,
    this.favoriteElements, {
    Key? key,
    this.showCountryOnly,
    this.emptySearchBuilder,
    InputDecoration searchDecoration = const InputDecoration(),
    this.searchStyle,
    this.textStyle,
    this.boxDecoration,
    this.showFlag,
    this.flagDecoration,
    this.flagWidth = 32,
    this.size,
    this.backgroundColor,
    this.barrierColor,
    this.hideSearch = false,
    this.hideCloseIcon = false,
    this.closeIcon,
    this.dialogItemPadding = const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
    this.searchPadding = const EdgeInsets.symmetric(horizontal: 24),
  })  : searchDecoration = searchDecoration.suffixIcon == null
            ? searchDecoration.copyWith(suffixIcon: const Icon(Icons.search))
            : searchDecoration,
        super(key: key);

  @override
  State<StatefulWidget> createState() => _SelectionDialogState();
}

class _SelectionDialogState extends State<SelectionDialog> {
  /// this is useful for filtering purpose
  late List<CountryCode> filteredElements;

  @override
  Widget build(BuildContext context) => Container(
    clipBehavior: Clip.hardEdge,
    width: 90,
    height:
        widget.size?.height ?? MediaQuery.of(context).size.height * 0.58,
    decoration: widget.boxDecoration ??
        BoxDecoration(
          color: widget.backgroundColor ?? const Color(0xFF2D2E2F),
          borderRadius: const BorderRadius.all(Radius.circular(8.0)),
          boxShadow: [
          ],
        ),
    child: Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        if (!widget.hideCloseIcon)
          Center(
            child: Container(
              width: 30,height: 3,
              decoration: const BoxDecoration(
                color:Color(0xFFE6E6E6),
                borderRadius:  BorderRadius.all(Radius.circular(100.0),),
              ),
            ),
          ),
        const SizedBox(height: 10,),
        if (!widget.hideSearch)
          Padding(
            padding:const EdgeInsets.symmetric(vertical: 10,horizontal: 10),
            child: TextField(
              style: widget.searchStyle,
              decoration: widget.searchDecoration,
              onChanged: _filterElements,
            ),
          ),
        Expanded(
          child:Scrollbar(
            trackVisibility: true,
            thumbVisibility: true,
            child: ListView(
              children: [
                widget.favoriteElements.isEmpty
                    ? const DecoratedBox(decoration: BoxDecoration())
                    : Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          ...widget.favoriteElements.map(
                            (f) => InkWell(
                              onTap: () {
                                _selectItem(f);
                              },
                              child: Padding(
                                padding: widget.dialogItemPadding,
                                child: _buildOption(f),
                              )
                            )
                          ),
                          const Divider(),
                        ],
                      ),
                if (filteredElements.isEmpty)
                  _buildEmptySearchWidget(context)
                else
                  ...filteredElements.map(
                    (e) => InkWell(
                      onTap: () {
                        _selectItem(e);
                      },
                      child: Padding(
                      padding: widget.dialogItemPadding,
                        child: _buildOption(e),
                      )
                    )
                  ),
              ],
            ),
          ),
        ),
      ],
    ),
  );

  Widget _buildOption(CountryCode e) {
    return SizedBox(
      width: 400,
      child: Flex(
        direction: Axis.horizontal,
        children: <Widget>[
          if (widget.showFlag!)
            Flexible(
              child: Container(
                margin: const EdgeInsets.only(right: 16.0),
                decoration: widget.flagDecoration,
                clipBehavior:
                    widget.flagDecoration == null ? Clip.none : Clip.hardEdge,
                child: Image.asset(
                  e.flagUri!,
                  package: 'country_code_picker',
                  width: widget.flagWidth,
                ),
              ),
            ),
          Expanded(
            flex: 4,
            child: Text(
              widget.showCountryOnly!
                  ? e.toString()
                  : e.toString(),
              overflow: TextOverflow.fade,
              style: widget.textStyle,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptySearchWidget(BuildContext context) {
    if (widget.emptySearchBuilder != null) {
      return widget.emptySearchBuilder!(context);
    }

    return Center(
      child: Text(CountryLocalizations.of(context)?.translate('no_country') ??
          'No country found'),
    );
  }

  @override
  void initState() {
    filteredElements = widget.elements;
    super.initState();
  }

  void _filterElements(String s) {
    s = s.toUpperCase();
    setState(() {
      filteredElements = widget.elements
          .where((e) =>
              // e.code!.contains(s) ||
              e.dialCode!.contains(s)// ||
              // e.name!.toUpperCase().contains(s)
      )
          .toList();
    });
  }

  void _selectItem(CountryCode e) {
    Navigator.pop(context, e);
  }
}
