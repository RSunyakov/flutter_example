import 'package:flutter/material.dart';
import 'package:teremok/ui/screens/booking/src/success/success_screen_controller.dart';
import 'package:teremok/ui/shared/all_shared.dart';
import 'package:teremok/ui/shared/widgets/booking_steps.dart';
import 'package:vfx_flutter_common/getx_helpers.dart';

class SuccessScreen extends StatexWidget<SuccessScreenController> {
  SuccessScreen({Key? key}) : super(() => SuccessScreenController(), key: key);

  @override
  Widget buildWidget(BuildContext context) {
    return AppScaffold(
        navBarEnable: false,
        appBar: const AppBarTitleIcons(
          titleWidget: BookingSteps(
            isDone: true,
          ),
        ),
        body: Padding(
          padding: EdgeInsets.symmetric(vertical: 40.r),
          child: Center(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(24),
                      color: AppColors.neutral20),
                  child: Image.asset(
                    AppIcons.checkCircleBroken,
                    width: 48.r,
                    height: 48.r,
                    color: AppColors.primary,
                  ),
                ),
                28.sbHeightA,
                const AppText(
                  'Бронирование успешно\nзапрошено!',
                  type: AppTextType.headerSemiBold,
                  color: AppColors.neutral100,
                  textAlign: TextAlign.center,
                ),
                16.sbHeightA,
                const Center(
                    child: AppText(
                  'Как только хозяин подтвердит\nбронирование мы сообщим вам',
                  type: AppTextType.lRegular,
                  color: AppColors.neutral80,
                  textAlign: TextAlign.center,
                )),
                32.sbHeightA,
                AppTextButton(
                  width: 218,
                  text: 'Смотреть мои поездки',
                  appTextButtonType: AppTextButtonType.outlined,
                  onPressed: controller.toMainScreen,
                )
              ],
            ),
          ),
        ));
  }
}
