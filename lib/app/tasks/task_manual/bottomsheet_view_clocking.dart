import 'package:asm_wt/util/full_screen_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:maplibre_gl/maplibre_gl.dart';

class ConfirmationSheetViewClocking extends StatefulWidget {
  final String clockIn;
  final String clockOut;
  final List<double> clock_in_location;
  final List<double> clock_out_location;
  final List<String> clock_in_image;
  final List<String> clock_out_image;

  ConfirmationSheetViewClocking(
      this.clockIn,
      this.clockOut,
      this.clock_in_location,
      this.clock_out_location,
      this.clock_in_image,
      this.clock_out_image);

  @override
  _ConfirmationSheetViewClockingState createState() =>
      _ConfirmationSheetViewClockingState();
}

class _ConfirmationSheetViewClockingState
    extends State<ConfirmationSheetViewClocking> {
  MapLibreMapController? mapController;

  @override
  void initState() {
    super.initState();
  }

  void _onMapCreated(MapLibreMapController controller) {
    mapController = controller;

    // Debugging: Print the locations
    print('Clock In Location: ${widget.clock_in_location}');
    print('Clock Out Location: ${widget.clock_out_location}');

    // Add markers for clock-in and clock-out locations
    // Delay adding circles
    Future.delayed(Duration(milliseconds: 500), () {
      _addPinOut(widget.clock_out_location);
      _addPinIn(widget.clock_in_location);
    });

    // Animate camera to the clock-in location
    mapController?.animateCamera(
      CameraUpdate.newLatLng(
        LatLng(widget.clock_in_location[0], widget.clock_in_location[1]),
      ),
    );
  }

// Helper function to load the image from assets
  Future<Uint8List> loadImageFromAsset(String path) async {
    final ByteData data = await rootBundle.load(path);
    return data.buffer.asUint8List();
  }

  void _addPinIn(List<double> location) async {
    if (mapController != null) {
      // Ensure the custom icon is added to the map style before adding a symbol
      await mapController!.addImage(
        'custom-marker', // Identifier for the custom icon
        await loadImageFromAsset('lib/assets/images/log-in.png'),
      );

      mapController?.addSymbol(
        SymbolOptions(
            geometry: LatLng(location[0], location[1]),
            iconImage: 'custom-marker', // Use the custom icon
            iconSize: 0.2, // Adjust size as needed
            iconOffset: Offset(0, -100)),
      );
    }
  }

  void _addPinOut(List<double> location) async {
    if (mapController != null) {
      // Ensure the custom icon is added to the map style before adding a symbol
      await mapController!.addImage(
        'out-marker', // Identifier for the custom icon
        await loadImageFromAsset('lib/assets/images/log-out.png'),
      );

      mapController?.addSymbol(
        SymbolOptions(
            geometry: LatLng(location[0], location[1]),
            iconImage: 'out-marker', // Use the custom icon
            iconSize: 0.2, // Adjust size as needed
            iconOffset: Offset(0, -100)),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      height: 600, // Adjust the height for map display
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            'Clocking Detail',
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const Divider(),
          const SizedBox(height: 10),
          Text('Clocking data'),
          const SizedBox(height: 20),
          Container(
            height: 165, // Map height
            child: MapLibreMap(
              styleString:
                  "https://maps.powermap.live/api/v2/map/vtile/styles?name=thailand_th&access_token=b378c575291af30a29f59919fd7e7e4c012d45c4", // MapLibre style URL
              onMapCreated: _onMapCreated,
              initialCameraPosition: CameraPosition(
                target: LatLng(
                    widget.clock_in_location[0], widget.clock_in_location[1]),
                zoom: 14.0, // Adjust zoom level for better visibility
              ),
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                  'Clock-in Lat/Lng: ${widget.clock_in_location[0].toString()}/${widget.clock_in_location[1].toString()}'),
              Text(
                  'Clock-out Lat/Lng: ${widget.clock_out_location[0].toString()}/${widget.clock_out_location[1].toString()}'), // Corrected index for longitude
            ],
          ),
          SizedBox(
            height: 10,
          ),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                if (widget.clock_in_image.isNotEmpty) ...[
                  Column(children: [
                    Text('Clock in image'),
                    Row(children: [
                      ...widget.clock_in_image.map((imageUrl) {
                        return Padding(
                          padding: const EdgeInsets.symmetric(
                              vertical: 5.0, horizontal: 5),
                          child: GestureDetector(
                            onTap: () {
                              FullscreenImageViewer.show(context, imageUrl);
                            },
                            child: Image.network(
                              imageUrl,
                              width: 100, // Set a fixed width
                              height: 100, // Set a fixed height
                              fit: BoxFit
                                  .cover, // Cover to maintain aspect ratio
                              errorBuilder: (context, error, stackTrace) {
                                return Container(
                                  color: Colors.grey[300], // Placeholder color
                                  width: 150,
                                  height: 100,
                                  child: const Center(
                                      child: Text('Image not available')),
                                );
                              },
                            ),
                          ),
                        );
                      }).toList()
                    ]),
                  ]),
                ] else ...[
                  const Text('No clock-in images available.'),
                ],
                SizedBox(
                  width: 10,
                ),
                if (widget.clock_out_image.isNotEmpty) ...[
                  // Fixed to clock_out_image
                  Column(
                    children: [
                      Text('Clock out image'),
                      Row(
                        children: [
                          ...widget.clock_out_image.map((imageUrl) {
                            return Padding(
                              padding: const EdgeInsets.symmetric(
                                  vertical: 5.0, horizontal: 5.0),
                              child: GestureDetector(
                                onTap: () {
                                  FullscreenImageViewer.show(context, imageUrl);
                                },
                                child: Image.network(
                                  imageUrl,
                                  width: 100, // Set a fixed width
                                  height: 100, // Set a fixed height
                                  fit: BoxFit
                                      .cover, // Cover to maintain aspect ratio
                                  errorBuilder: (context, error, stackTrace) {
                                    return Container(
                                      color:
                                          Colors.grey[300], // Placeholder color
                                      width: 150,
                                      height: 100,
                                      child: const Center(
                                          child: Text('Image not available')),
                                    );
                                  },
                                ),
                              ),
                            );
                          }).toList(),
                        ],
                      ),
                    ],
                  ),
                ] else ...[
                  const Text('No clock-out images available.'),
                ],
              ],
            ),
          ),
          SizedBox(
            height: 10,
          ),
          const Divider(),
          SizedBox(
            height: 10,
          ),
        ],
      ),
    );
  }
}
