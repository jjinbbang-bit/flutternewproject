import 'dart:async';
import 'dart:developer' as developer;
import 'dart:io';
import 'dart:math';
import 'package:animated_text_kit/animated_text_kit.dart';
import 'package:circle_nav_bar/circle_nav_bar.dart';
import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:mygptrainer/api/apis.dart';
import 'package:mygptrainer/main.dart';
import 'package:mygptrainer/models/gemini_coll.dart';
import 'package:mygptrainer/screens/auth/gemini_screen.dart';
import 'package:mygptrainer/screens/home_screen.dart';
import 'package:syncfusion_flutter_charts/charts.dart';
import 'package:image_picker/image_picker.dart';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';
import 'package:mime/mime.dart';
import 'dart:convert';
import 'package:flutter_dotenv/flutter_dotenv.dart';


// jinhomescreen.dart
class JinhomeScreen extends StatefulWidget {
  final bool showDialogOnLoad;

  const JinhomeScreen({Key? key, this.showDialogOnLoad = false}) : super(key: key);

  @override
  _JinhomeScreen createState() => _JinhomeScreen();
}




void initState() {




// ...
}





class _JinhomeScreen extends State<JinhomeScreen> with SingleTickerProviderStateMixin {
  int _selectedIndex = 0;
  late PageController pageController;
  String dietMessage = 'Loading...';
  String? _gptimage;
  Timer? _timer;
  List<ImageModel> _images = [];
  final picker = ImagePicker();
  DateTime? _selectedDate;
  late List<_ChartData> mealData;
  late TooltipBehavior _tooltip;
  File? _image;
  Map<String, dynamic>? _chartData;

  final List<String> bearMessages = [
    "으앙~ 배고파!",
    "나 생선줘...",
    "오늘도 화이팅!",
    "나 오늘부터 다이어트할거야!",
    "오늘 뭐 먹을거야?",
    "식단은 잘 지키고 있어?",
    "오늘부터 다이어트 시작!",
    "흠냐흠냐 ....",
    "생선구이 좋아해?",
    "나 사실 연어를 젤 좋아해!",
    "연어 먹구싶다...ㅠㅠ",
    "나는야~곰돌쓰!!"
  ];

