import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:just_the_tooltip/just_the_tooltip.dart';
import 'package:teremok/ui/screens/booking/src/third_step/third_booking_step_controller.dart';
import 'package:teremok/ui/shared/all_shared.dart';
import 'package:teremok/ui/shared/funcs.dart';
import 'package:teremok/ui/shared/widgets/booking_steps.dart';
import 'package:teremok/ui/shared/widgets/bottom_price.dart';
import 'package:vfx_flutter_common/getx_helpers.dart';

class ThirdBookingStepScreen extends StatexWidget<ThirdBookingStepController> {
  ThirdBookingStepScreen({Key? key})
      : super(() => ThirdBookingStepController(), key: key);

  @override
  Widget buildWidget(BuildContext context) {
    return Obx(
      () => Stack(
        children: [
          AppScaffold(
            navBarEnable: false,
            appBar: AppBarTitleIcons(
              titleWidget: const BookingSteps(
                thirdIsActive: true,
              ),
              onTapShare: () {},
            ),
            body: Container(
              color: AppColors.neutral20,
              child: Column(
                children: [
                  const Expanded(
                      child: SingleChildScrollView(child: _BookingBlock())),
                  BottomPrice(
                    shortStartDate: controller.getShortStartDate(),
                    shortEndDate: controller.getShortEndDate(),
                    finallySum: controller.getFinallyPrice(),
                    //TODO: localization
                    buttonTitle: 'Забронировать',
                    onButtonTap: controller.createBooking,
                  )
                ],
              ),
            ),
          ),
          controller.isLoading.value ? Consts.preLoader : Container()
        ],
      ),
    );
  }
}

class _BookingBlock extends GetViewSim<ThirdBookingStepController> {
  const _BookingBlock({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Obx(
      () => Container(
        padding: EdgeInsets.symmetric(horizontal: 16.r, vertical: 24.r),
        decoration: const BoxDecoration(
            color: AppColors.white,
            borderRadius: BorderRadius.only(
                bottomLeft: Radius.circular(12),
                bottomRight: Radius.circular(12))),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const AppText(
              'Бронирование',
              type: AppTextType.headerSemiBold,
              color: AppColors.neutral100,
            ),
            20.sbHeightA,
            ListView.separated(
                physics: const NeverScrollableScrollPhysics(),
                shrinkWrap: true,
                itemBuilder: (_, i) {
                  final currentRoom =
                      controller.roomMap.value.keys.elementAt(i);
                  return _RoomContainer(
                      roomImgPath: currentRoom.bedImgPath,
                      roomName: currentRoom.title,
                      networkImage: true,
                      isActive: controller.roomMap.value[currentRoom] ?? false,
                      onTap: () => controller.tapOnRoom(currentRoom));
                },
                separatorBuilder: (_, i) {
                  if (i != controller.roomMap.value.length - 1) {
                    return 12.sbHeightA;
                  } else {
                    return const SizedBox.shrink();
                  }
                },
                itemCount: controller.roomMap.value.length),
            20.sbHeightA,
            ListView.builder(
                physics: const NeverScrollableScrollPhysics(),
                shrinkWrap: true,
                itemBuilder: (_, i) {
                  final currentRoom =
                      controller.roomMap.value.keys.elementAt(i);
                  if (controller.roomMap.value[currentRoom] ?? false) {
                    return Column(
                      children: [
                        _DetailedPrice(
                            roomTitle: currentRoom.title,
                            price: controller
                                .getPrice(currentRoom.price.toDouble()),
                            countOfNight: controller.durationInDays),
                        16.sbHeightA,
                      ],
                    );
                  } else {
                    return Container();
                  }
                },
                itemCount: controller.roomMap.value.length),
            const _DetailedPrice(tax: 'Сбор за услуги', price: 1567),
            16.sbHeightA,
            const _DetailedPrice(price: 0, isCoupon: true),
            20.sbHeightA,
            _CouponInput(
              controller: controller.couponController,
            ),
            20.sbHeightA,
            Container(
              padding: EdgeInsets.symmetric(horizontal: 16.r, vertical: 14.r),
              decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(16),
                  color: AppColors.neutral20),
              child: Row(
                children: [
                  const AppText(
                    'Итого',
                    type: AppTextType.lRegular,
                    color: AppColors.neutral80,
                  ),
                  const Spacer(),
                  AppText(
                    getFormatDouble(controller.getFinallyPrice()),
                    type: AppTextType.lSemiBold,
                    color: AppColors.neutral100,
                  ),
                ],
              ),
            ),
            16.sbHeightA,
            _RefugeeCheckbox(
                isActive: controller.isRefugee.value,
                onTap: (b) => controller.isRefugee.toggle()),
            16.sbHeightA,
          ],
        ),
      ),
    );
  }
}

