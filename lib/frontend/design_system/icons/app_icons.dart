/// Icon path registry.
/// Source of truth — mirrors Figma icon book.
/// Add new icons here as they are exported from Figma.
class AppIcons {
  AppIcons._();

  static const _base = 'assets/icons';

  // ── Actions ──
  static const add = '$_base/add.svg';
  static const close = '$_base/close.svg';
  static const copy = '$_base/copy.svg';
  static const delete = '$_base/delete.svg';
  static const download = '$_base/download.svg';
  static const edit = '$_base/edit.svg';
  static const filter = '$_base/filter.svg';
  static const link = '$_base/link.svg';
  static const refresh = '$_base/refresh.svg';
  static const search = '$_base/search.svg';
  static const select = '$_base/select.svg';
  static const share = '$_base/share.svg';
  static const sort = '$_base/sort.svg';

  // ── Arrows ──
  static const arrowBack = '$_base/arrow-back.svg';
  static const arrowDown = '$_base/arrow-down.svg';
  static const arrowExpand = '$_base/arrow-expand.svg';
  static const arrowLeft = '$_base/arrow-left.svg';
  static const arrowRight = '$_base/arrow-right.svg';
  static const arrowUp = '$_base/arrow-up.svg';

  // ── Media ──
  static const camera = '$_base/camera.svg';
  static const pause = '$_base/pause.svg';
  static const play = '$_base/play.svg';
  static const repeat = '$_base/repeat.svg';
  static const skip = '$_base/skip.svg';
  static const stop = '$_base/stop.svg';
  static const video = '$_base/video.svg';

  // ── Communication ──
  static const chat = '$_base/chat.svg';
  static const comment = '$_base/comment.svg';
  static const group = '$_base/group.svg';
  static const notification = '$_base/notification.svg';
  static const userAdd = '$_base/user-add.svg';

  // ── Navigation ──
  static const home = '$_base/home.svg';
  static const profile = '$_base/profile.svg';
  static const setting = '$_base/setting.svg';

  // ── Status ──
  static const alert = '$_base/alert.svg';
  static const check = '$_base/check.svg';
  static const checkbox = '$_base/checkbox.svg';
  static const error = '$_base/error.svg';
  static const minus = '$_base/minus.svg';
  static const info = '$_base/info.svg';
  static const success = '$_base/success.svg';
  static const verified = '$_base/verified.svg';
  static const warning = '$_base/warning.svg';

  // ── Fitness ──
  static const body = '$_base/body.svg';
  static const computerVision = '$_base/computer-vision.svg';
  static const doctor = '$_base/doctor.svg';
  static const goal = '$_base/goal.svg';
  static const heartRate = '$_base/heart-rate.svg';
  static const stats = '$_base/stats.svg';
  static const streak = '$_base/streak.svg';
  static const timer = '$_base/timer.svg';
  static const trendDown = '$_base/trend-down.svg';
  static const trendUp = '$_base/trend-up.svg';
  static const weight = '$_base/weight.svg';

  // ── Achievements ──
  static const crown = '$_base/crown.svg';
  static const flag = '$_base/flag.svg';
  static const medal = '$_base/medal.svg';
  static const star = '$_base/star.svg';
  static const thumbsDown = '$_base/thumbs-down.svg';
  static const thumbsUp = '$_base/thumbs-up.svg';
  static const trophy = '$_base/trophy.svg';

  // ── UI ──
  static const bundles = '$_base/bundles.svg';
  static const calendar = '$_base/calendar.svg';
  static const dragHandle = '$_base/drag-handle.svg';
  static const ellipses = '$_base/ellipses.svg';
  static const eye = '$_base/eye.svg';
  static const eyeOff = '$_base/eye-off.svg';
  static const lightbulb = '$_base/lightbulb.svg';
  static const listView = '$_base/list-view.svg';
  static const lock = '$_base/lock.svg';
  static const moreDots = '$_base/more-dots.svg';
  static const notebook = '$_base/notebook.svg';
  static const sidebar = '$_base/sidebar.svg';

  // ── Brand (multi-color — do not tint; use SvgPicture.asset directly, not AppIcon) ──
  static const googleG = '$_base/google-g.svg';

