import 'package:ami/src/pages/painter_image_view.dart';
import 'package:ami/src/widgets/dynamic_text.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:syncfusion_flutter_charts/charts.dart';

import '../models/chart_sample_data_model.dart';
import '../providers/face_detector_provider.dart';

class ReportPage extends StatefulWidget {
  final String? imagePath, text;
  const ReportPage({super.key, this.imagePath, this.text});

  @override
  State<ReportPage> createState() => _ReportPageState();
}

class _ReportPageState extends State<ReportPage> {
  TooltipBehavior? _tooltipBehavior;
  List<ChartSampleData>? dataSources;
  List<CircularChartAnnotation>? _annotationSources;
  List<Color>? colors;
  @override
  void initState() {
    _tooltipBehavior =
        TooltipBehavior(enable: true, format: 'point.x : point.y%');
    dataSources = <ChartSampleData>[
      ChartSampleData(
          x: 'Moisture',
          y: 62.70,
          text: '10%',
          pointColor: const Color.fromRGBO(69, 186, 161, 1.0)),
      ChartSampleData(
          x: 'Firmness',
          y: 29.20,
          text: '10%',
          pointColor: const Color.fromRGBO(230, 135, 111, 1.0)),
      ChartSampleData(
          x: 'Pores',
          y: 85.20,
          text: '100%',
          pointColor: const Color.fromRGBO(145, 132, 202, 1.0)),
      ChartSampleData(
          x: 'Dark Circles',
          y: 45.70,
          text: '100%',
          pointColor: const Color.fromRGBO(235, 96, 143, 1.0))
    ];
    _annotationSources = <CircularChartAnnotation>[
      CircularChartAnnotation(
        widget: Image.asset(
          'assets/pure-water.png',
          width: 20,
          height: 20,
        ),
      ),
      CircularChartAnnotation(
        widget: Image.asset(
          'assets/anti-wrinkle.png',
          width: 20,
          height: 20,
          // color: const Color.fromRGBO(230, 135, 111, 1.0),
        ),
      ),
      CircularChartAnnotation(
        widget: Image.asset(
          'assets/skin-care.png',
          width: 20,
          height: 20,
          // color: const Color.fromRGBO(145, 132, 202, 1.0),
        ),
      ),
      CircularChartAnnotation(
        widget: Image.asset(
          'assets/tired.png',
          width: 20,
          height: 20,
          // color: const Color.fromRGBO(235, 96, 143, 1.0),
        ),
      ),
    ];
    colors = const <Color>[
      Color.fromRGBO(69, 186, 161, 1.0),
      Color.fromRGBO(230, 135, 111, 1.0),
      Color.fromRGBO(145, 132, 202, 1.0),
      Color.fromRGBO(235, 96, 143, 1.0)
    ];

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Expanded(child: _buildCustomizedRadialBarChart());
  }

