import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:teremok/domain/detailed_housing/detailed_housing.dart';
import 'package:teremok/ui/screens/booking/booking.dart';
import 'package:teremok/ui/shared/all_shared.dart';
import 'package:teremok/ui/shared/stackable_progress_indicator.dart';
import 'package:teremok/ui/shared/widgets/app_bottom_sheet/app_bottom_sheet.dart';
import 'package:teremok/ui/shared/widgets/app_input.dart';
import 'package:teremok/ui/shared/widgets/booking_bottom_sheet.dart';
import 'package:teremok/ui/shared/widgets/booking_conditional.dart';
import 'package:teremok/ui/shared/widgets/booking_steps.dart';
import 'package:teremok/ui/shared/widgets/bottom_price.dart';
import 'package:teremok/ui/shared/widgets/phone_input_widget/src/phone_input_widget.dart';
import 'package:teremok/ui/shared/widgets/phone_input_widget/src/selector_config.dart';
import 'package:vfx_flutter_common/getx_helpers.dart';
import 'package:intl_phone_number_input/intl_phone_number_input.dart' as intl;

class BookingMainScreen extends StatexWidget<BookingMainController> {
  BookingMainScreen({Key? key})
      : super(() => BookingMainController(), key: key);

  @override
  Widget buildWidget(BuildContext context) {
    return AppScaffold(
      navBarEnable: false,
      appBar: AppBarTitleIcons(
        titleWidget: const BookingSteps(
          firstIsActive: true,
        ),
        onTapShare: () {},
      ),
      //     AppBar(
      //   title: const BookingSteps(),
      //   automaticallyImplyLeading: false,
      //   elevation: 1,
      //   titleSpacing: 0,
      //   backgroundColor: Colors.white,
      //   bottomOpacity: 0,
      // ),
      body: Obx(
        () {
          final arg = controller.arguments();
          if (arg.placeId == -1) {
            return const Center(
              child: AppText(
                // TODO: localization
                'что-то пошло не так, \nне пришел аргумент',
                type: AppTextType.headerSemiBold,
                textAlign: TextAlign.center,
              ),
            );
          }
          return Stack(
            children: [
              Container(
                color: AppColors.neutral20,
                child: Column(
                  children: [
                    Expanded(
                      child: SingleChildScrollView(
                        child: controller.isAuthorized()
                            ? Column(
                                children: [
                                  ReservationCard(
                                    details: arg.details,
                                  ),
                                  12.sbHeightA,
                                  const TripCard(),
                                  16.sbHeightA,
                                ],
                              )
                            : const NotAuthorized(),
                      ),
                    ),
                    BottomPrice(
                      shortStartDate: controller.getShortStartDate(),
                      shortEndDate: controller.getShortEndDate(),
                      onButtonTap: controller.toNextStep,
                      finallySum: controller.getFinallyPrice(),
                    )
                  ],
                ),
              ),
              if (controller.isLoading.value ||
                  controller.isDateLoading.value) ...[
                const StackableProgressIndicator()
              ]
            ],
          );
        },
      ),
    );
  }
}

class ReservationCard extends StatelessWidget {
  const ReservationCard({Key? key, required this.details}) : super(key: key);

  final DetailedHousing details;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 16.r, vertical: 24.r),
      decoration: const BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(12),
          bottomRight: Radius.circular(12),
        ),
      ),
      child: Column(
        children: [
          _ReservationDescription(
            details: details,
          ),
          24.sbHeightA,
          const Divider(
            height: 1,
            thickness: 1,
            color: AppColors.neutral30,
          ),
          24.sbHeightA,
          BookingConditional(
            bgColor: AppColors.neutral20,
            // TODO: localization
            text: 'Это жилье бесплатно для беженцев',
            iconPath: AppIcons.refugees,
            iconSize: Size(20.r, 20.r),
            toolTip: true,
            // TODO: localization
            toolTipText: 'Тестовый tooltip',
          ),
          16.sbHeightA,
          if (details.settings.autoBookingConfirmation) ...[
            const BookingConditional(
              bgColor: AppColors.bookingBackground2,
              // TODO: localization
              text: 'Бронирование будет автоматически принято',
              iconText: '!',
              iconColor: AppColors.primaryHover,
            ),
            16.sbHeightA,
          ],
          if (details.settings.guestsWithVerifiedDocumentsOnly) ...[
            const BookingConditional(
              bgColor: AppColors.infoFocus,
              // TODO: localization
              text: 'Хозяин принимает только подтвержденных гостей',
              iconText: '!',
              iconColor: AppColors.infoPrimary,
            ),
          ]
        ],
      ),
    );
  }
}

class _ReservationDescription extends StatelessWidget {
  const _ReservationDescription({Key? key, required this.details})
      : super(key: key);