  // ══════════════════════════════════════════
  // ── Filled variants (active state) ──
  // ══════════════════════════════════════════

  // Actions
  static const copyFilled = '$_base/copy-filled.svg';
  static const deleteFilled = '$_base/delete-filled.svg';
  static const downloadFilled = '$_base/download-filled.svg';
  static const editFilled = '$_base/edit-filled.svg';
  static const filterFilled = '$_base/filter-filled.svg';
  static const linkFilled = '$_base/link-filled.svg';
  static const refreshFilled = '$_base/refresh-filled.svg';
  static const searchFilled = '$_base/search-filled.svg';
  static const shareFilled = '$_base/share-filled.svg';
  static const sortFilled = '$_base/sort-filled.svg';

  // Arrows
  static const arrowBackFilled = '$_base/arrow-back-filled.svg';
  static const arrowExpandFilled = '$_base/arrow-expand-filled.svg';

  // Media
  static const cameraFilled = '$_base/camera-filled.svg';
  static const pauseFilled = '$_base/pause-filled.svg';
  static const playFilled = '$_base/play-filled.svg';
  static const repeatFilled = '$_base/repeat-filled.svg';
  static const skipFilled = '$_base/skip-filled.svg';
  static const stopFilled = '$_base/stop-filled.svg';
  static const videoFilled = '$_base/video-filled.svg';

  // Communication
  static const chatFilled = '$_base/chat-filled.svg';
  static const commentFilled = '$_base/comment-filled.svg';
  static const groupFilled = '$_base/group-filled.svg';
  static const notificationFilled = '$_base/notification-filled.svg';
  static const userAddFilled = '$_base/user-add-filled.svg';

  // Navigation
  static const homeFilled = '$_base/home-filled.svg';
  static const profileFilled = '$_base/profile-filled.svg';
  static const settingFilled = '$_base/setting-filled.svg';

  // Status
  static const alertFilled = '$_base/alert-filled.svg';
  static const checkboxFilled = '$_base/checkbox-filled.svg';
  static const errorFilled = '$_base/error-filled.svg';
  static const infoFilled = '$_base/info-filled.svg';
  static const successFilled = '$_base/success-filled.svg';
  static const verifiedFilled = '$_base/verified-filled.svg';
  static const warningFilled = '$_base/warning-filled.svg';

  // Fitness
  static const bodyFilled = '$_base/body-filled.svg';
  static const computerVisionFilled = '$_base/computer-vision-filled.svg';
  static const clinicFilled = '$_base/clinic-filled.svg';
  static const doctorFilled = '$_base/doctor-filled.svg';
  static const heartRateFilled = '$_base/heart-rate-filled.svg';
  static const streakFilled = '$_base/streak-filled.svg';
  static const timerFilled = '$_base/timer-filled.svg';
  static const trendDownFilled = '$_base/trend-down-filled.svg';
  static const trendUpFilled = '$_base/trend-up-filled.svg';
  static const weightFilled = '$_base/weight-filled.svg';

  // Achievements
  static const crownFilled = '$_base/crown-filled.svg';
  static const flagFilled = '$_base/flag-filled.svg';
  static const medalFilled = '$_base/medal-filled.svg';
  static const starFilled = '$_base/star-filled.svg';
  static const thumbsDownFilled = '$_base/thumbs-down-filled.svg';
  static const thumbsUpFilled = '$_base/thumbs-up-filled.svg';
  static const trophyFilled = '$_base/trophy-filled.svg';

  // UI
  static const calendarFilled = '$_base/calendar-filled.svg';
  static const ellipsesFilled = '$_base/ellipses-filled.svg';
  static const eyeFilled = '$_base/eye-filled.svg';
  static const eyeOffFilled = '$_base/eye-off-filled.svg';
  static const lightbulbFilled = '$_base/lightbulb-filled.svg';
  static const listViewFilled = '$_base/list-view-filled.svg';
  static const lockFilled = '$_base/lock-filled.svg';
  static const notebookFilled = '$_base/notebook-filled.svg';
  static const sidebarFilled = '$_base/sidebar-filled.svg';

