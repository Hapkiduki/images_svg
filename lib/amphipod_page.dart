import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:map_svg/body_clipper.dart';
import 'package:map_svg/body_part.dart';
import 'package:xml/xml.dart';

class AmphipodPage extends StatefulWidget {
  const AmphipodPage({super.key});

  @override
  State<AmphipodPage> createState() => _AmphipodPageState();
}

class _AmphipodPageState extends State<AmphipodPage> {
  final bodyIds = ['_155860064', 'g326'];
  late final Future<List<BodyPart>> _bodyPartsFuture;
  BodyPart? _currentPart;

  @override
  void initState() {
    super.initState();
    _bodyPartsFuture = _loadBody();
  }

  Future<List<BodyPart>> _loadBody() async {
    final List<BodyPart> parts = [];
    const amphiodPath = 'assets/amphipod_anatomy.svg';
    final svgString = await rootBundle.loadString(amphiodPath);
    final document = XmlDocument.parse(svgString);
    final labels = document.findAllElements('g').first;
    final bodyParts = labels.childElements
        .where((e) => bodyIds.contains(e.getAttribute('id')));

    for (var bp in bodyParts) {
      final names = bp.children
          .where((p0) => p0.getAttribute('id') != null)
          .map(
              (e) => {e.getAttribute('color'): e.getAttribute('id') ?? 'Cola'});
      final bodyParts = List<BodyPart>.from(
        bp.findAllElements('path').map(
          (e) {
            final color = e.getAttribute('color').toString();
            String name = 'cola';

            for (var n in names) {
              if (n.containsKey(color)) {
                name = n[color]!;
                break;
              }
            }

            return BodyPart(
              color: color,
              d: e.getAttribute('d').toString(),
              id: e.getAttribute('id').toString(),
              name: name,
            );
          },
        ),
      );
      parts.addAll(bodyParts);
    }

    return parts;
  }

  void _onPartSelected(BodyPart part) {
    setState(() {
      _currentPart = part;
    });
  }

  Color _parseColor(String stringColor) {
    String hexColor = stringColor.replaceAll('#', '');
    if (hexColor.length == 6) {
      hexColor = 'FF$hexColor';
    }
    return Color(int.parse(hexColor, radix: 16));
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Scaffold(
        appBar: AppBar(
          title: const Text('Anfípodo'),
        ),
        body: FutureBuilder(
          future: _bodyPartsFuture,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(
                child: CircularProgressIndicator(),
              );
            } else if (snapshot.hasError) {
              return const Center(
                child: Text('Error al decodificar el mapa'),
              );
            } else if (snapshot.hasData) {
              return Column(
                mainAxisSize: MainAxisSize.max,
                children: [
                  Expanded(
                    child: InteractiveViewer(
                      maxScale: 5,
                      minScale: .1,
                      child: Stack(
                        children: [
                          for (var part in snapshot.data!)
                            ClipPath(
                              clipper: BodyClipper(part.d),
                              child: GestureDetector(
                                onTap: () => _onPartSelected.call(part),
                                child: Container(
                                  color: _parseColor(part.color)
                                      .withOpacity(_currentPart == null
                                          ? 1.0
                                          : _currentPart?.id == part.id
                                              ? 1.0
                                              : 0.3),
                                ),
                              ),
                            ),
                        ],
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 18,
                    ),
                    child: Column(
                      children: [
                        Text(
                          'Langosta',
                          style: textTheme.displayMedium,
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            Text(
                              _currentPart?.name ??
                                  'partes del cuerpo ${snapshot.data!.length}',
                              style: textTheme.bodyLarge,
                            ),
                            if (_currentPart != null)
                              Container(
                                color: _parseColor(_currentPart!.color),
                                height: 18,
                                width: 50,
                              ),
                          ],
                        ),
                        Text(
                          'Lorem ipsum si amet dorem itum pare cuta namae ogore na.Lorem ipsum si amet dorem itum pare cuta namae ogore na.Lorem ipsum si ',
                          style: textTheme.labelLarge,
                          textAlign: TextAlign.center,
                        )
                      ],
                    ),
                  ),
                ],
              );
            }

            return const Center(
              child: Text('No hay datos disponibles'),
            );
          },
        ));
  }
}
