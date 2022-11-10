import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:teremok/domain/detailed_housing/detailed_housing.dart';
import 'package:teremok/ui/screens/booking/src/second_step/second_booking_step_controller.dart';
import 'package:teremok/ui/shared/all_shared.dart';
import 'package:teremok/ui/shared/widgets/booking_steps.dart';
import 'package:teremok/ui/shared/widgets/bottom_price.dart';
import 'package:vfx_flutter_common/getx_helpers.dart';

class SecondBookingStep extends StatexWidget<SecondBookingStepController> {
  SecondBookingStep({Key? key})
      : super(() => SecondBookingStepController(), key: key);

  @override
  Widget buildWidget(BuildContext context) {
    return AppScaffold(
      appBar: AppBarTitleIcons(
        titleWidget: const BookingSteps(
          secondIsActive: true,
        ),
        onTapShare: () {},
      ),
      navBarEnable: false,
      body: Container(
        color: AppColors.neutral20,
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const _Payment(),
                    12.sbHeightA,
                    const _PaidComfort(),
                    12.sbHeightA,
                    _BookingRules(
                      details: controller.arguments().details,
                    ),
                    16.sbHeightA,
                  ],
                ),
              ),
            ),
            BottomPrice(
              shortStartDate: controller.getShortStartDate(),
              shortEndDate: controller.getShortEndDate(),
              onButtonTap: controller.toThirdStep,
              finallySum: controller.getFinallyPrice(),
            )
          ],
        ),
      ),
    );
  }
}

class _Payment extends GetViewSim<SecondBookingStepController> {
  const _Payment({Key? key}) : super(key: key);

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
            4.sbHeightA,
            const AppText(
              'Способ оплаты',
              type: AppTextType.headerSemiBold,
              color: AppColors.neutral100,
            ),
            24.sbHeightA,
            _PaymentBlock(
              isActive: controller.isCard.value,
              text: 'Оплата картой',
              iconPath: AppIcons.card,
              isCard: true,
              onTap: controller.onCardTap,
            ),
            10.sbHeightA,
            _PaymentBlock(
              isActive: controller.isCash.value,
              text: 'Оплата наличными',
              iconPath: AppIcons.bankNote,
              onTap: controller.onCashTap,
            )
          ],
        ),
      ),
    );
  }
}

class _PaymentBlock extends GetViewSim<SecondBookingStepController> {
  const _PaymentBlock(
      {Key? key,
      this.isCard = false,
      required this.isActive,
      required this.text,
      required this.iconPath,
      required this.onTap})
      : super(key: key);

  final bool isCard;

  final bool isActive;

  final String text;

  final String iconPath;

  final Function() onTap;

  @override
  Widget build(BuildContext context) {
    return Obx(
      () => GestureDetector(
        onTap: onTap,
        child: Container(
          height: isCard ? 173.r : 76.r,
          padding:
              EdgeInsets.only(left: 16.r, right: 16.r, top: 16.r, bottom: 18.r),
          decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: AppColors.neutral40)),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _PaymentMethod(
                  text: text, iconPath: iconPath, isActive: isActive),
              if (isCard) ...[
                26.sbHeightA,
                Expanded(
                  child: ListView.separated(
                      shrinkWrap: true,
                      scrollDirection: Axis.horizontal,
                      itemBuilder: (context, index) {
                        final currentCard =
                            controller.cardMap.value.keys.elementAt(index);
                        return GestureDetector(
                            onTap: () => controller.setIsActive(currentCard),
                            child: Card(
                              card: currentCard,
                              isActive: controller.cardMap.value[currentCard] ??
                                  false,
                            ));
                      },
                      separatorBuilder: (context, index) {
                        return 16.sbWidthA;
                      },
                      itemCount: controller.cardMap.value.length),
                )
              ]
            ],
          ),
        ),
      ),
    );
  }
}

class _PaymentMethod extends StatelessWidget {
  const _PaymentMethod(
      {Key? key,
      required this.text,
      required this.iconPath,
      required this.isActive})
      : super(key: key);

