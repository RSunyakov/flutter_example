import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl_phone_number_input/intl_phone_number_input.dart';
import 'package:teremok/domain/booking/booking_dates.dart';
import 'package:teremok/domain/core/value_objects.dart';
import 'package:teremok/logic/core/app_store_service.dart';
import 'package:teremok/logic/core/data_types.dart';
import 'package:teremok/logic/enter/enter_bloc.dart';
import 'package:teremok/ui/router/routing.dart';
import 'package:teremok/ui/screens/booking/src/booking_service.dart';
import 'package:teremok/ui/screens/enter/src/enter_screen_service.dart';
import 'package:teremok/ui/shared/all_shared.dart';
import 'package:teremok/ui/shared/app_alert.dart';
import 'package:teremok/ui/shared/consts.dart';
import 'package:teremok/ui/shared/widgets/app_bottom_sheet/app_bottom_sheet.dart';
import 'package:vfx_flutter_common/get_rx_decorator.dart';
import 'package:vfx_flutter_common/getx_helpers.dart';

import 'booking_arguments.dart';

class BookingMainController extends StatexController {
  BookingMainController(
      {AppStoreService? appStoreService,
      EnterScreenService? enterService,
      BookingService? bookingService})
      : _appStoreService = appStoreService ?? Get.find(),
        _enterService = enterService ?? Get.find(),
        _bookingService = bookingService ?? Get.find();

  final BookingService _bookingService;

  final AppStoreService _appStoreService;

  final EnterScreenService _enterService;

  GetRxDecorator<ErrOrUser> get user => _appStoreService.user;

  GetRxDecoratorInt get adultCount => _bookingService.adultCount;

  final isLoading = false.obsDeco();

  GetRxDecoratorBool get isDateLoading => _bookingService.isLoading;

  GetRxDecoratorInt get childCount => _bookingService.childCount;

  final phoneInputValidation = false.obsDeco();

  GetRxDecoratorBool get passwordError => _enterService.passwordError;

  final passwordCtrl = TextEditingController();

  var hidePassword = true.obsDeco();

  final passwordInputValidation = false.obsDeco();

  final calendarError = false.obsDeco();

  GetRxDecorator<DateTime> get startDate => _bookingService.startDate;

  GetRxDecorator<DateTime> get endDate => _bookingService.endDate;

  GetRxDecorator<BookingArguments> get arguments => _bookingService.arguments;

  GetRxDecorator<EnterState> get state => _enterService.state;

  GetRxDecorator<BookingDates> get bookingDates => _bookingService.bookingDates;

  bool get isButtonEnabled =>
      phoneInputValidation.value && passwordInputValidation.value;

  @override
  void onInit() {
    super.onInit();
    if (Get.arguments != null) {
      final arg = Get.arguments as BookingArguments;
      arguments.value = arg;
      _bookingService.getDates();
      arguments.refresh();
      _bookingService.refreshArguments();
    }
  }

  void passwordInputChanged(String value) => value.isEmpty
      ? passwordInputValidation.value = false
      : passwordInputValidation.value = true;

  bool isAuthorized() {
    var isAuthorized = false;
    user.value.fold((l) {
      isAuthorized = false;
    }, (r) {
      isAuthorized = true;
    });
    return isAuthorized;
  }

  void phoneInputChanged(PhoneNumber value) {
    var number = value.phoneNumber?.substring(value.dialCode?.length ?? 0);
    if (number?.length == 10) {
      phoneInputValidation.value = true;
      _enterService.phone.value = Phone(value.phoneNumber ?? '');
    } else {
      phoneInputValidation.value = false;
      _enterService.phone.value = Phone('');
    }
  }

  void toRestorePasswordScreen() => Get.toNamed(AppRoutes.restorePassword,
      arguments: Consts.restorePasswordArgument);

  void pressEnter() {
    _enterService.password.value = Password(passwordCtrl.text);
    _enterService.tryEnter();
  }

  @override
  void onReady() {
    super.onReady();
    state.stream.listen(_stateProcessing);
  }

  void _stateProcessing(EnterState state) {
    state.maybeWhen(
      enterTried: (d) {
        d.maybeWhen(
          result: (r) {
            isLoading(false);
            r.fold(
              (l) => null,
              (r) => Get.offAllNamed(AppRoutes.booking),
            );
          },
          orElse: () => isLoading(true),
        );
      },
      orElse: () {},
    );
  }

  void openBottomSheet(BuildContext context, Widget child) {
    OpenBottomSheet.open(
      context,
      child,
      height: Get.height - 170,
      isScrollControlled: true,
      enableDrag: true,
      isAdaptiveKeyboard: true,
    );
  }

  void savePeopleCount(int adult, int child) {
    adultCount.value = adult;
    childCount.value = child;
    Get.back();
  }

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

  void clearCalendar() {
    startDate.value = DateTime.now();
    endDate.value = DateTime.now();
  }

  void toNextStep() => Get.toNamed(AppRoutes.secondStepBooking);

  double getFinallyPrice() => _bookingService.finallyPrice();

  bool bookedDay(DateTime firstDate, DateTime? secondDate) {
    var listIsBook = [];
    final listDays = getBookedDates();
    var days = [];

    final diff = secondDate?.difference(firstDate).inDays ?? 0;
    for (var i = 0; i < (diff - 1); i++) {
      days.add(
          DateTime(firstDate.year, firstDate.month, firstDate.day + (i + 1)));
    }
    for (DateTime day in listDays) {
      listIsBook.add(days.contains(day));
    }
    return listIsBook.contains(true);
  }

  List<DateTime> getBookedDates() {
    var days = <DateTime>[];
    for (var element in bookingDates.value.reserve) {
      final daysToGenerate = element.to.difference(element.from).inDays;
      days.add(
          DateTime(element.from.year, element.from.month, element.from.day));
      for (int i = 1; i <= daysToGenerate; i++) {
        days.add(DateTime(
            element.from.year, element.from.month, element.from.day + i));
      }
    }
    return days;
  }

  void onRangeSelected(DateTime firstDate, DateTime? secondDate) {
    if (secondDate != null) {
      if (bookedDay(firstDate, secondDate)) {
        clearCalendar();
        appAlert(
          // TODO: localization
          value: 'В вашем выборе есть забронированные даты',
          color: AppColors.dangerPrimary,
        );
      } else {
        calendarError.value = false;
        startDate.value = firstDate;
        endDate.value = secondDate;
      }
    } else {
      calendarError.value = true;
    }
  }
}
