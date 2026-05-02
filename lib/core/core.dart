// ─────────────────────────────────────────────────────────────────────────────
// core.dart  –  F.E.A.S.T. barrel export
//
// RULES:
//  • Every widget used in 2+ places lives in lib/core/widgets/.
//  • Each widget has exactly ONE definition. Duplicate classes removed.
//  • DonateModal covers both "Donate Funds" and "Donate Items" flows.
//  • ConfirmationModal covers Reset / Create / Join / Remove-member flows.
//  • DeleteRemoveModal covers Delete-notification & Remove-bookmark flows.
//  • ItemDonationModal covers the item-quantity stepper (donated).
//  • ReportModal covers report content across requests, events, messages.
//  • ProfilePopup is the canonical user pop-up (profile_menu_dialog removed).
//  • chat_data.dart stays as the local model layer; Firestore replaces it later.
// ─────────────────────────────────────────────────────────────────────────────

// ── Theme & Constants ────────────────────────────────────────────────────────
export 'constants/app_colors.dart';
export 'constants/app_routes.dart';
export 'constants/firestore_paths.dart';
export 'constants/app_router.dart';

// ── Primitive & Layout Widgets ───────────────────────────────────────────────
export 'widgets/feast_background.dart';
export 'widgets/feast_logo.dart';
export 'widgets/feast_tagline.dart';
export 'widgets/bottom_form_background.dart';
export 'widgets/feast_bottom_nav.dart';
export 'widgets/feast_app_bar.dart';
export 'widgets/feast_drawer.dart';
export 'widgets/toggle_login_register.dart';

// ── Form Widgets ─────────────────────────────────────────────────────────────
export 'widgets/labeled_text_field.dart';
export 'widgets/field_label.dart';
export 'widgets/feast_checkbox.dart';
export 'widgets/feast_button.dart';
export 'widgets/feast_link.dart';

// ── Feedback & State Widgets ─────────────────────────────────────────────────
export 'widgets/empty_state_widget.dart';
export 'widgets/error_state_widget.dart';
export 'widgets/loading_overlay.dart';
export 'widgets/offline_banner.dart';
export 'widgets/feast_toast.dart';
export 'widgets/progress_bar_widget.dart';

// ── Media & Content Widgets ──────────────────────────────────────────────────
export 'widgets/image_carousel.dart';
export 'widgets/feast_floating_button.dart';
export 'widgets/feast_expandable_item.dart';
export 'widgets/feast_white_section.dart';
export 'widgets/feast_yellow_section.dart';

// ── List Item Widgets ────────────────────────────────────────────────────────
export 'widgets/aid_request_list_item.dart';
export 'widgets/bookmark_list_item.dart';
export 'widgets/charity_event_list_item.dart';
export 'widgets/chat_list_item.dart';
export 'widgets/group_member_list_item.dart';
export 'widgets/history_log_list_item.dart';
export 'widgets/notification_list_item.dart';

// ── Modals & Dialogs ─────────────────────────────────────────────────────────
// Announcement
export 'widgets/announcement_modal.dart';

// Generic yes/no confirmation (covers: Reset form, Create request/event,
// Disable notifications, Remove group member, Join event, Logout, Cancel)
export 'widgets/confirmation_modal.dart';
export 'widgets/disable_notification_dialog.dart';

// Destructive action (covers: Delete notification, Remove bookmark)
export 'widgets/delete_remove_modal.dart';

// Donation flows
export 'widgets/donate_modal.dart';
export 'widgets/item_donation_modal.dart';
export 'widgets/join_event_dialog.dart';

// Reporting
export 'widgets/report_modal.dart';

// Question / FAQ submission
export 'widgets/question_modal.dart';

// Messaging modals
export 'widgets/create_chat_modal.dart';
export 'widgets/edit_group_modal.dart';
export 'widgets/invite_collaborators_modal.dart';
export 'widgets/remove_members_modal.dart';

// Form utilities
export 'widgets/date_picker_modal.dart';
export 'widgets/file_picker_modal.dart';
export 'widgets/reset_form_dialog.dart';

// Profile
export 'widgets/profile_popup.dart';
export 'widgets/edit_profile_modal.dart';

// ── Services ─────────────────────────────────────────────────────────────────
export 'services/auth_service.dart';
export 'services/firestore_service.dart'; 
export 'services/storage_service.dart'; 
export 'services/notification_service.dart';

// ── Utilities ───────────────────────────────────────────────────────────────
export 'utils/date_parser.dart';
export 'utils/text_formatters.dart';