  @override
  void initState() {




    super.initState();
    pageController = PageController(initialPage: _selectedIndex);
    updateBearMessage();
    _timer = Timer.periodic(
        const Duration(seconds: 7), (Timer t) => updateBearMessage());

    mealData = [
      _ChartData('Calories', 0, Colors.blue),
      _ChartData('Protein', 0, Colors.green),
      _ChartData('Fat', 0, Colors.orange),
      _ChartData('Salt', 0, Colors.red),
      _ChartData('Sugar', 0, Colors.purple),
    ];
    _tooltip = TooltipBehavior(enable: true);
    if (widget.showDialogOnLoad) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _showImageSourceDialog();
      });
    }
  }






  @override
  void dispose() {
    _timer?.cancel();
    pageController.dispose();
    super.dispose();
  }

  void updateBearMessage() {
    final random = Random();
    final randomMessage = bearMessages[random.nextInt(bearMessages.length)];
    setState(() {
      dietMessage = randomMessage;
    });
  }

  void addImage(File image, String caption) {
    setState(() {
      _images.add(ImageModel(image, false, caption));
    });
  }

  void toggleLike(int index) {
    setState(() {
      _images[index].isLiked = !_images[index].isLiked;
    });
  }

  Future<void> _pickImage(ImageSource source) async {
    final pickedFile = await picker.pickImage(source: source);

    if (pickedFile != null) {
      setState(() {
        _image = File(pickedFile.path);
      });
      await _uploadImage();
    } else {
      print('No image selected.');
    }
  }

  Future<void> _uploadImage() async {
    if (_image == null) return;

    final url = Uri.parse(dotenv.env['CLOUD_URL']!); // Load URL from .env file
    final mimeTypeData = lookupMimeType(_image!.path)!.split('/');

    final imageUploadRequest = http.MultipartRequest('POST', url);
    final file = await http.MultipartFile.fromPath(
      'image',
      _image!.path,
      contentType: MediaType(mimeTypeData[0], mimeTypeData[1]),
    );

    imageUploadRequest.files.add(file);

    try {
      final streamedResponse = await imageUploadRequest.send();
      final response = await http.Response.fromStream(streamedResponse);

      if (response.statusCode == 200) {
        final responseData = json.decode(response.body);
        setState(() {
          _chartData = responseData;
          // Update the mealData here with new chart data
          mealData = [
            _ChartData('Calories', _parseDouble(_chartData?['cal_t']), Colors.blue),
            _ChartData('Protein', _parseDouble(_chartData?['pro_t']), Colors.green),
            _ChartData('Fat', _parseDouble(_chartData?['fat_t']), Colors.orange),
            _ChartData('Salt', _parseDouble(_chartData?['salt_t']), Colors.red),
            _ChartData('Sugar', _parseDouble(_chartData?['sugar_t']), Colors.purple),
          ];
        });
        developer.log('Image uploaded successfully: ${response.body}');
      } else {
        developer.log('Failed to upload image: ${response.statusCode}');
      }
    } catch (e) {
      developer.log('Error uploading image: $e');
    }
  }

  double _parseDouble(dynamic value) {
    if (value == null) {
      return 0.0;
    }
    return value is double ? value : double.tryParse(value.toString()) ?? 0.0;
  }

  void _showImageSourceDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Select Image Source'),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              _pickImage(ImageSource.camera);
            },
            child: Text('Camera'),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              _pickImage(ImageSource.gallery);
            },
            child: Text('Gallery'),
          ),
        ],
      ),
    );
  }

  void _showFoodDetails() {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('오늘의 음식 정보'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (_selectedDate != null)
                Text('날짜: ${_selectedDate.toString().split(' ')[0]}'),
              SizedBox(height: 10),
              _buildCaloriesChart(),
              SizedBox(height: 10),
              _buildNutrientPieChart(),
              SizedBox(height: 10),
              Text('사진 목록:'),
              SizedBox(
                height: 200,
                child: ListView.builder(
                  itemCount: _images.length,
                  itemBuilder: (context, index) {
                    final imageModel = _images[index];
                    return Card(
                      child: Column(
                        children: [
                          Image.file(
                            imageModel.image,
                            height: 100,
                            width: double.infinity,
                            fit: BoxFit.cover,
                          ),
                          const SizedBox(height: 10),
                          Text(imageModel.caption),
                        ],
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
          actions: <Widget>[
            TextButton(
              child: const Text('Close'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    String userId = 'yourUserId';
    String docId = 'yourDocId';
    return Scaffold(
        appBar: AppBar(
          toolbarHeight: mq.height * 0.085,
          title: Row(
            children: [
              SizedBox(
                height: 3500, // 곰돌이 크기(제목 칸이라 제목 칸을 안 키우는 이상 못 큼)
                width: 50, // 곰돌이 들여쓰기 간격
                child: Lottie.asset('assets/lottie/bear.json'),
              ),
              const SizedBox(width: 10), // 곰돌이와 곰돌이 말풍선 사이 거리
              Expanded(
                child: Container(
                  padding: const EdgeInsets.all(8.0),
                  decoration: BoxDecoration(
                    color: Colors.pink[100],
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    dietMessage,
                    style: const TextStyle(fontSize: 16),
                  ),
                ),
              ),
            ],
          ),
          backgroundColor: Color.fromARGB(232, 248, 245, 250),
          elevation: 0,
        ),
        body: PageView(
          controller: pageController,
          onPageChanged: (v) {
            setState(() {
              _selectedIndex = v;
            });
          },
          physics: NeverScrollableScrollPhysics(),
          children: [
            SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(
                    height: 250,
                    child: _buildLargeCircularChart(),
                  ),
                  const SizedBox(height: 20),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      Expanded(
                        child: Column(
                          children: [
                            SizedBox(
                              height: 120,
                              child: _buildSmallCircularChart(
                                'Carbohydrates',
                                _parseDouble(_chartData?['car_t_pct']),
                                Colors.blue,
                              ),
                            ),
                            const Text(
                              'Carbohydrates',
                              style: TextStyle(fontSize: 12),
                            ),
                          ],
                        ),
                      ),
                      Expanded(
                        child: Column(
                          children: [
                            SizedBox(
                              height: 120,
                              child: _buildSmallCircularChart(
                                'Protein',
                                _parseDouble(_chartData?['pro_t_pct']),
                                Colors.green,
                              ),
                            ),
                            const Text(
                              'Protein',
                              style: TextStyle(fontSize: 12),
                            ),
                          ],
                        ),
                      ),
                      Expanded(
                        child: Column(
                          children: [
                            SizedBox(
                              height: 120,
                              child: _buildSmallCircularChart(
                                'Fat',
                                _parseDouble(_chartData?['fat_t_pct']),
                                Colors.orange,
                              ),
                            ),
                            const Text(
                              'Fat',
                              style: TextStyle(fontSize: 12),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(
                      height: 30), //carbonhydrates, protein, fat과 아침 점심 저녁 사이 공간
                  SizedBox(
                    height: 250,
                    child: _buildMultiColumnChart(),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(top: 10.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        Text(
                          '아침',
                          style: TextStyle(color: Colors.blue),
                        ),
                        Text(
                          '점심',
                          style: TextStyle(color: Colors.green),
                        ),
                        Text(
                          '저녁',
                          style: TextStyle(color: Colors.orange),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 30),
                  Center(
                    child: DefaultTextStyle(
                      style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Colors.black,
                      ),
                      child: AnimatedTextKit(
                        animatedTexts: [
                          WavyAnimatedText(
                            '오늘의 칼로리 섭취량은 %kcal!',
                          ),
                        ],
                        isRepeatingAnimation: true,
                      ),
                    ),
                  ),
                  const SizedBox(height: 30),
                  Center(
                    child: SizedBox(
                      height: 250,
                      child: _buildNutrientPieChart(),
                    ),
                  ),
                  const SizedBox(height: 20),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: TextField(
                            readOnly: true,
                            decoration: InputDecoration(
                              labelText: _selectedDate == null
                                  ? '날짜 선택'
                                  : '${_selectedDate.toString().split(' ')[0]}',
                            ),
                            onTap: () async {
                              DateTime? pickedDate = await showDatePicker(
                                context: context,
                                initialDate: DateTime.now(),
                                firstDate: DateTime(2000),
                                lastDate: DateTime(2101),
                              );
                              if (pickedDate != null) {
                                setState(() {
                                  _selectedDate = pickedDate;
                                });
                              }
                            },
                          ),
                        ),
                        const SizedBox(width: 10),
                        ElevatedButton(
                          onPressed: _showFoodDetails,
                          child: const Text('그날 먹은 음식'),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),
                  ListView.builder(
                    shrinkWrap: true,
                    physics: NeverScrollableScrollPhysics(),
                    itemCount: _images.length,
                    itemBuilder: (context, index) {
                      final imageModel = _images[index];
                      return Card(
                        child: Column(
                          children: [
                            Image.file(
                              imageModel.image,
                              height: 200,
                              width: double.infinity,
                              fit: BoxFit.cover,
                            ),
                            const SizedBox(height: 10),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                IconButton(
                                  icon: Icon(
                                    imageModel.isLiked
                                        ? Icons.favorite
                                        : Icons.favorite_border,
                                    color: imageModel.isLiked
                                        ? Colors.red
                                        : Colors.grey,
                                  ),
                                  onPressed: () {
                                    toggleLike(index);
                                  },
                                ),
                                Expanded(
                                  child: Text(
                                    imageModel.caption,
                                    textAlign: TextAlign.center,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                  const SizedBox(height: 20),
                  SizedBox(
                    height: 300,
                    child: _buildCaloriesChart(),
                  ),
                ],
              ),
            ),
            Center(
              child: Text(
                'SNS',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
            ),
          ],
        ),
        bottomNavigationBar: CircleNavBar(
          activeIcons: const [
            Icon(Icons.home, color: Colors.deepPurple),
            Icon(Icons.photo_camera, color: Colors.deepPurple),
            Icon(Icons.group, color: Colors.deepPurple),
          ],
          inactiveIcons: const [
            Text("Home"),
            Text("Camera"),
            Text("SNS"),
          ],
          color: Colors.deepPurple.shade100,
          circleColor: Colors.white,
          height: 60,
          circleWidth: 60,
          activeIndex: _selectedIndex,
          onTap: (index) {
            setState(() {
              _selectedIndex = index;
            });
            if (index == 1) {
              _showImageSourceDialog();
            }
            if (index == 2) {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (context) => HomeScreen()),
              );
            }
          },
          padding: EdgeInsets.only(
              left: mq.width * 0.00,
              right: mq.width * 0.00,
              bottom: mq.height * 0.062), //메뉴창,
          cornerRadius: const BorderRadius.only(
            topLeft: Radius.circular(8),
            topRight: Radius.circular(8),
            bottomRight: Radius.circular(24),
            bottomLeft: Radius.circular(24),
          ),
          shadowColor: Colors.deepPurple,
          elevation: 10, //발광하는 보라색 부분
        ),
        floatingActionButton: FloatingActionButton(
            onPressed: () {
              Navigator.push(
                  context, MaterialPageRoute(builder: (_) => GeminiScreen()));
            },
            child: Image.asset(
              'images/bears.png',
              width: mq.width * 0.12,
              height: mq.height * 0.12,
            )
        )
    );
  }

  SfCircularChart _buildLargeCircularChart() {
    return SfCircularChart(
      series: <CircularSeries>[
        DoughnutSeries<_ChartData, String>(
          dataSource: mealData,
          pointColorMapper: (_ChartData data, _) => data.color,
          xValueMapper: (_ChartData data, _) => data.x,
          yValueMapper: (_ChartData data, _) => data.y,
          dataLabelSettings: DataLabelSettings(isVisible: true),
        )
      ],
      title: ChartTitle(text: 'Meal Nutrients Breakdown'),
    );
  }

  SfCircularChart _buildSmallCircularChart(String title, double value, Color color) {
    return SfCircularChart(
      series: <CircularSeries>[
        DoughnutSeries<_ChartData, String>(
          dataSource: [
            _ChartData(title, value, color),
          ],
          pointColorMapper: (_ChartData data, _) => data.color,
          xValueMapper: (_ChartData data, _) => data.x,
          yValueMapper: (_ChartData data, _) => data.y,
          dataLabelSettings: DataLabelSettings(isVisible: true),
        )
      ],
      annotations: <CircularChartAnnotation>[
        CircularChartAnnotation(
          widget: Text(
            '${value.toInt()}%',
            style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
          ),
        )
      ],
    );
  }

  SfCartesianChart _buildMultiColumnChart() {
    return SfCartesianChart(
      primaryXAxis: CategoryAxis(),
      primaryYAxis: NumericAxis(
        minimum: 0,
        maximum: 1000,
        interval: 100,
      ),
      tooltipBehavior: _tooltip,
      series: <CartesianSeries>[
        ColumnSeries<_ChartData, String>(
          dataSource: mealData,
          xValueMapper: (_ChartData data, _) => data.x,
          yValueMapper: (_ChartData data, _) => data.y,
          pointColorMapper: (_ChartData data, _) => data.color,
          name: 'Nutrients',
          dataLabelSettings: DataLabelSettings(isVisible: true),
        ),
      ],
    );
  }

  SfCircularChart _buildNutrientPieChart() {
    final List<_ChartData> pieData = [
      _ChartData('Carbohydrates', _parseDouble(_chartData?['car_t']), Colors.blue),
      _ChartData('Protein', _parseDouble(_chartData?['pro_t']), Colors.green),
      _ChartData('Fat', _parseDouble(_chartData?['fat_t']), Colors.orange),
    ];

    return SfCircularChart(
      series: <CircularSeries>[
        PieSeries<_ChartData, String>(
          dataSource: pieData,
          pointColorMapper: (_ChartData data, _) => data.color,
          xValueMapper: (_ChartData data, _) => data.x,
          yValueMapper: (_ChartData data, _) => data.y,
          dataLabelSettings: DataLabelSettings(isVisible: true),
        )
      ],
      title: ChartTitle(text: 'Nutrient Breakdown'),
    );
  }

  SfCartesianChart _buildCaloriesChart() {
    final List<_ChartData> calorieData = [
      _ChartData('월요일', 2200, Colors.blue),
      _ChartData('화요일', 1800, Colors.blue),
      _ChartData('수요일', 2500, Colors.blue),
      _ChartData('목요일', 2000, Colors.blue),
      _ChartData('금요일', 2100, Colors.blue),
      _ChartData('토요일', 2300, Colors.blue),
      _ChartData('일요일', 1900, Colors.blue),
    ];

    return SfCartesianChart(
      primaryXAxis: CategoryAxis(),
      primaryYAxis: NumericAxis(
        minimum: 0,
        maximum: 3000,
        interval: 500,
      ),
      tooltipBehavior: TooltipBehavior(enable: true),
      series: <CartesianSeries>[
        LineSeries<_ChartData, String>(
          dataSource: calorieData,
          xValueMapper: (_ChartData data, _) => data.x,
          yValueMapper: (_ChartData data, _) => data.y,
          pointColorMapper: (_ChartData data, _) => data.color,
          name: 'Calories',
          dataLabelSettings: DataLabelSettings(isVisible: true),
        ),
      ],
    );
  }
}

class _ChartData {
  _ChartData(this.x, this.y, this.color);

  final String x;
  final double y;
  final Color color;
}

class ImageModel {
  final File image;
  bool isLiked;
  final String caption;

  ImageModel(this.image, this.isLiked, this.caption);
}
