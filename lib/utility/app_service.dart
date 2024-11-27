// ignore_for_file: avoid_print

import 'dart:convert';

import 'dart:io';
import 'dart:math';

import 'package:bluetooth_thermal_printer/bluetooth_thermal_printer.dart';
import 'package:checkofficer/models/guest_model.dart';
import 'package:checkofficer/models/objective_model.dart';
import 'package:checkofficer/models/province_model.dart';
// import 'package:checkofficer/models/cartype_model.dart';
import 'package:checkofficer/utility/app_constant.dart';
import 'package:checkofficer/utility/app_controller.dart';
import 'package:checkofficer/utility/app_dialog.dart';
import 'package:checkofficer/utility/app_snackbar.dart';
import 'package:checkofficer/widgets/widget_button.dart';
import 'package:checkofficer/widgets/widget_text.dart';
import 'package:dio/dio.dart' as dio;
import 'package:dio/dio.dart';
import 'package:esc_pos_utils/esc_pos_utils.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';

import 'package:image/image.dart' as image;

import 'package:image_picker/image_picker.dart';
import 'package:screenshot/screenshot.dart';

class AppService {
  AppController appController = Get.put(AppController());

  Future<void> setupIndexApi() async {

    var indexApi = await GetStorage().read('api');

    if (indexApi !=null) {
      appController.indexApi.value=indexApi;
    }


  }



  String displayDateTime({required String dateTimeString}) {
    var strings = dateTimeString.split(' ');
    var dates = strings[0].split('-');
    var times = strings[1].split(':');

    return '${dates[2]}/${dates[1]}/${dates[0]} เวลา ${times[0]}:${times[1]}';
  }

  void dialogCallConnectedPrinter({required BuildContext context}) {
    if (!appController.connectedPrinter.value) {
      AppDialog(context: context).normalDialog(
        title: 'Connected Printer',
        contentWidget: appController.availableBluetoothDevices.isEmpty
            ? const WidgetText(data: 'ไม่มี Printer')
            : SizedBox(
                height: 100,
                width: 250,
                child: ListView.builder(
                  physics: const ScrollPhysics(),
                  shrinkWrap: true,
                  itemCount: appController.availableBluetoothDevices.length,
                  itemBuilder: (context, index) => WidgetButton(
                    label: appController.availableBluetoothDevices[index]
                        .toString(),
                    pressFunc: () {
                      AppService()
                          .processChoosePrinter(
                              printerName: appController
                                  .availableBluetoothDevices[index])
                          .then((value) => Get.back());
                    },
                  ),
                ),
              ),
      );
    }
  }

  Future<void> processPrint(
      {required String name, required String phone}) async {
    await BluetoothThermalPrinter.writeText('Test Print\n$name\n$phone\n\n\n');
  }