  Widget _buildCustomizedRadialBarChart() {
    return Container(
      margin: const EdgeInsets.all(14),
      height: 700,
      width: MediaQuery.of(context).size.width,
      decoration: BoxDecoration(
        color: Colors.grey.shade100,
        borderRadius: BorderRadius.circular(14),
        border: Border(
          bottom: BorderSide(
            color: Colors.grey.shade300,
            width: 0.5,
          ),
        ),
      ),
      child: Column(
        children: [
          const SizedBox(height: 14),
          const DynamicText(
            text: "Skin Conerns",
            fontSize: 14,
            color: Colors.grey,
          ),
          const SizedBox(height: 4),
          DynamicText(
            text: "Moisture • Dark Circles • Firmness • Pores",
            fontSize: 14,
            color: Colors.grey.shade800,
            fontWeight: FontWeight.bold,
          ),
          const SizedBox(height: 18),
          SfCircularChart(
            legend: Legend(
              isVisible: true,
              overflowMode: LegendItemOverflowMode.scroll,
              alignment: ChartAlignment.center,
              legendItemBuilder: (
                String name,
                dynamic series,
                dynamic point,
                int index,
              ) {
                return SizedBox(
                  height: 60,
                  width: 150,
                  child: Row(
                    children: <Widget>[
                      SizedBox(
                        height: 75,
                        width: 65,
                        child: SfCircularChart(
                          annotations: <CircularChartAnnotation>[
                            _annotationSources![index],
                          ],
                          series: <RadialBarSeries<ChartSampleData, String>>[
                            RadialBarSeries<ChartSampleData, String>(
                              animationDuration: 0,
                              dataSource: <ChartSampleData>[
                                dataSources![index]
                              ],
                              maximumValue: 100,
                              radius: '100%',
                              cornerStyle: CornerStyle.bothCurve,
                              xValueMapper: (ChartSampleData data, _) =>
                                  point.x as String,
                              yValueMapper: (ChartSampleData data, _) => data.y,
                              pointColorMapper: (ChartSampleData data, _) =>
                                  data.pointColor,
                              innerRadius: '70%',
                              pointRadiusMapper: (ChartSampleData data, _) =>
                                  data.text,
                            ),
                          ],
                        ),
                      ),
                      SizedBox(
                        width: 72,
                        child: Text(
                          point.x,
                          style: TextStyle(
                            color: colors![index],
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
            series: _getRadialBarCustomizedSeries(),
            tooltipBehavior: _tooltipBehavior,
            annotations: <CircularChartAnnotation>[
              CircularChartAnnotation(
                height: '90%',
                width: '90%',
                widget: ClipRRect(
                  borderRadius: BorderRadius.circular(100),
                  child: Consumer<FaceDetectorProvider>(
                      builder: (context, provider, widgetChild) {
                    if (provider.imgSize != null &&
                        provider.customPaint != null) {
                      return GestureDetector(
                        onTap: () {
                          var child = Expanded(
                            child: Consumer<FaceDetectorProvider>(
                                builder: (context, provider, widgetChild) {
                              if (provider.imgSize != null &&
                                  provider.customPaint != null) {
                                return Stack(
                                  fit: StackFit.expand,
                                  children: [
                                    FittedBox(
                                      child: SizedBox(
                                        width: provider.imgSize!.width,
                                        height: provider.imgSize!.height,
                                        child: provider.customPaint!,
                                      ),
                                    ),
                                  ],
                                );
                              } else {
                                return const CircularProgressIndicator();
                              }
                            }),
                          );

                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) =>
                                  PainterImageView(child: child),
                            ),
                          );
                        },
                        child: Stack(
                          fit: StackFit.expand,
                          children: [
                            FittedBox(
                              child: Hero(
                                tag: "imageHero",
                                child: SizedBox(
                                  width: provider.imgSize!.width,
                                  height: provider.imgSize!.height,
                                  child: provider.customPaint!,
                                ),
                              ),
                            ),
                          ],
                        ),
                      );
                    } else {
                      return const CircularProgressIndicator();
                    }
                  }),
                ),
              ),
            ],
          ),
          if (widget.imagePath != null) ...[
            DynamicText(
              text: "Image Path: ${widget.imagePath}",
              padding: const EdgeInsets.all(8),
              softwrap: true,
              overflow: TextOverflow.visible,
            ),
            DynamicText(text: widget.text),
          ],
        ],
      ),
    );
  }

  List<RadialBarSeries<ChartSampleData, String>>
      _getRadialBarCustomizedSeries() {
    return <RadialBarSeries<ChartSampleData, String>>[
      RadialBarSeries<ChartSampleData, String>(
        animationDuration: 0,
        maximumValue: 100,
        gap: '10%',
        radius: '100%',
        dataSource: <ChartSampleData>[
          ChartSampleData(
              x: 'Moisture',
              y: 62.70,
              text: '10%',
              pointColor: const Color.fromRGBO(69, 186, 161, 1.0)),
          ChartSampleData(
              x: 'Firmness',
              y: 29.20,
              text: '10%',
              pointColor: const Color.fromRGBO(230, 135, 111, 1.0)),
          ChartSampleData(
              x: 'Pores',
              y: 85.20,
              text: '100%',
              pointColor: const Color.fromRGBO(145, 132, 202, 1.0)),
          ChartSampleData(
              x: 'Dark Circles',
              y: 45.70,
              text: '100%',
              pointColor: const Color.fromRGBO(235, 96, 143, 1.0))
        ],
        cornerStyle: CornerStyle.bothCurve,
        xValueMapper: (ChartSampleData data, _) => data.x as String,
        yValueMapper: (ChartSampleData data, _) => data.y,
        pointRadiusMapper: (ChartSampleData data, _) => data.text,
        pointColorMapper: (ChartSampleData data, _) => data.pointColor,
        legendIconType: LegendIconType.circle,
      ),
    ];
  }

  @override
  void dispose() {
    dataSources!.clear();
    _annotationSources!.clear();
    super.dispose();
  }
}
