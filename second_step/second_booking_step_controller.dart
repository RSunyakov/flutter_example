import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:teremok/ui/router/routing.dart';
import 'package:teremok/ui/screens/booking/src/booking_arguments.dart';
import 'package:teremok/ui/screens/booking/src/booking_service.dart';
import 'package:teremok/ui/shared/all_shared.dart';
import 'package:vfx_flutter_common/get_rx_decorator.dart';
import 'package:vfx_flutter_common/getx_helpers.dart';

enum BankEnum {
  sber('СБЕР'),
  tinkoff('TINKOFF'),
  mts('МТС БАНК');

  const BankEnum(this.name);
  final String name;
}

enum PaymentSystem {
  masterCard('master_card'),
  visa('visa'),
  mir('МИР');

  const PaymentSystem(this.name);
  final String name;
}

//Класс-заглушка, пока не подтягиваю данные с бэка
class AmenityBook {
  AmenityBook(
      {required this.title,
      required this.price,
      required this.value,
      required this.iconPath});

  String title;
  int price;
  bool value;
  String iconPath;
}

class CardInfo {
  CardInfo(
      {required this.bankName,
      required this.lastCardNumber,
      required this.paymentSystem}) {
    switch (paymentSystem) {
      case PaymentSystem.masterCard:
        paymentSystemWidget = Image.asset(
          AppIcons.masterCard,
          width: 23.r,
          height: 16.r,
        );
        break;
      case PaymentSystem.visa:
        paymentSystemWidget = Image.asset(
          AppIcons.visa,
          width: 23.r,
          height: 16.r,
        );
        break;
      case PaymentSystem.mir:
        paymentSystemWidget = AppText(
          PaymentSystem.mir.name,
          type: AppTextType.mMedium,
          color: AppColors.white,
        );
        break;
    }

    switch (bankName) {
      case BankEnum.tinkoff:
        bankNameWidget = AppText(
          BankEnum.tinkoff.name,
          type: AppTextType.sMedium,
          color: AppColors.white,
        );
        backgroundColor = AppColors.paymentTink;
        break;
      case BankEnum.sber:
        bankNameWidget = Row(
          children: [
            Image.asset(
              AppIcons.sber,
              width: 16.r,
              height: 16.r,
              color: AppColors.white,
            ),
            5.sbWidthA,
            AppText(
              BankEnum.sber.name,
              type: AppTextType.sRegular,
              color: AppColors.white,
            ),
          ],
        );
        backgroundColor = AppColors.paymentSber;
        break;
      case BankEnum.mts:
        bankNameWidget = const AppText(
          'МТС БАНК',
          type: AppTextType.sRegular,
          color: AppColors.white,
        );
        backgroundColor = AppColors.paymentMTS;
        break;
    }
  }

  BankEnum bankName;
  PaymentSystem paymentSystem;
  int lastCardNumber;
  late Widget paymentSystemWidget;
  late Widget bankNameWidget;
  late Color backgroundColor;
}

class SecondBookingStepController extends StatexController {
  SecondBookingStepController({BookingService? bookingService})
      : _bookingService = bookingService ?? Get.find();

  final BookingService _bookingService;

  GetRxDecorator<DateTime> get startDate => _bookingService.startDate;

  GetRxDecorator<DateTime> get endDate => _bookingService.endDate;

  final cardMap = {
    CardInfo(
        bankName: BankEnum.sber,
        lastCardNumber: 9078,
        paymentSystem: PaymentSystem.mir): false,
    CardInfo(
        bankName: BankEnum.tinkoff,
        lastCardNumber: 8234,
        paymentSystem: PaymentSystem.masterCard): false,
    CardInfo(
        bankName: BankEnum.mts,
        lastCardNumber: 4411,
        paymentSystem: PaymentSystem.visa): false
  }.obsDeco();

  final amenityList = <AmenityBook>[].obsDeco();

  GetRxDecorator<BookingArguments> get arguments => _bookingService.arguments;

  final isShowFullListAmenities = false.obsDeco();

  final isCard = true.obsDeco();

  final isCash = false.obsDeco();

  @override
  void onInit() {
    super.onInit();
    arguments().details.amenities.map((e) => e.options.where((element) {
          if (element.price != 0) {
            amenityList.value.add(AmenityBook(
                title: element.title,
                price: element.price,
                value: element.value,
                iconPath: getIconFromAmenityName(element.title)));
          }
          return element.price != 0;
        }));
    //TODO(syyunek): закидываю тестовые удобства, так как на бэке все удобства бесплатные
    if (amenityList.value.isEmpty) {
      amenityList.value.addAll([
        AmenityBook(
            title: 'Посудомоечная машина',
            price: 112,
            value: false,
            iconPath: AppIcons.washingMachine),
        AmenityBook(
            title: 'Кондиционер',
            price: 112,
            value: false,
            iconPath: AppIcons.conditioner),
        AmenityBook(
            title: 'Кухонная плита',
            price: 112,
            value: false,
            iconPath: AppIcons.kitchenStove),
        AmenityBook(
            title: 'Кухонная плита',
            price: 112,
            value: false,
            iconPath: AppIcons.kitchenStove),
        AmenityBook(
            title: 'Кухонная плита',
            price: 112,
            value: false,
            iconPath: AppIcons.kitchenStove),
        AmenityBook(
            title: 'Кухонная плита',
            price: 112,
            value: false,
            iconPath: AppIcons.kitchenStove),
      ]);
    }
    amenityList.refresh();
  }

  String getIconFromAmenityName(String name) {
    switch (name) {
      case 'Wi-Fi':
        return AppIcons.wiFi;
      case 'Кондиционер':
        return AppIcons.conditioner;
      case 'Отопление':
        return AppIcons.heating;
      case 'Кухонная плита':
        return AppIcons.kitchenStove;
      case 'Микроволновая печь':
        return AppIcons.microwaveOven;
      case 'Фен':
        return AppIcons.fan;
      case 'Телевизор':
        return AppIcons.tv;
      case 'Стиральная машина':
      case 'Посудомоечная машина':
        return AppIcons.washingMachine;
      case 'Утюг':
        return AppIcons.iron;
      case 'Кроватка для ребенка':
        return AppIcons.babyBed;
      case 'Детские игрушки':
        return AppIcons.toys;
      default:
        return AppIcons.noPhoto4;
    }
  }

  void setIsActive(CardInfo key) {
    for (var element in cardMap.value.keys) {
      cardMap.value[element] = false;
    }
    cardMap.value[key] = true;
    cardMap.refresh();
  }

  void onCardTap() {
    HapticFeedback.mediumImpact();
    if (!isCard.value) {
      isCard.toggle();
      isCash.toggle();
    }
  }

  void onCashTap() {
    HapticFeedback.mediumImpact();
    if (!isCash.value) {
      isCash.toggle();
      isCard.toggle();
    }
  }

  void tapOnAmenity(int i) {
    amenityList.value.elementAt(i).value =
        !amenityList.value.elementAt(i).value;
    amenityList.refresh();
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

  void toThirdStep() => Get.toNamed(AppRoutes.thirdStepBooking);

  double getFinallyPrice() => _bookingService.finallyPrice();
}