  /// All outline icons for catalog/iteration.
  static const all = <String, String>{
    'add': add,
    'alert': alert,
    'arrow-back': arrowBack,
    'arrow-down': arrowDown,
    'arrow-expand': arrowExpand,
    'arrow-left': arrowLeft,
    'arrow-right': arrowRight,
    'arrow-up': arrowUp,
    'body': body,
    'bundles': bundles,
    'calendar': calendar,
    'camera': camera,
    'chat': chat,
    'check': check,
    'checkbox': checkbox,
    'close': close,
    'comment': comment,
    'computer-vision': computerVision,
    'copy': copy,
    'crown': crown,
    'delete': delete,
    'doctor': doctor,
    'download': download,
    'drag-handle': dragHandle,
    'edit': edit,
    'ellipses': ellipses,
    'error': error,
    'eye': eye,
    'eye-off': eyeOff,
    'filter': filter,
    'flag': flag,
    'goal': goal,
    'google-g': googleG,
    'group': group,
    'heart-rate': heartRate,
    'home': home,
    'info': info,
    'lightbulb': lightbulb,
    'link': link,
    'list-view': listView,
    'lock': lock,
    'medal': medal,
    'minus': minus,
    'more-dots': moreDots,
    'notebook': notebook,
    'notification': notification,
    'pause': pause,
    'play': play,
    'profile': profile,
    'refresh': refresh,
    'repeat': repeat,
    'search': search,
    'select': select,
    'setting': setting,
    'share': share,
    'sidebar': sidebar,
    'skip': skip,
    'sort': sort,
    'star': star,
    'stats': stats,
    'stop': stop,
    'streak': streak,
    'success': success,
    'thumbs-down': thumbsDown,
    'thumbs-up': thumbsUp,
    'timer': timer,
    'trend-down': trendDown,
    'trend-up': trendUp,
    'trophy': trophy,
    'user-add': userAdd,
    'verified': verified,
    'video': video,
    'warning': warning,
    'weight': weight,
  };

  /// All filled icons for catalog/iteration.
  static const allFilled = <String, String>{
    'alert': alertFilled,
    'arrow-back': arrowBackFilled,
    'arrow-expand': arrowExpandFilled,
    'body': bodyFilled,
    'calendar': calendarFilled,
    'camera': cameraFilled,
    'chat': chatFilled,
    'checkbox': checkboxFilled,
    'clinic': clinicFilled,
    'comment': commentFilled,
    'computer-vision': computerVisionFilled,
    'copy': copyFilled,
    'crown': crownFilled,
    'delete': deleteFilled,
    'doctor': doctorFilled,
    'download': downloadFilled,
    'edit': editFilled,
    'ellipses': ellipsesFilled,
    'error': errorFilled,
    'eye': eyeFilled,
    'eye-off': eyeOffFilled,
    'filter': filterFilled,
    'flag': flagFilled,
    'group': groupFilled,
    'heart-rate': heartRateFilled,
    'home': homeFilled,
    'info': infoFilled,
    'lightbulb': lightbulbFilled,
    'link': linkFilled,
    'list-view': listViewFilled,
    'lock': lockFilled,
    'medal': medalFilled,
    'notebook': notebookFilled,
    'notification': notificationFilled,
    'pause': pauseFilled,
    'play': playFilled,
    'profile': profileFilled,
    'refresh': refreshFilled,
    'repeat': repeatFilled,
    'search': searchFilled,
    'setting': settingFilled,
    'share': shareFilled,
    'sidebar': sidebarFilled,
    'skip': skipFilled,
    'sort': sortFilled,
    'star': starFilled,
    'stop': stopFilled,
    'streak': streakFilled,
    'success': successFilled,
    'thumbs-down': thumbsDownFilled,
    'thumbs-up': thumbsUpFilled,
    'timer': timerFilled,
    'trend-down': trendDownFilled,
    'trend-up': trendUpFilled,
    'trophy': trophyFilled,
    'user-add': userAddFilled,
    'verified': verifiedFilled,
    'video': videoFilled,
    'warning': warningFilled,
    'weight': weightFilled,
  };
}