  final String text;

  final String iconPath;

  final bool isActive;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          height: 40.r,
          width: 40.r,
          decoration: BoxDecoration(
              color: AppColors.neutral20,
              borderRadius: BorderRadius.circular(8)),
          child: Center(
            child: Image.asset(
              iconPath,
              width: 24.r,
              height: 24.r,
            ),
          ),
        ),
        16.sbWidthA,
        AppText(text, type: AppTextType.lMedium, color: AppColors.neutral100),
        const Spacer(),
        RoundedCheckBox(isActive: isActive)
      ],
    );
  }
}

class RoundedCheckBox extends StatelessWidget {
  const RoundedCheckBox({Key? key, required this.isActive}) : super(key: key);

  final bool isActive;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 24.r,
      height: 24.r,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(color: AppColors.neutral30, width: 4.r),
      ),
      child: Container(
        width: 16.r,
        height: 16.r,
        decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: isActive ? AppColors.primary : AppColors.neutral30),
      ),
    );
  }
}

class Card extends StatelessWidget {
  const Card({Key? key, required this.card, required this.isActive})
      : super(key: key);

  final CardInfo card;

  final bool isActive;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
              color: isActive ? AppColors.primary : AppColors.neutral40)),
      padding: const EdgeInsets.all(2),
      child: Container(
        decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(8),
            color: card.backgroundColor),
        padding: EdgeInsets.only(left: 8.r, right: 7.r, top: 7.r, bottom: 5.r),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            card.bankNameWidget,
            const Spacer(),
            Row(
              children: [
                AppText(
                  '** ${card.lastCardNumber.toString()}',
                  type: AppTextType.interSemiBold,
                  color: AppColors.white,
                ),
                19.sbWidthA,
                card.paymentSystemWidget,
              ],
            )
          ],
        ),
      ),
    );
  }
}

