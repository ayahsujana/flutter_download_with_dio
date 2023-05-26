import 'package:dio/dio.dart';
import 'package:downloads_path_provider_28/downloads_path_provider_28.dart';
import 'package:flutter/material.dart';
import 'package:percent_indicator/percent_indicator.dart';
import 'package:permission_handler/permission_handler.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  double progressDownload = 0.0;
  bool isShow = false;
  final fileUrl =
      'https://www.mediafire.com/file_premium/xjchr2py9iv6ggt/croatian_war_of_independence%252C_december_31st_1991.zip';
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Download File from URL'),
      ),
      body: Container(
        margin: const EdgeInsets.all(20),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text('URL: $fileUrl'),
            const Divider(),
            ElevatedButton(
              onPressed: () async {
                Map<Permission, PermissionStatus> status = await [
                  Permission.storage,
                ].request();

                if (status[Permission.storage]!.isGranted) {
                  var dir = await DownloadsPathProvider.downloadsDirectory;
                  if (dir != null) {
                    isShow = true;
                    String saveName = 'test.zip';
                    String savePath = dir.path + '/$saveName';
                    print('savePath: $savePath');

                    try {
                      await Dio().download(fileUrl, savePath,
                          onReceiveProgress: (received, total) {
                        if (total != 1) {
                          setState(() {
                            progressDownload = (received / total * 100);
                            if (progressDownload == 100) {
                              //isShow = false;
                            }
                          });
                        }
                      });
                      print('File is saved to download folder.');
                    } on DioError catch (e) {
                      print(e);
                    }
                  }
                } else {
                  print('No Permission to read and write');
                }
              },
              child: const Text('Download File'),
            ),
            isShow
                ? LinearPercentIndicator(
                    animation: true,
                    animationDuration: 1000,
                    lineHeight: 20.0,
                    percent: progressDownload / 100,
                    center: Text(
                      progressDownload.toStringAsFixed(0) + '%',
                      style: const TextStyle(
                          fontSize: 12.0,
                          fontWeight: FontWeight.w600,
                          color: Colors.black),
                    ),
                    linearStrokeCap: LinearStrokeCap.roundAll,
                    progressColor: Colors.blue[400],
                    backgroundColor: Colors.grey[300],
                  )
                : const SizedBox()
          ],
        ),
      ),
    );
  }
}
