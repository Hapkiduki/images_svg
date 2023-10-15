import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:map_svg/country.dart';
import 'package:path_drawing/path_drawing.dart';
import 'package:xml/xml.dart';

class MapPage extends StatefulWidget {
  const MapPage({super.key});

  @override
  State<MapPage> createState() => _MapPageState();
}

class _MapPageState extends State<MapPage> {
  late final Future<List<Country>> _mapsFuture;
  Country? _currentMap;

  @override
  void initState() {
    super.initState();
    _mapsFuture = _loadSvgImage(svgImage: 'assets/sa-c-05.svg');
  }

  Future<List<Country>> _loadSvgImage({required String svgImage}) async {
    List<Country> maps = [];
    final generalString = await rootBundle.loadString(svgImage);
    final document = XmlDocument.parse(generalString);
    final paths = document.findAllElements('path');

    for (var path in paths) {
      final id = path.getAttribute('id').toString();
      final d = path.getAttribute('d').toString();
      final name = path.getAttribute('name').toString();
      final color = path.getAttribute('color')?.toString() ?? 'D7D3D2';

      maps.add(
        Country(color: color, d: d, id: id, name: name),
      );
    }

    return maps;
  }

  void _onCountrySelected(Country country) {
    setState(() {
      _currentMap = country;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Sudamerica'),
      ),
      body: FutureBuilder(
          future: _mapsFuture,
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
              return InteractiveViewer(
                maxScale: 5,
                minScale: .1,
                child: Stack(
                  children: [
                    for (var map in snapshot.data!)
                      ClipPath(
                        clipper: Clipper(
                          svgPath: map.d,
                        ),
                        child: GestureDetector(
                          onTap: () => _onCountrySelected.call(map),
                          child: Container(
                            color: Color(int.parse('FF${map.color}', radix: 16))
                                .withOpacity(_currentMap == null
                                    ? 1.0
                                    : _currentMap?.id == map.id
                                        ? 1.0
                                        : 0.3),
                          ),
                        ),
                      ),
                  ],
                ),
              );
            }
            return const Center(
              child: Text('No hay datos disponibles'),
            );
          }),
    );
  }
}

class Clipper extends CustomClipper<Path> {
  Clipper({
    required this.svgPath,
  });

  String svgPath;

  @override
  Path getClip(Size size) {
    var path = parseSvgPathData(svgPath);
    final Matrix4 matrix4 = Matrix4.identity();

    matrix4.scale(1.1, 1.1);

    return path.transform(matrix4.storage).shift(const Offset(-220, 0));
  }

  @override
  bool shouldReclip(CustomClipper oldClipper) {
    return false;
  }
}