class _PaidComfort extends GetViewSim<SecondBookingStepController> {
  const _PaidComfort({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Obx(
      () => Container(
        decoration: BoxDecoration(
            color: AppColors.white, borderRadius: BorderRadius.circular(12)),
        padding: EdgeInsets.symmetric(horizontal: 16.r, vertical: 28.r),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const AppText(
              'Платные удобства',
              type: AppTextType.headerSemiBold,
              color: AppColors.neutral100,
            ),
            24.sbHeightA,
            if (controller.amenityList.value.isEmpty)
              const SizedBox.shrink()
            else if (controller.amenityList.value.length <= 3 ||
                controller.isShowFullListAmenities.value)
              ListView.separated(
                physics: const NeverScrollableScrollPhysics(),
                shrinkWrap: true,
                itemBuilder: (_, i) {
                  final currentAmenity =
                      controller.amenityList.value.elementAt(i);
                  return GestureDetector(
                      onTap: () => controller.tapOnAmenity(i),
                      child: ComfortCheckbox(
                          isActive: currentAmenity.value,
                          text: currentAmenity.title,
                          iconPath: currentAmenity.iconPath,
                          price: currentAmenity.price));
                },
                separatorBuilder: (_, i) {
                  return 16.sbHeightA;
                },
                itemCount: controller.amenityList.value.length,
              )
            else ...[
              ListView.separated(
                  physics: const NeverScrollableScrollPhysics(),
                  shrinkWrap: true,
                  itemBuilder: (_, i) {
                    final currentAmenity =
                        controller.amenityList.value.elementAt(i);
                    return GestureDetector(
                        onTap: () => controller.tapOnAmenity(i),
                        child: ComfortCheckbox(
                            isActive: currentAmenity.value,
                            text: currentAmenity.title,
                            iconPath: currentAmenity.iconPath,
                            price: currentAmenity.price));
                  },
                  separatorBuilder: (_, __) => 16.sbHeightA,
                  itemCount: 3),
              24.sbHeight,
              AppTextButton(
                appTextButtonType: AppTextButtonType.outlined,
                //TODO: localization
                text: 'Показать все: ${controller.amenityList.value.length}',
                height: 48.r,
                onPressed: () => c.isShowFullListAmenities.value = true,
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class ComfortCheckbox extends StatelessWidget {
  const ComfortCheckbox(
      {Key? key,
      required this.isActive,
      required this.text,
      required this.iconPath,
      required this.price})
      : super(key: key);

  final bool isActive;
  final String text;
  final String iconPath;
  final int price;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(12.r),
      decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          color: AppColors.neutral20,
          border: Border.all(
              color: isActive ? AppColors.primary : AppColors.neutral20)),
      child: Row(
        children: [
          Row(
            children: [
              Container(
                padding: EdgeInsets.all(4.r),
                decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(8),
                    color: AppColors.white),
                child: Image.asset(
                  iconPath,
                  width: 20.r,
                  height: 20.r,
                  color: AppColors.neutral70,
                ),
              ),
              12.sbWidthA,
              AppText(
                text,
                type: AppTextType.lRegular,
                color: AppColors.neutral100,
              ),
            ],
          ),
          const Spacer(),
          Row(
            children: [
              AppText(
                '$price Р',
                type: AppTextType.lSemiBold,
                color: AppColors.neutral100,
              ),
              12.sbWidthA,
              Container(
                  decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(4),
                      border: Border.all(
                          color: isActive
                              ? AppColors.primary
                              : AppColors.neutral60),
                      color: isActive ? AppColors.primary : AppColors.white),
                  child: isActive
                      ? Image.asset(
                          AppIcons.checkMark,
                          width: 20.r,
                          height: 20.r,
                          color: AppColors.white,
                        )
                      : SizedBox(
                          width: 20.r,
                          height: 20.r,
                        ))
            ],
          )
        ],
      ),
    );
  }
}

class _BookingRules extends StatelessWidget {
  const _BookingRules({Key? key, required this.details}) : super(key: key);

  final DetailedHousing details;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
          color: AppColors.white, borderRadius: BorderRadius.circular(12)),
      padding: EdgeInsets.symmetric(horizontal: 16.r, vertical: 28.r),
      child: Column(
        children: [
          //TODO: localization
          const AppText(
            'Правила бронирования',
            type: AppTextType.headerSemiBold,
            color: AppColors.neutral100,
          ),
          8.sbHeightA,
          //TODO: localization
          const AppText(
            'Эти правила указал хозяин жилья. Пожалуйста, ознакомьтесь с ними перед бронированием',
            type: AppTextType.lRegular,
            color: AppColors.neutral80,
          ),
          24.sbHeightA,
          //TODO: localization
          _RuleCard(
              iconPath: AppIcons.xCircle,
              text: 'Срок действия бесплатной отмены\nбронирования:',
              boldText: '${details.settings.freeCancellationDays} дня'),
          16.sbHeightA,
          _RuleCard(
            iconPath: AppIcons.sale,
            text: 'Неустойка за отмену после срока\nбесплатной отмены:',
            boldText:
                '${details.settings.percentageForfeit}% от суммы бронирования',
          )
        ],
      ),
    );
  }
}

class _RuleCard extends StatelessWidget {
  const _RuleCard(
      {Key? key,
      required this.iconPath,
      required this.text,
      required this.boldText})
      : super(key: key);

  final String iconPath;
  final String text;
  final String boldText;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        color: AppColors.neutral20,
      ),
      padding: EdgeInsets.symmetric(horizontal: 12.r, vertical: 8.r),
      child: Row(
        children: [
          Container(
            decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(8.r),
                color: AppColors.white),
            child: Image.asset(
              iconPath,
              width: 20.r,
              height: 20.r,
              color: AppColors.neutral70,
            ),
          ),
          12.sbWidthA,
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              AppText(
                text,
                type: AppTextType.lRegular,
                color: AppColors.neutral90,
                softWrap: true,
              ),
              AppText(
                boldText,
                type: AppTextType.lSemiBold,
                color: AppColors.neutral100,
                softWrap: true,
              )
            ],
          )
        ],
      ),
    );
  }
}
