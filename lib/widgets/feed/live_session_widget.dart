import 'package:flutter/material.dart';
import '../../config/constants.dart';
import '../../models/live_session.dart';
import '../../services/auth_service.dart';
import '../../services/feed_content_service.dart';
import '../../widgets/common/custom_popup.dart';
import '../../screens/auth/mobile_auth_screen.dart';

class LiveSessionWidget extends StatefulWidget {
  final LiveSession session;
  final VoidCallback? onJoin;
  final VoidCallback? onFollow;
  final VoidCallback? onShare;

  const LiveSessionWidget({
    super.key,
    required this.session,
    this.onJoin,
    this.onFollow,
    this.onShare,
  });

  @override
  State<LiveSessionWidget> createState() => _LiveSessionWidgetState();
}

class _LiveSessionWidgetState extends State<LiveSessionWidget> {
  bool _isHandRaised = false;
  bool _isJoining = false;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      height: double.infinity,
      decoration: BoxDecoration(
        color: Colors.black,
        image: widget.session.thumbnailUrl != null
            ? DecorationImage(
                image: NetworkImage(widget.session.thumbnailUrl!),
                fit: BoxFit.cover,
              )
            : null,
      ),
      child: Stack(
        children: [
          // Dark overlay
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Colors.black.withOpacity(0.3),
                  Colors.black.withOpacity(0.7),
                ],
              ),
            ),
          ),
          
          // Live indicator
          if (widget.session.isLive)
            Positioned(
              top: 50,
              left: 16,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: Colors.red,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 8,
                      height: 8,
                      decoration: const BoxDecoration(
                        color: Colors.white,
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 6),
                    const Text(
                      'LIVE',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ),

          // Participant count
          if (widget.session.isLive)
            Positioned(
              top: 50,
              right: 16,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: Colors.black.withOpacity(0.6),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(
                      Icons.people,
                      color: Colors.white,
                      size: 16,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      '${widget.session.currentParticipants}',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
            ),

          // Content
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: Container(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Tutor info
                  Row(
                    children: [
                      CircleAvatar(
                        radius: 20,
                        backgroundImage: widget.session.tutor.introVideoUrl != null
                            ? NetworkImage(widget.session.tutor.introVideoUrl!)
                            : null,
                        child: widget.session.tutor.introVideoUrl == null
                            ? const Icon(Icons.person, color: Colors.white)
                            : null,
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              widget.session.tutor.bio?.split(' ').take(3).join(' ') ?? 'Tutor',
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            Text(
                              widget.session.subject,
                              style: const TextStyle(
                                color: Colors.white70,
                                fontSize: 14,
                              ),
                            ),
                          ],
                        ),
                      ),
                      if (widget.session.tutor.isVerified == true)
                        const Icon(
                          Icons.verified,
                          color: Colors.blue,
                          size: 20,
                        ),
                    ],
                  ),
                  
                  const SizedBox(height: 12),
                  
                  // Session title
                  Text(
                    widget.session.title,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  
                  if (widget.session.description != null) ...[
                    const SizedBox(height: 4),
                    Text(
                      widget.session.description!,
                      style: const TextStyle(
                        color: Colors.white70,
                        fontSize: 14,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                  
                  const SizedBox(height: 12),
                  
                  // Session info
                  Row(
                    children: [
                      if (widget.session.isLive) ...[
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: Colors.red.withOpacity(0.2),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: Colors.red, width: 1),
                          ),
                          child: const Text(
                            'Live Now',
                            style: TextStyle(
                              color: Colors.red,
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                      ] else if (widget.session.isScheduled) ...[
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: Colors.blue.withOpacity(0.2),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: Colors.blue, width: 1),
                          ),
                          child: Text(
                            'Starts ${_formatTime(widget.session.scheduledAt)}',
                            style: const TextStyle(
                              color: Colors.blue,
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                      ],
                      
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          widget.session.typeText,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                      
                      if (widget.session.isPaid) ...[
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: Colors.green.withOpacity(0.2),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: Colors.green, width: 1),
                          ),
                          child: Text(
                            '${widget.session.currency} ${widget.session.price?.toStringAsFixed(0)}',
                            style: const TextStyle(
                              color: Colors.green,
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                  
                  const SizedBox(height: 16),
                  
                  // Action buttons
                  Row(
                    children: [
                      // Join/Raise Hand button - only show for authenticated users
                      if (AuthService.isAuthenticated) ...[
                        Expanded(
                          child: ElevatedButton(
                            onPressed: _isJoining ? null : _handleJoinSession,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: widget.session.isLive 
                                  ? (_isHandRaised ? Colors.orange : AppConstants.primaryColor)
                                  : Colors.blue,
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(vertical: 12),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(25),
                              ),
                            ),
                            child: _isJoining
                                ? const SizedBox(
                                    width: 20,
                                    height: 20,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                      valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                                    ),
                                  )
                                : Text(
                                    _getJoinButtonText(),
                                    style: const TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                          ),
                        ),
                      ] else ...[
                        // Sign in prompt for non-authenticated users
                        Expanded(
                          child: ElevatedButton(
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => const MobileAuthScreen(showSignUp: false),
                                ),
                              );
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppConstants.primaryColor,
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(vertical: 12),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(25),
                              ),
                            ),
                            child: const Text(
                              'Sign In to Join',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                      ],
                      
                      const SizedBox(width: 12),
                      
                      // Follow button - only show for authenticated users
                      if (AuthService.isAuthenticated)
                        IconButton(
                          onPressed: widget.onFollow,
                          icon: const Icon(
                            Icons.person_add,
                            color: Colors.white,
                            size: 24,
                          ),
                          style: IconButton.styleFrom(
                            backgroundColor: Colors.white.withOpacity(0.2),
                            shape: const CircleBorder(),
                          ),
                        ),
                      
                      // Share button
                      IconButton(
                        onPressed: widget.onShare,
                        icon: const Icon(
                          Icons.share,
                          color: Colors.white,
                          size: 24,
                        ),
                        style: IconButton.styleFrom(
                          backgroundColor: Colors.white.withOpacity(0.2),
                          shape: const CircleBorder(),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _getJoinButtonText() {
    if (widget.session.isLive) {
      return _isHandRaised ? 'Hand Raised' : 'Raise Hand';
    } else if (widget.session.isScheduled) {
      return 'Join When Live';
    } else {
      return 'View Details';
    }
  }

  String _formatTime(DateTime dateTime) {
    final now = DateTime.now();
    final difference = dateTime.difference(now);
    
    if (difference.inDays > 0) {
      return 'in ${difference.inDays}d';
    } else if (difference.inHours > 0) {
      return 'in ${difference.inHours}h';
    } else if (difference.inMinutes > 0) {
      return 'in ${difference.inMinutes}m';
    } else {
      return 'now';
    }
  }

  Future<void> _handleJoinSession() async {
    if (!AuthService.isAuthenticated) {
      _showSignInRequiredDialog();
      return;
    }

    setState(() {
      _isJoining = true;
    });

    try {
      if (widget.session.isLive) {
        if (_isHandRaised) {
          // Lower hand
          await FeedContentService.lowerHand(widget.session.id, AuthService.currentUser!.id);
          setState(() {
            _isHandRaised = false;
          });
          _showSuccessMessage('Hand lowered');
        } else {
          // Raise hand
          await FeedContentService.raiseHand(
            widget.session.id,
            AuthService.currentUser!.id,
            AuthService.currentUser!.fullName,
          );
          setState(() {
            _isHandRaised = true;
          });
          _showSuccessMessage('Hand raised! Waiting for approval...');
        }
      } else if (widget.session.isScheduled) {
        // Join when live
        _showInfoMessage('Session will start ${_formatTime(widget.session.scheduledAt)}');
      } else {
        // View details
        _showInfoMessage('Session details: ${widget.session.title}');
      }
    } catch (e) {
      _showErrorMessage('Failed to join session: $e');
    } finally {
      setState(() {
        _isJoining = false;
      });
    }
  }

  void _showSignInRequiredDialog() {
    showDialog(
      context: context,
      builder: (context) => CustomPopup(
        title: 'Sign In Required',
        message: 'Please sign in to join live sessions and raise your hand.',
        type: PopupType.info,
        onConfirm: () {
          Navigator.of(context).pop();
          // Navigate to auth screen
          Navigator.pushNamed(context, '/auth');
        },
      ),
    );
  }

  void _showSuccessMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.green,
        duration: const Duration(seconds: 2),
      ),
    );
  }

  void _showInfoMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.blue,
        duration: const Duration(seconds: 2),
      ),
    );
  }

  void _showErrorMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
        duration: const Duration(seconds: 3),
      ),
    );
  }
}
