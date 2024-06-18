import 'dart:developer';

import 'package:dio/dio.dart';

class SkinAnalysisService {
  final Dio _dio = Dio();

  Future<dynamic> analyzeSkin(String imagePath) async {
    // The URL of the API endpoint
    const String url =
        'https://skin-analyze.p.rapidapi.com/facebody/analysis/skinanalyze';

    // Prepare the FormData
    FormData formData = FormData.fromMap({
      // Assuming 'image' is the key the API expects for the image file
      'image': await MultipartFile.fromFile(imagePath, filename: 'image.jpg'),
    });

    // Prepare the request options
    Options options = Options(
      method: 'POST',
      headers: {
        'X-RapidAPI-Key': '4dddb852bbmshf17cc7894b8f04bp1c64d9jsn908ead2fb9d3',
        'X-RapidAPI-Host': 'skin-analyze.p.rapidapi.com',
      },
    );

    try {
      // Make the request
      final response = await _dio.post(url, data: formData, options: options);

      // Return the response data
      return response.data;
    } on DioException catch (e) {
      // Handle any errors
      log(e.toString());
      return null;
    }
  }
}