  final DetailedHousing details;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(16),
              child: details.images.isNotEmpty
                  ? ImgNetwork(
                      pathImg: details.images.first.image.origin,
                      width: 80.r,
                      height: 80.r,
                    )
                  : Image.asset(
                      AppIcons.reservationPreview,
                      width: 80.r,
                      height: 80.r,
                    ),
            ),
            16.sbWidthA,
            Expanded(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  AppText(
                    details.title.getOrElse(),
                    softWrap: true,
                    type: AppTextType.headerSemiBold,
                    color: AppColors.neutral100,
                  ),
                  8.sbHeightA,
                  /*const AppText(
                    'В комнате: 4 из 8 человека',
                    type: AppTextType.mRegular,
                    color: AppColors.neutral90,
                  ),
                  const AppText(
                    '8 м2',
                    type: AppTextType.mRegular,
                    color: AppColors.neutral90,
                  )*/
                ],
              ),
            )
          ],
        ),
        24.sbHeightA,
        AppText(
          details.address.getOrElse(),
          type: AppTextType.mRegular,
          color: AppColors.neutral90,
        ),
        if (details.subway?.name.getOrElse().isNotEmpty ?? false) ...[
          8.sbHeightA,
          Row(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    decoration: const BoxDecoration(
                        shape: BoxShape.circle, color: AppColors.metroColor),
                    width: 8.r,
                    height: 8.r,
                  ),
                  8.sbWidthA,
                  AppText(
                    details.subway?.name.getOrElse() ?? '',
                    type: AppTextType.mRegular,
                    color: AppColors.neutral90,
                  )
                ],
              ),
              16.sbWidthA,
              SizedBox(
                  height: 16.r,
                  child: VerticalDivider(
                    width: 1.sp,
                    thickness: 1.sp,
                    color: AppColors.neutral40,
                  )),
              16.sbWidthA,
              Row(
                children: [
                  Image.asset(
                    AppIcons.pedestrian,
                    width: 14.r,
                    height: 14.r,
                  ),
                  4.sbWidthA,
                  const AppText(
                    '15 мин',
                    type: AppTextType.mRegular,
                    color: AppColors.neutral90,
                  )
                ],
              )
            ],
          ),
        ]
      ],
    );
  }
}

class TripCard extends GetViewSim<BookingMainController> {
  const TripCard({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Obx(
      () {
        final arg = controller.arguments();
        return Container(
          padding: EdgeInsets.symmetric(horizontal: 16.r, vertical: 24.r),
          decoration: BoxDecoration(
            color: AppColors.white,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              //TODO: localization
              const AppText(
                'Ваша поездка',
                type: AppTextType.headerSemiBold,
                color: AppColors.neutral100,
              ),
              20.sbHeightA,
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
                decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(16),
                    color: AppColors.neutral20),
                child: Column(
                  children: [
                    Row(
                      children: [
                        Container(
                          width: 28.r,
                          height: 28.r,
                          decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(5),
                              color: AppColors.white),
                          child: Center(
                              child: Image.asset(
                            AppIcons.calendar,
                            width: 16.r,
                            height: 16.r,
                            color: AppColors.neutral80,
                          )),
                        ),
                        16.sbWidthA,
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            //TODO: localization
                            const AppText(
                              'Даты:',
                              type: AppTextType.mRegular,
                              color: AppColors.neutral80,
                            ),
                            GestureDetector(
                              onTap: () => controller.openBottomSheet(
                                  context, const _Calendar()),
                              child: Text(
                                  '${controller.getStartDate()} - ${controller.getEndDate()}',
                                  style: AppTextStyles.lMedium.copyWith(
                                      decoration: TextDecoration.underline,
                                      decorationStyle:
                                          TextDecorationStyle.dashed,
                                      color: AppColors.neutral100)),
                            ),
                          ],
                        )
                      ],
                    ),
                    24.sbHeightA,
                    Row(
                      children: [
                        Container(
                          width: 28.r,
                          height: 28.r,
                          decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(5),
                              color: AppColors.white),
                          child: Center(
                              child: Image.asset(
                            AppIcons.users,
                            width: 16.r,
                            height: 16.r,
                            color: AppColors.neutral80,
                          )),
                        ),
                        16.sbWidthA,
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const AppText(
                              'Гости: ',
                              type: AppTextType.mRegular,
                              color: AppColors.neutral80,
                            ),
                            GestureDetector(
                              onTap: () {
                                OpenBottomSheet.open(
                                  context,
                                  BookingBottomSheet(
                                    maxGuest:
                                        controller.arguments().details.guests +
                                            arg.details.children,
                                    maxChild: arg.details.children,
                                    maxAdult: arg.details.guests,
                                    extraGuestCost: arg
                                        .details.settings.additionalGuestAmount,
                                    adultCount: controller.adultCount,
                                    childCount: controller.childCount,
                                    submitFunc: controller.savePeopleCount,
                                  ),
                                  height: 420.r,
                                  enableDrag: true,
                                  isScrollControlled: true,
                                  isAdaptiveKeyboard: true,
                                );
                              },
                              child: Text(
                                '${controller.adultCount.value + controller.childCount.value} гостя',
                                style: AppTextStyles.lMedium.copyWith(
                                    decoration: TextDecoration.underline,
                                    decorationStyle: TextDecorationStyle.dashed,
                                    color: AppColors.neutral100),
                              ),
                            )
                          ],
                        )
                      ],
                    )
                  ],
                ),
              )
            ],
          ),
        );
      },
    );
  }
}

