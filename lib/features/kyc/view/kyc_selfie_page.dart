import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/widgets/gradient_button.dart';
import '../../../routes.dart';

class KycSelfiePage extends StatelessWidget {
  const KycSelfiePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, size: 20),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: const Text('MONEYMINING'),
        centerTitle: true,
        actions: [
          TextButton(
            onPressed: () {},
            child: Text(
              'IDENTITY VERIFICATION',
              style: AppTextStyles.bodyMedium.copyWith(
                color: AppColors.luxuryGold,
                fontSize: 10,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            const SizedBox(height: 10),
            // Step Indicators
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(8, (index) {
                return Container(
                  margin: const EdgeInsets.symmetric(horizontal: 4),
                  width: index == 7 ? 24 : 12,
                  height: 4,
                  decoration: BoxDecoration(
                    color: index == 7 ? AppColors.luxuryGold : Colors.white24,
                    borderRadius: BorderRadius.circular(2),
                  ),
                );
              }),
            ),
            const SizedBox(height: 30),
            
            // Header
            const Text(
              'Final Step: Selfie',
              style: AppTextStyles.headlineMedium,
            ),
            const SizedBox(height: 12),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 40),
              child: Text(
                'Position your face within the frame. Ensure you are in a well-lit environment.',
                textAlign: TextAlign.center,
                style: AppTextStyles.bodyMedium.copyWith(
                  color: Colors.white70,
                  height: 1.4,
                ),
              ),
            ),
            
            Expanded(
              child: Stack(
                alignment: Alignment.center,
                children: [
                   // Camera Circle Border with Glow
                   Container(
                     width: 300,
                     height: 300,
                     decoration: BoxDecoration(
                       shape: BoxShape.circle,
                       border: Border.all(color: AppColors.luxuryGold, width: 3),
                       boxShadow: [
                         BoxShadow(
                           color: AppColors.luxuryGold.withOpacity(0.3),
                           blurRadius: 30,
                           spreadRadius: 2,
                         )
                       ]
                     ),
                   ),
                   
                   // Corner Markers inside the circle (Simulated using a Container with custom painting or just Stacked images/widgets)
                   // Simplified using Borders on container for now to mimic the framing
                   SizedBox(
                     width: 180,
                     height: 180,
                     child: Stack(
                       children: [
                         // Top Left
                         Positioned(
                           left: 0, top: 0,
                           child: Container(
                             width: 40, height: 40,
                             decoration: const BoxDecoration(
                               border: Border(
                                 top: BorderSide(color: AppColors.luxuryGold, width: 2),
                                 left: BorderSide(color: AppColors.luxuryGold, width: 2),
                               ),
                               borderRadius: BorderRadius.only(topLeft: Radius.circular(12)),
                             ),
                           ),
                         ),
                         // Top Right
                         Positioned(
                           right: 0, top: 0,
                           child: Container(
                             width: 40, height: 40,
                             decoration: const BoxDecoration(
                               border: Border(
                                 top: BorderSide(color: AppColors.luxuryGold, width: 2),
                                 right: BorderSide(color: AppColors.luxuryGold, width: 2),
                               ),
                               borderRadius: BorderRadius.only(topRight: Radius.circular(12)),
                             ),
                           ),
                         ),
                         // Bottom Left
                         Positioned(
                           left: 0, bottom: 0,
                           child: Container(
                             width: 40, height: 40,
                             decoration: const BoxDecoration(
                               border: Border(
                                 bottom: BorderSide(color: AppColors.luxuryGold, width: 2),
                                 left: BorderSide(color: AppColors.luxuryGold, width: 2),
                               ),
                               borderRadius: BorderRadius.only(bottomLeft: Radius.circular(12)),
                             ),
                           ),
                         ),
                         // Bottom Right
                         Positioned(
                           right: 0, bottom: 0,
                           child: Container(
                             width: 40, height: 40,
                             decoration: const BoxDecoration(
                               border: Border(
                                 bottom: BorderSide(color: AppColors.luxuryGold, width: 2),
                                 right: BorderSide(color: AppColors.luxuryGold, width: 2),
                               ),
                               borderRadius: BorderRadius.only(bottomRight: Radius.circular(12)),
                             ),
                           ),
                         ),
                         
                         // Shadow Icon Placeholder
                         const Center(
                           child: Icon(Icons.person, size: 80, color: Colors.white12),
                         ),
                       ],
                     ),
                   ),
                   
                   // Small Orbiting Dot (Simplified fixed position)
                   Positioned(
                     top: 40,
                     right: 50,
                     child: Container(
                       width: 12, height: 12,
                       decoration: const BoxDecoration(
                         color: AppColors.goldHighlight,
                         shape: BoxShape.circle,
                          boxShadow: [
                           BoxShadow(color: AppColors.goldHighlight, blurRadius: 8),
                         ]
                       ),
                     ),
                   ),
                ],
              ),
            ),
            
            // Lighting Status
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: Colors.white10,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: Colors.white12),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.wb_sunny, size: 16, color: AppColors.successGreen),
                  const SizedBox(width: 8),
                  Text(
                    'Lighting: Perfect',
                    style: AppTextStyles.bodyMedium.copyWith(color: Colors.white),
                  ),
                ],
              ),
            ),
            
            const SizedBox(height: 40),
            
            // Camera Controls
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Gallery
                _buildCircleButton(icon: Icons.image),
                const SizedBox(width: 32),
                
                // Capture
                Container(
                  width: 80, height: 80,
                  decoration: const BoxDecoration(
                     shape: BoxShape.circle,
                     color: AppColors.luxuryGold,
                      boxShadow: [
                         BoxShadow(
                           color: AppColors.luxuryGold,
                           blurRadius: 20,
                           spreadRadius: -5,
                         )
                       ]
                  ),
                  child: IconButton(
                    icon: const Icon(Icons.camera_alt, color: AppColors.matteBlack, size: 32),
                    onPressed: () {},
                  ),
                ),
                
                const SizedBox(width: 32),
                
                // Flip Camera
                _buildCircleButton(icon: Icons.flip_camera_ios),
              ],
            ),
            
            const SizedBox(height: 40),
            
            // Footer
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.lock, size: 12, color: AppColors.luxuryGold),
                const SizedBox(width: 8),
                Text(
                  'SECURE END-TO-END ENCRYPTION',
                  style: AppTextStyles.bodyMedium.copyWith(
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                    color: Colors.white38,
                  ),
                ),
              ],
            ),
            
            const SizedBox(height: 20),
            
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24.0),
              child: GradientButton(
                text: 'CAPTURE PHOTO', 
                onPressed: () {

                  Navigator.pushNamed(context, Routes.dashboard);

                  // showDialog(
                  //   context: context, 
                  //   builder: (c) => AlertDialog(
                  //     backgroundColor: AppColors.darkGray,
                  //     title: const Text('Demo Complete', style: AppTextStyles.headlineMedium),
                  //     content: const Text('All verification screens have been implemented.', style: AppTextStyles.bodyMedium),
                  //     actions: [
                  //       TextButton(
                  //         onPressed: () => Navigator.pop(c),
                  //         child: const Text('OK', style: TextStyle(color: AppColors.luxuryGold)),
                  //       )
                  //     ],
                  //   )
                  // );
                }
              ),
            ),
             const SizedBox(height: 16),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 40),
               child: Text(
                'Your biometric data is only used for regulatory compliance and identity verification.',
                textAlign: TextAlign.center,
                style: AppTextStyles.bodyMedium.copyWith(
                  fontSize: 10,
                  color: Colors.white24,
                ),
              ),
            ),
             const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
  
  Widget _buildCircleButton({required IconData icon}) {
    return Container(
      width: 50, height: 50,
      decoration: BoxDecoration(
        color: Colors.white10,
        shape: BoxShape.circle,
        border: Border.all(color: Colors.white10),
      ),
      child: Icon(icon, color: Colors.white70, size: 24),
    );
  }
}
