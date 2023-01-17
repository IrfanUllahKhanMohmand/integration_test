import 'dart:convert';
import 'dart:developer';
import 'dart:io';
import 'dart:isolate';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:http/http.dart' as http;
import 'package:image_cropper/image_cropper.dart';
import 'package:path_provider/path_provider.dart';
import 'package:provider/provider.dart';
import 'package:stories_editor/src/domain/models/editable_items.dart';
import 'package:stories_editor/src/domain/providers/notifiers/control_provider.dart';
import 'package:stories_editor/src/domain/providers/notifiers/draggable_widget_notifier.dart';
import 'package:stories_editor/src/domain/providers/notifiers/painting_notifier.dart';
import 'package:stories_editor/src/domain/providers/notifiers/scroll_notifier.dart';
import 'package:stories_editor/src/presentation/utils/constants/app_enums.dart';
import 'package:transparent_image/transparent_image.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:flutter_downloader/flutter_downloader.dart';
import 'package:uuid/uuid.dart';

class PickOnlineImages extends StatefulWidget {
  const PickOnlineImages({super.key});

  @override
  State<PickOnlineImages> createState() => _PickOnlineImagesState();
}

class _PickOnlineImagesState extends State<PickOnlineImages> {
  var urlData;
  var _scrollController;
  getApiData() async {
    var url = Uri.parse(
        'https://api.unsplash.com/photos/?per_page=30&client_id=XgscPMNOWiabPbYstw2sBRekrTsurK84QLyCA9la7Tk');
    final res = await http.get(url);
    setState(() {
      urlData = jsonDecode(res.body);
      print(urlData);
    });
  }