class NotAuthorized extends StatelessWidget {
  const NotAuthorized({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 16.r, vertical: 24.r),
      decoration: const BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.only(
              bottomLeft: Radius.circular(12),
              bottomRight: Radius.circular(12))),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          //TODO: localization
          const AppText(
            'Авторизуйтесь',
            type: AppTextType.headerSemiBold,
            color: AppColors.neutral100,
          ),
          8.sbHeightA,
          //TODO: localization
          const AppText(
            'Для бронирования этого жилья',
            type: AppTextType.lRegular,
            color: AppColors.neutral80,
          ),
          24.sbHeightA,
          const _PhoneInput(),
          26.sbHeightA,
          const _PasswordInput(),
        ],
      ),
    );
  }
}

class _PhoneInput extends GetViewSim<BookingMainController> {
  const _PhoneInput({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final inputDecoration = InputDecoration(
        contentPadding: EdgeInsets.symmetric(horizontal: 16.sp),
        hintStyle: AppTextStyles.lRegular.copyWith(color: AppColors.neutral70),
        filled: true,
        fillColor: AppColors.neutral20,
        enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12.sp),
            borderSide: const BorderSide(color: Colors.transparent)),
        focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12.sp),
            borderSide: const BorderSide(color: AppColors.primary)));

    final initialNumber = intl.PhoneNumber(isoCode: 'RU');

    return InternationalPhoneNumberInput(
      initialValue: initialNumber,
      maxLength: 10,
      textStyle: AppTextStyles.lRegular.copyWith(color: AppColors.neutral100),
      selectorConfig: SelectorConfig(
          selectorType: intl.PhoneInputSelectorType.BOTTOM_SHEET,
          useEmoji: false,
          trailingSpace: false,
          padding: EdgeInsets.symmetric(horizontal: 16.sp),
          height: 48,
          inputDecoration: BoxDecoration(
            color: AppColors.neutral20,
            borderRadius: BorderRadius.circular(12.sp),
          )),
      spaceBetweenSelectorAndTextField: 5.sp,
      hintText: '',
      //TODO: localization
      searchBoxDecoration: inputDecoration.copyWith(
          hintText: 'Поиск по стране или телефонному коду'),
      inputDecoration: inputDecoration,
      onInputChanged: controller.phoneInputChanged,
      formatInput: false,
    );
  }
}

class _PasswordInput extends GetViewSim<BookingMainController> {
  const _PasswordInput({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Obx(() => Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // TODO: localization
            const AppText('Пароль', type: AppTextType.mRegular),
            8.sbHeightA,
            AppInput(
              //TODO: localization,
              error: controller.passwordError.value,
              hintText: 'Введите пароль',
              controller: controller.passwordCtrl,
              obscureText: controller.hidePassword.value,
              onChanged: controller.passwordInputChanged,
              obscuringCharacter: '*',
              height: 48.r,
              suffixIcon: InkWell(
                onTap: () {
                  HapticFeedback.mediumImpact();
                  controller.hidePassword.toggle();
                },
                child: Padding(
                    padding: EdgeInsetsDirectional.only(end: 16.r),
                    child: Align(
                        widthFactor: 1,
                        heightFactor: 1,
                        alignment: Alignment.centerRight,
                        child: Image.asset(
                          AppIcons.eye,
                          width: 20.r,
                          height: 20.r,
                        ))),
              ),
            ),
            if (controller.passwordError.value) ...[
              8.sbHeightA,
              //TODO: localization
              const AppText(
                'Неправильно',
                type: AppTextType.mRegular,
                color: AppColors.dangerPrimary,
              )
            ],
            8.sbHeightA,
            GestureDetector(
                onTap: controller.toRestorePasswordScreen,
                //TODO: localization
                child: const AppText(
                  'Не помню пароль',
                  type: AppTextType.mRegular,
                  color: AppColors.primary,
                )),
            24.sbHeightA,
            //controller.passwordError.value ? 24.sbHeightA : 52.sbHeightA,
            //TODO: localization
            AppTextButton(
                text: 'Войти',
                onPressed:
                    controller.isButtonEnabled ? controller.pressEnter : null),
            10.sbHeightA,
            //TODO: localization
            Center(
              child: GestureDetector(
                onTap: controller.toRestorePasswordScreen,
                child: const AppText(
                  'Создать аккаунт',
                  type: AppTextType.lMedium,
                  color: AppColors.primary,
                ),
              ),
            )
          ],
        ));
  }
}

class _Calendar extends GetViewSim<BookingMainController> {
  const _Calendar({Key? key}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    var days = controller.getBookedDates();
    return Obx(
      () => AppCalendar(
        initialDateSelected: controller.startDate.value,
        endDateSelected: controller.endDate.value,
        onRangeSelected: controller.onRangeSelected,
        onTapCancel: controller.clearCalendar,
        bookedDate: days,
      ),
    );
  }
}