  Future<void> processPrintImage({required GuestModel guestModel}) async {
    CapabilityProfile profile = await CapabilityProfile.load();
    var generator = Generator(PaperSize.mm80, profile);

    List<int> bytes = <int>[];

    ScreenshotController screenshotController = ScreenshotController();
    screenshotController
        .captureFromWidget(
      SizedBox(
        width: 140,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: [ 
              WidgetText(
              data: 'หมู่บ้านเพอร์เฟค',
              textStyle: AppConstant().h4Style(color: Colors.black, size: 12),
            ),
               WidgetText(
              data: 'โคโลเนียล รามคำแหง',
              textStyle: AppConstant().h3Style(color: Colors.black, size: 12),
            ),
              WidgetText(
              data: 'รายละเอียดข้อมูลการติดต่อ',
              textStyle: AppConstant().h5Style(color: Colors.black, size: 10),
            ),
            WidgetText(
              data: 'ทะเบียนรถ : ${guestModel.carId}',
              textStyle: AppConstant().h5Style(color: Colors.black, size: 10),
            ),
            WidgetText(
              data: 'จังหวัด : ${guestModel.province}',
              textStyle: AppConstant().h5Style(color: Colors.black, size: 10),
            ),
            WidgetText(
              data: 'ข้อมูลการติดต่อ : ${guestModel.objective}',
              textStyle: AppConstant().h5Style(color: Colors.black, size: 10),
            ),
            WidgetText(
              data: 'หมายเหตุ : ${guestModel.remark}',
              textStyle: AppConstant().h5Style(color: Colors.black, size: 10),
            ),
            // const Divider(),
            WidgetText(
              data: 'เวลาเข้า : ${guestModel.checkIn}',
              textStyle: AppConstant().h3Style(color: Colors.black, size: 10),
            ),
            // const Divider(),
            // const Divider(),

            WidgetText(
              data: '-------------------------------',
              textStyle: AppConstant().h4Style(color: Colors.black, size: 8),
            ),
            // WidgetText(
            //   data: 'การเก็บรวบรวมใช้หรือเปิดเผย',
            //   textStyle: AppConstant().h4Style(color: Colors.black, size: 8),
            // ),
            // WidgetText(
            //   data: 'ข้อมูลส่วนบุคลของท่านเพื่อใช้ ',
            //   textStyle: AppConstant().h4Style(color: Colors.black, size: 8),
            // ),
            // WidgetText(
            //   data: 'ในการรักษาความปลอดภัย',
            //   textStyle: AppConstant().h4Style(color: Colors.black, size: 8),
            // ),
            // WidgetText(
            //   data: 'นิติบุคลหมู่บ้านจัดสรร',
            //   textStyle: AppConstant().h4Style(color: Colors.black, size: 8),
            // ),
            // WidgetText(
            //   data: 'มาย์ด ฮอฟฟ์ สุวรรณภูมิ และ',
            //   textStyle: AppConstant().h4Style(color: Colors.black, size: 8),
            // ),
            // WidgetText(
            //   data: 'ลูกบ้านของโครงการ หมู่บ้านเท่านั้น',
            //   textStyle: AppConstant().h4Style(color: Colors.black, size: 8),
            // ),

            // const Divider(),
            // const Divider(),
            // const Divider(),
            // const Divider(
            //   color: Colors.black,
            // ),
            const Divider(),
            Container(
              margin: const EdgeInsets.symmetric(vertical: 16),
              width: 120,
              height: 80,
              alignment: Alignment.center,
              decoration: BoxDecoration(border: Border.all()),
              child: WidgetText(
                data: 'ตราประทับ',
                textStyle: AppConstant().h5Style(color: Colors.black, size: 10),
              ),
            ),
          ],
        ),
      ),
    )
        .then((value) async {
      final myImage = image.decodeImage(value);
      bytes += generator.image(myImage!);

      bytes += generator.qrcode(guestModel.id!,size: QRSize.Size6);

      bytes += generator.text('\n\n\n\n\n');

      await BluetoothThermalPrinter.writeBytes(bytes);
    });
  }

  Future<void> processChoosePrinter({required String printerName}) async {
    print('printName ---> $printerName');
    var macs = printerName.split('#');
    print('mas.last----> ${macs.last}');
    try {
      await BluetoothThermalPrinter.connect(macs.last).then((value) {
        print('value at processChoosePrinter ---> $value');
        if (value.toString() == 'true') {
          appController.connectedPrinter.value = true;
        }
      });
    } on Exception catch (e) {
      print('onError -----> $e');
    }
  }

  Future<void> proccessGetBluetooth() async {
    await BluetoothThermalPrinter.getBluetooths.then((value) {
      if (value != null) {
        appController.availableBluetoothDevices.addAll(value);
      }
    });
  }

  Future<void> readAllGuest() async {
    String urlApi = AppConstant.apiReadAllGurests[appController.indexApi.value];

    if (appController.guestModels.isNotEmpty) {
      appController.guestModels.clear();
      appController.listUrlImages.clear();
    }

    await dio.Dio().get(urlApi).then((value) {
      for (var element in json.decode(value.data)) {
        GuestModel model = GuestModel.fromMap(element);

        print('##1nov guestModel ---> ${model.toMap()}');

        appController.guestModels.add(model);

        var urlImages = <String>[];
        if (model.urlImage1.isNotEmpty) {
          urlImages.add(model.urlImage1);
        }
        if (model.urlImage2.isNotEmpty) {
          urlImages.add(model.urlImage2);
        }
        if (model.urlImage3.isNotEmpty) {
          urlImages.add(model.urlImage3);
        }

        appController.listUrlImages.add(urlImages);
      }
    });
  }

  Future<void> processAddGuest({
    required String nameAndSurname,
    required String phone,
    required String carId,
    required String province,
    required String objective,
    required String remark, required String cartype,
  }) async {
    String urlApiUpload = 'https://tswg.site/app/saveFile.php';

    var files = <File?>[];
    if (appController.avatarFiles.isNotEmpty) {
      files.add(appController.avatarFiles.last);
    } else {
      files.add(null);
    }

    if (appController.carFiles.isNotEmpty) {
      files.add(appController.carFiles.last);
    } else {
      files.add(null);
    }

    if (appController.cardFiles.isNotEmpty) {
      files.add(appController.cardFiles.last);
    } else {
      files.add(null);
    }

    var urlImages = <String>[
      '',
      '',
      '',
    ];
    int index = 0;

    for (var element in files) {
      if (element != null) {
        String nameFile = 'image${Random().nextInt(1000000)}.jpg';
        Map<String, dynamic> map = {};
        map['file'] =
            await dio.MultipartFile.fromFile(element.path, filename: nameFile);
        dio.FormData formData = dio.FormData.fromMap(map);
        await dio.Dio().post(urlApiUpload, data: formData).then((value) {
          print('upload $nameFile success');
          urlImages[index] = 'https://tswg.site/app/image/$nameFile';
        });
      }

      index++;
    }

    if (urlImages.isNotEmpty) {
      String urlApiInsertGuest = '${AppConstant.apiInsertGuests[appController.indexApi.value]}$nameAndSurname&phone=$phone&carId=$carId&province=$province&cartype=$cartype&objective=$objective&urlImage1=${urlImages[0]}&urlImage2=${urlImages[1]}&urlImage3=${urlImages[2]}&checkIn=${DateTime.now().toString()}&remark=$remark';
      print('##7nov urlApiInsert --> $urlApiInsertGuest');
      await dio.Dio().get(urlApiInsertGuest).then((value) {
        Get.back();
        AppSnackBar(
                title: 'Add Guest Success', message: 'Thankyou for Add Guest')
            .normalSnackBar();
      });
    }
  }

  Future<File> processTakePhoto() async {
    var result = await ImagePicker()
        .pickImage(source: ImageSource.camera, maxWidth: 800, maxHeight: 800);
    File file = File(result!.path);
    appController.totalFiles.add(file);
    return file;
  }

  Future<void> readAllObjective() async {
    String urlApi = 'https://tswg.site/app/getAllObjectiveUng.php';
    await dio.Dio().get(urlApi).then((value) {
      if (appController.objectiveModels.isNotEmpty) {
        appController.objectiveModels.clear();
        appController.chooseObjectives.clear();
        appController.chooseObjectives.add(null);
      }

      for (var element in json.decode(value.data)) {
        ObjectiveModel model = ObjectiveModel.fromMap(element);
        appController.objectiveModels.add(model);
      }
    });
  }

  Future<void> readAllProvince() async {
    String urlApi = 'https://www.androidthai.in.th/flutter/getAllprovinces.php';
    await dio.Dio().get(urlApi).then((value) {
      if (appController.provinceModels.isNotEmpty) {
        appController.provinceModels.clear();
        appController.chooseProvinces.clear();
        appController.chooseProvinces.add(null);
      }

      for (var element in json.decode(value.data)) {
        ProvinceModel model = ProvinceModel.fromMap(element);
        appController.provinceModels.add(model);
      }
    });
  }

  Future<void> processFindGuestModel({required String dataScan}) async {
    String urlApiEdit =
        '${AppConstant.apiEditCheckOuts[appController.indexApi.value]}$dataScan&checkOut=${DateTime.now().toString()}';

    await Dio().get(urlApiEdit).then((value) async {
      String url =
          '${AppConstant.apiGetGuests[appController.indexApi.value]}$dataScan';

      await Dio().get(url).then((value) {
        if (value.toString() != 'null') {
          for (var element in json.decode(value.data)) {
            // guestModel = GuestModel.fromMap(element);
            // setState(() {});
            GuestModel guestModel = GuestModel.fromMap(element);
            appController.qrGuestModels.add(guestModel);
          }
        }
      });
    });
  }
}
