import 'package:easy_localization/easy_localization.dart';
import 'package:get/get.dart';
import 'package:teremok/core/utils/stream_subscriber.dart';
import 'package:teremok/data/dto/booking/booking_create_body.dart';
import 'package:teremok/domain/booking/booking_dates.dart';
import 'package:teremok/domain/core/extended_errors.dart';
import 'package:teremok/logic/booking/booking_bloc.dart';
import 'package:teremok/ui/router/routing.dart';
import 'package:teremok/ui/screens/booking/src/third_step/third_booking_step_controller.dart';
import 'package:teremok/ui/shared/all_shared.dart';
import 'package:vfx_flutter_common/get_rx_decorator.dart';

import '../../../../domain/detailed_housing/detailed_housing.dart';
import 'booking_arguments.dart';

class BookingService extends GetxService with StreamSubscriberMixin {
  BookingService({BookingBloc? bloc})
      : _bloc = bloc ?? BookingBloc.makeInstance();

  final BookingBloc _bloc;

  final dateFormat = 'dd.MM.yyyy';

  final shortDateFormat = 'dd MMMM';

  final bedMap = <BookingBed, bool>{}.obsDeco();

  final adultCount = 0.obsDeco();

  final childCount = 0.obsDeco();

  final isLoading = false.obsDeco();

  final bookingDates =
      const BookingDates(reserve: [], userReserve: [], minDays: 0).obsDeco();

  final arguments = BookingArguments(
          placeId: -1,
          details: DetailedHousing.empty,
          startDate: DateTime.now(),
          endDate: DateTime.now(),
          beds: [],
          adults: 1,
          child: 0)
      .obsDeco();

  @override
  void onReady() {
    super.onReady();
    refreshArguments();
  }

  @override
  void onInit() {
    super.onInit();
    _bloc.stream.listen(_processBooking);
  }

  GetRxDecoratorDouble taxPrice = 1567.0.obsDeco();

  GetRxDecoratorDouble couponDiscount = 0.0.obsDeco();

  GetRxDecoratorInt get durationInDays =>
      endDate.value.difference(startDate.value).inDays.obsDeco();

  var startDate = DateTime.now().obsDeco();

  var endDate = DateTime.now().obsDeco();

  GetRxDecoratorDouble get finallyPrice {
    var sum = 0.0.obsDeco();
    bedMap.value.forEach((key, value) {
      if (value) {
        sum = sum + getPrice(key.price);
      }
    });
    sum = sum + taxPrice.value;
    sum = sum - couponDiscount.value;
    return sum;
  }

  String getStartDate() {
    return DateFormat(dateFormat).format(startDate.value);
  }

  String getEndDate() {
    return DateFormat(dateFormat).format(endDate.value);
  }

  String getShortStartDate() {
    return DateFormat('dd').format(startDate.value);
  }

  String getShortEndDate() {
    return DateFormat(shortDateFormat).format(endDate.value);
  }

  double getPrice(double price) {
    if (durationInDays.value < 1) {
      return (price * 1);
    }
    return (price * durationInDays.value);
  }

  void _processBooking(BookingState state) {
    state.maybeWhen(
        created: (d) {
          d.maybeWhen(
              loading: () => isLoading.value = true,
              result: (result) {
                isLoading.value = false;
                result.fold((l) {
                  for (var element in l.onlyUserFieldsErrorsValue) {
                    appAlert(
                        value: element.toString(), color: AppColors.primary);
                  }
                }, (r) => Get.toNamed(AppRoutes.successBooking));
              },
              orElse: () {});
        },
        gotDates: (d) {
          d.maybeWhen(
              loading: () => isLoading.value = true,
              result: (result) {
                isLoading.value = false;
                result.fold((l) {
                  for (var element in l.onlyUserFieldsErrorsValue) {
                    appAlert(
                        value: element.toString(), color: AppColors.primary);
                  }
                }, (r) {
                  bookingDates.value = r;
                  bookingDates.refresh();
                });
              },
              orElse: () {});
        },
        orElse: () {});
  }

  void createBooking() {
    final bedsIds = <int>[];
    for (var value in bedMap.value.keys) {
      if (value.bedId != null) {
        bedsIds.add(value.bedId!);
      }
    }
    final body = BookingCreateBody(
        placeId: arguments().placeId,
        guests: adultCount.value,
        children: childCount.value,
        dateTo: endDate.value.stringFromDateTime,
        dateFrom: startDate.value.stringFromDateTime,
        bedIds: bedsIds.isEmpty ? null : bedsIds);
    _bloc.add(BookingEvent.create(body: body));
  }

  void getDates() {
    _bloc.add(BookingEvent.getDates(placeId: arguments().placeId));
  }

  void refreshArguments() {
    final details = arguments().details;
    final images = details.images;
    bedMap.value.clear();
    if (arguments().beds.isNotEmpty) {
      for (var bed in arguments().beds) {
        bedMap.value[bed] = true;
      }
    } else {
      bedMap.value[BookingBed(
        bedImgPath:
            images.isEmpty ? AppIcons.sampleRoom1 : images.first.image.origin,
        title: arguments().details.title.getOrElse(),
        price: arguments().details.price.toDouble(),
      )] = true;
    }
    startDate.value = arguments.value.startDate;
    endDate.value = arguments.value.endDate;
    adultCount.value = arguments.value.adults;
    childCount.value = arguments.value.child;
  }
}