class _RoomContainer extends StatelessWidget {
  const _RoomContainer(
      {Key? key,
      required this.roomImgPath,
      required this.roomName,
      required this.isActive,
      required this.onTap,
      this.networkImage})
      : super(key: key);

  final String roomImgPath;

  final String roomName;

  final bool? networkImage;

  final bool isActive;

  final Function() onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.all(12.r),
        decoration: BoxDecoration(
          color: AppColors.white,
          border: Border.all(color: AppColors.neutral40),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            SizedBox(
              width: 44.r,
              height: 44.r,
              child: (networkImage ?? false)
                  ? ImgNetwork(
                      pathImg: roomImgPath,
                      width: 44.r,
                      height: 44.r,
                      borderRadius: BorderRadius.circular(8),
                    )
                  : Image.asset(roomImgPath, width: 44.r, height: 44.r),
            ),
            12.sbWidthA,
            Expanded(
              child: AppText(
                roomName,
                type: AppTextType.lRegular,
                color: AppColors.neutral100,
                softWrap: true,
              ),
            ),
            const Spacer(),
            Container(
                width: 20.r,
                height: 20.r,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(4),
                  color: isActive ? AppColors.primary : AppColors.white,
                  border: Border.all(
                      color:
                          isActive ? AppColors.primary : AppColors.neutral40),
                ),
                child: isActive
                    ? Padding(
                        padding: EdgeInsets.all(1.r),
                        child: Image.asset(
                          AppIcons.checkMark,
                          width: 19.r,
                          height: 19.r,
                        ),
                      )
                    : SizedBox(
                        width: 20.r,
                        height: 20.r,
                      ))
          ],
        ),
      ),
    );
  }
}

class _DetailedPrice extends StatelessWidget {
  const _DetailedPrice(
      {Key? key,
      this.roomTitle,
      this.countOfNight,
      required this.price,
      this.isCoupon = false,
      this.tax})
      : super(key: key);

  final String? roomTitle;

  final int? countOfNight;

  final double price;

  final bool isCoupon;

  final String? tax;
  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisAlignment: MainAxisAlignment.start,
      children: [
        Expanded(
          child: AppText(
            (countOfNight != null)
                ? '$roomTitle, $countOfNight ночи'
                : tax != null
                    ? '$tax'
                    : isCoupon
                        ? 'Купон'
                        : '',
            type: AppTextType.lRegular,
            color: AppColors.neutral80,
            softWrap: true,
            maxLines: 4,
            //overflow: TextOverflow.ellipsis,
          ),
        ),
        const Spacer(),
        AppText(
          isCoupon
              ? '- ${getFormatDouble(price)} Р'
              : '${getFormatDouble(price)} Р',
          type: AppTextType.lSemiBold,
          color: isCoupon ? AppColors.primary : AppColors.neutral100,
          softWrap: true,
        )
      ],
    );
  }
}

class _CouponInput extends StatelessWidget {
  const _CouponInput({Key? key, this.controller}) : super(key: key);

  final TextEditingController? controller;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 48.r,
      child: TextFormField(
        controller: controller,
        decoration: InputDecoration(
            filled: true,
            //TODO: localization
            hintText: 'Введите купон',
            enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(color: AppColors.neutral20)),
            fillColor: AppColors.neutral20,
            hintStyle:
                AppTextStyles.lRegular.copyWith(color: AppColors.neutral70),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: AppColors.primary),
            ),
            suffixIcon: Container(
              width: 40.r,
              height: 40.r,
              padding: EdgeInsets.all(8.r),
              margin: EdgeInsets.all(4.r),
              decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(8),
                  color: AppColors.primary),
              child: Image.asset(
                AppIcons.send,
                width: 24.r,
                height: 24.r,
                color: AppColors.white,
              ),
            )),
      ),
    );
  }
}

class _RefugeeCheckbox extends StatelessWidget {
  const _RefugeeCheckbox(
      {Key? key, required this.isActive, required this.onTap})
      : super(key: key);

  final bool isActive;

  final Function(bool b) onTap;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 52.r,
      padding: EdgeInsets.symmetric(horizontal: 16.r, vertical: 13.r),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.neutral40),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              AppCheckbox(
                isActive: isActive,
                onTap: onTap,
              ),
              11.sbWidthA,
              //TODO: localization
              const AppText(
                'Я беженец',
                type: AppTextType.lRegular,
                color: AppColors.neutral100,
              )
            ],
          ),
          const Spacer(),
          JustTheTooltip(
              isModal: true,
              content: const AppText(
                'Тестовый tooltip',
                type: AppTextType.lRegular,
              ),
              child: Image.asset(
                AppIcons.infoCircle,
                width: 20.r,
                height: 20.r,
              ))
        ],
      ),
    );
  }
}