  List<String> imageList = [
    'https://cdn.pixabay.com/photo/2019/03/15/09/49/girl-4056684_960_720.jpg',
    'https://cdn.pixabay.com/photo/2020/12/15/16/25/clock-5834193__340.jpg',
    'https://cdn.pixabay.com/photo/2020/09/18/19/31/laptop-5582775_960_720.jpg',
    'https://media.istockphoto.com/photos/woman-kayaking-in-fjord-in-norway-picture-id1059380230?b=1&k=6&m=1059380230&s=170667a&w=0&h=kA_A_XrhZJjw2bo5jIJ7089-VktFK0h0I4OWDqaac0c=',
    'https://cdn.pixabay.com/photo/2019/11/05/00/53/cellular-4602489_960_720.jpg',
    'https://cdn.pixabay.com/photo/2017/02/12/10/29/christmas-2059698_960_720.jpg',
    'https://cdn.pixabay.com/photo/2020/01/29/17/09/snowboard-4803050_960_720.jpg',
    'https://cdn.pixabay.com/photo/2020/02/06/20/01/university-library-4825366_960_720.jpg',
    'https://cdn.pixabay.com/photo/2020/11/22/17/28/cat-5767334_960_720.jpg',
    'https://cdn.pixabay.com/photo/2020/12/13/16/22/snow-5828736_960_720.jpg',
    'https://cdn.pixabay.com/photo/2020/12/09/09/27/women-5816861_960_720.jpg',
  ];
  @override
  void initState() {
    super.initState();
    getApiData();
    _scrollController = ScrollController();
    _scrollController.addListener(() {
      if (_scrollController.hasClients) {
        if (_scrollController.position.minScrollExtent ==
            _scrollController.offset) {
          Provider.of<ScrollNotifier>(context, listen: false)
              .pageController
              .animateToPage(0,
                  duration: const Duration(milliseconds: 300),
                  curve: Curves.easeIn);
        }
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        backgroundColor: Colors.white24,
        body: urlData != null
            ? Container(
                margin: const EdgeInsets.all(5),
                child: MasonryGridView.count(
                  controller: _scrollController,
                  crossAxisCount: 2,
                  crossAxisSpacing: 5,
                  mainAxisSpacing: 5,
                  itemCount: 30,
                  itemBuilder: (context, index) {
                    return GestureDetector(
                      // onPanUpdate: (details) {
                      //   if (_scrollController.position.maxScrollExtent ==
                      //       _scrollController.offset) {
                      //     Provider.of<ScrollNotifier>(context, listen: false)
                      // .pageController
                      // .animateToPage(0,
                      //     duration: const Duration(milliseconds: 300),
                      //     curve: Curves.easeIn);
                      //   }
                      // },
                      // onVerticalDragEnd: (details) {
                      //   if (Provider.of<ScrollNotifier>(context, listen: false)
                      //           .pageController
                      //           .page ==
                      //       1.0) {
                      //     Provider.of<ScrollNotifier>(context, listen: false)
                      //         .pageController
                      //         .animateToPage(0,
                      //             duration: const Duration(milliseconds: 300),
                      //             curve: Curves.easeIn);
                      //   }
                      //   log(Provider.of<ScrollNotifier>(context, listen: false)
                      //       .pageController
                      //       .page
                      //       .toString());
                      // },
                      onTap: () {
                        Provider.of<PaintingNotifier>(context, listen: false)
                                .fullImageViewUrl =
                            urlData[index]['urls']['regular'];
                        Provider.of<PaintingNotifier>(context, listen: false)
                                .fullImageViewDownloadLink =
                            urlData[index]['links']['download'];
                        Provider.of<PaintingNotifier>(context, listen: false)
                            .fullImageViewIndex = index;

                        Provider.of<ScrollNotifier>(context, listen: false)
                            .pageController
                            .animateToPage(2,
                                duration: const Duration(milliseconds: 300),
                                curve: Curves.easeIn);
                        // Navigator.push(context,
                        //     MaterialPageRoute(builder: (context) {
                        //   return FullImageView(
                        //     url: urlData[index]['urls']['regular'],
                        //     ind: index,
                        //     downloadLink: urlData[index]['links']['download'],
                        //   );
                        // }));
                      },
                      child: Container(
                        decoration: const BoxDecoration(
                            color: Colors.transparent,
                            borderRadius:
                                BorderRadius.all(Radius.circular(15))),
                        child: ClipRRect(
                          borderRadius:
                              const BorderRadius.all(Radius.circular(5)),
                          child: FadeInImage.memoryNetwork(
                            placeholder: kTransparentImage,
                            image: urlData[index]['urls']['regular'],
                            fit: BoxFit.cover,
                          ),
                        ),
                      ),
                    );
                  },
                ),
              )
            : Container(
                margin: const EdgeInsets.all(5),
                child: MasonryGridView.count(
                  crossAxisCount: 2,
                  crossAxisSpacing: 5,
                  mainAxisSpacing: 5,
                  itemCount: imageList.length,
                  itemBuilder: (context, index) {
                    return InkWell(
                      onTap: () {
                        Provider.of<PaintingNotifier>(context, listen: false)
                            .fullImageViewUrl = imageList[index];
                        Provider.of<PaintingNotifier>(context, listen: false)
                            .fullImageViewDownloadLink = imageList[index];
                        Provider.of<PaintingNotifier>(context, listen: false)
                            .fullImageViewIndex = index;

                        Provider.of<ScrollNotifier>(context, listen: false)
                            .pageController
                            .animateToPage(2,
                                duration: const Duration(milliseconds: 300),
                                curve: Curves.easeIn);
                      },
                      child: Hero(
                        tag: index,
                        child: Container(
                          decoration: const BoxDecoration(
                              color: Colors.transparent,
                              borderRadius:
                                  BorderRadius.all(Radius.circular(15))),
                          child: ClipRRect(
                            borderRadius:
                                const BorderRadius.all(Radius.circular(5)),
                            child: FadeInImage.memoryNetwork(
                              placeholder: kTransparentImage,
                              image: imageList[index],
                              fit: BoxFit.cover,
                            ),
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
      ),
    );
  }
}

class FullImageView extends StatefulWidget {
  final String url;
  final int ind;
  final String downloadLink;
  const FullImageView(
      {super.key,
      required this.url,
      required this.ind,
      required this.downloadLink});

  @override
  State<FullImageView> createState() => _FullImageViewState();
}

class _FullImageViewState extends State<FullImageView> {
  late var baseStorage;
  late var uuid;
  final ReceivePort _port = ReceivePort();
  @override
  void initState() {
    super.initState();

    IsolateNameServer.registerPortWithName(
        _port.sendPort, 'downloader_send_port');
    _port.listen((dynamic data) async {
      String id = data[0];
      DownloadTaskStatus status = data[1];
      int progress = data[2];

      if (status == DownloadTaskStatus.complete) {
        CroppedFile? croppedFile = await ImageCropper().cropImage(
          sourcePath: "${baseStorage!.path}/$uuid",
          aspectRatioPresets: Platform.isAndroid
              ? [
                  CropAspectRatioPreset.square,
                  CropAspectRatioPreset.ratio3x2,
                  CropAspectRatioPreset.original,
                  CropAspectRatioPreset.ratio4x3,
                  CropAspectRatioPreset.ratio16x9
                ]
              : [
                  CropAspectRatioPreset.original,
                  CropAspectRatioPreset.square,
                  CropAspectRatioPreset.ratio3x2,
                  CropAspectRatioPreset.ratio4x3,
                  CropAspectRatioPreset.ratio5x3,
                  CropAspectRatioPreset.ratio5x4,
                  CropAspectRatioPreset.ratio7x5,
                  CropAspectRatioPreset.ratio16x9
                ],
          uiSettings: [
            AndroidUiSettings(
                toolbarColor: Colors.black,
                toolbarWidgetColor: Colors.white,
                // initAspectRatio: CropAspectRatioPreset.original,
                hideBottomControls: true,
                lockAspectRatio: false),
            IOSUiSettings(
              title: 'Cropper',
            ),
            WebUiSettings(
              context: context,
            ),
          ],
        );

        Provider.of<ControlNotifier>(context, listen: false).mediaPath =
            croppedFile!.path.toString();
        // controlNotifier.mediaPath = path.first.path!.toString();
        if (Provider.of<ControlNotifier>(context, listen: false)
            .mediaPath
            .isNotEmpty) {
          Provider.of<DraggableWidgetNotifier>(context, listen: false)
              .draggableWidget
              .insert(
                  0,
                  EditableItem()
                    ..type = ItemType.image
                    ..position = const Offset(0.0, 0));
        }
        Provider.of<ScrollNotifier>(context, listen: false)
            .pageController
            .animateToPage(0,
                duration: const Duration(milliseconds: 300),
                curve: Curves.easeIn);
      }
      setState(() {});
    });

    FlutterDownloader.registerCallback(downloadCallback);
  }

  @override
  void dispose() {
    IsolateNameServer.removePortNameMapping('downloader_send_port');
    super.dispose();
  }

  @pragma('vm:entry-point')
  static void downloadCallback(
      String id, DownloadTaskStatus status, int progress) {
    final SendPort? send =
        IsolateNameServer.lookupPortByName('downloader_send_port');
    send!.send([id, status, progress]);
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      child: InkWell(
        onTap: () {
          download(widget.url);
          log(widget.downloadLink);
        },
        child: Container(
          decoration: BoxDecoration(
            image: DecorationImage(
                image: NetworkImage(widget.url), fit: BoxFit.contain),
          ),
        ),
      ),
    );
  }

  download(String url) async {
    var status = await Permission.storage.request();
    if (status.isGranted) {
      baseStorage = await getExternalStorageDirectory();
      uuid = const Uuid().v4();
      await FlutterDownloader.enqueue(
        fileName: uuid,
        url: url,
        headers: {}, // optional: header send with url (auth token etc)
        savedDir: baseStorage!.path,
        showNotification:
            true, // show download progress in status bar (for Android)
        openFileFromNotification:
            true, // click on notification to open downloaded file (for Android)
      );
    }
  }
}
