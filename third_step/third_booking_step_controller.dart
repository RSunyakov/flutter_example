import 'package:flutter/cupertino.dart';
import 'package:get/get.dart';
import 'package:teremok/ui/screens/booking/src/booking_arguments.dart';
import 'package:teremok/ui/screens/booking/src/booking_service.dart';
import 'package:vfx_flutter_common/get_rx_decorator.dart';
import 'package:vfx_flutter_common/vfx_flutter_common.dart';

class BookingBed {
  BookingBed(
      {required this.bedImgPath,
      required this.title,
      required this.price,
      this.roomId,
      this.bedId});

  final int? roomId;

  final int? bedId;

  final String bedImgPath;

  final String title;

  final double price;
}

class ThirdBookingStepController extends StatexController {
  ThirdBookingStepController({BookingService? bookingService})
      : _bookingService = bookingService ?? Get.find();

  final BookingService _bookingService;

  GetRxDecorator<DateTime> get startDate => _bookingService.startDate;

  GetRxDecorator<DateTime> get endDate => _bookingService.endDate;

  GetRxDecorator<Map<BookingBed, bool>> get roomMap => _bookingService.bedMap;

  final isRefugee = false.obsDeco();

  GetRxDecorator<BookingArguments> get arguments => _bookingService.arguments;

  GetRxDecoratorBool get isLoading => _bookingService.isLoading;

  final couponController = TextEditingController();

  int get durationInDays => _bookingService.durationInDays.value;

  String getStartDate() {
    return _bookingService.getStartDate();
  }

  String getEndDate() {
    return _bookingService.getEndDate();
  }

  String getShortStartDate() {
    return _bookingService.getShortStartDate();
  }

  String getShortEndDate() {
    return _bookingService.getShortEndDate();
  }

  void tapOnRoom(BookingBed room) {
    final prevVal = roomMap.value[room] ?? false;
    roomMap.value[room] = !prevVal;
    roomMap.refresh();
    _bookingService.finallyPrice.refresh();
  }

  double getPrice(double price) => _bookingService.getPrice(price);

  double getFinallyPrice() => _bookingService.finallyPrice();

  void createBooking() {
    _bookingService.createBooking();
  }
}
