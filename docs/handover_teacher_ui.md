# Teacher UI Handover

## Goal

Build the Teacher experience for profiles with role `TEACHER`.

Teacher UI must use the Numinumi Figma style and replace the current Student fallback when `HomeScreen.activeRole == ProfileRole.teacher`.

Figma nodes:

- Homepage, no class: `KhbblZdYfW0DKtqDt7zutO`, node `66:1301`
- Homepage, with classes: `KhbblZdYfW0DKtqDt7zutO`, node `72:1889`
- Create class: `KhbblZdYfW0DKtqDt7zutO`, node `66:1402`
- Class detail: `KhbblZdYfW0DKtqDt7zutO`, node `2035:328`
- Manage classroom members: `KhbblZdYfW0DKtqDt7zutO`, node `2091:256`

## Current Repo State

- Role support already exists in `ActiveProfileSession` as `ProfileRole.student`, `parent`, and `teacher`.
- `HomeScreen` now branches to a Teacher-specific UI when `ProfileRole.teacher` is active.
- Networking is centralized in `NetworkApi` / `NetworkClient`; do not call Dio directly from widgets or tabs.
- Network models use `json_annotation` / generated `*.g.dart`; new classroom models should follow this.
- Multipart upload support already exists through `NetworkClient.postMultipart`.
- Avatar/image picking can reuse `AvatarPickerService.pickAvatarPath()`.
- Bottom navigation was recently changed to edge-to-edge with safe-area handled locally.
- The app font has been normalized to Andika. `ThemeData.textTheme` uses `GoogleFonts.andikaTextTheme()`, and old explicit `Nunito` / `Fredoka` overrides were removed from `lib`.
- Profile avatar selection was rebuilt to use a fixed backend key catalog. The app submits `avatar_key` to profile create/update and displays avatars through one shared widget.
- Private S3 profile avatar images are intended to be bundled under `assets/avatars/`; `pubspec.yaml` includes this folder.

## Implemented Status

- Student homepage / classroom search updates are also in this branch now:
  - Student homepage was rebuilt against Figma node `2178:138`.
  - Student homepage pending invitations are API-backed through `POST /classrooms/invitations/my-pending`.
  - Student invitation cards call accept/reject APIs and show an inline row spinner while each action is processing.
  - Student homepage joined-classroom list calls `POST /classrooms/my-joined` with `{ "profile_id": {{profile_id}} }`.
  - Student homepage class cards use Figma local assets and fixed layout values. A card height overflow was fixed by increasing the grid item extent from `168` to `176`.
  - Student homepage Figma hero Assessment and Practice buttons are wired to the old behavior again:
    - Assessment opens `GradeSelectionScreen` with `quizPurposeAssessment`
    - Practice opens `GradeSelectionScreen` with `quizPurposePractice`
  - Join classroom screen was built from Figma node `2017:2`.
  - Join classroom search calls `POST /classrooms/list` and always includes `profile_id` plus optional `search`.
  - Join request action calls `POST /classrooms/join-by-code` with `profile_id` and `classroom_code`.
  - Classroom search results use the backend `relationship` field to prevent duplicate join requests.
  - Relationship values handled: `MEMBER`, `PENDING_INVITATION`, `PENDING_REQUEST`, `NONE`.
  - Only `relationship: NONE` enables the join request button.
  - Status icons in the join search list use local Figma-exported SVG assets; do not use Material icons for these Figma-driven icons.
  - The `NONE` status label is currently `CHƯA THAM GIA` / `NOT JOINED`, while the button remains the join action.
- Added classroom API/model/service plumbing:
  - `lib/core/network/classroom_models.dart`
  - `lib/core/network/classroom_models.g.dart`
  - `NetworkApi.createClassroom`
  - `NetworkApi.listClassrooms`
  - `NetworkApi.listMyJoinedClassrooms`
  - `NetworkApi.getClassroomDetail`
  - `NetworkApi.sendClassroomInvitations`
  - `NetworkApi.listMyPendingClassroomInvitations`
  - `NetworkApi.acceptClassroomInvitation`
  - `NetworkApi.rejectClassroomInvitation`
  - `lib/features/onboarding/data/classroom_api.dart`
- Added split Teacher UI files:
  - `teacher_classroom_screens.dart`
  - `teacher_home_tab.dart`
  - `teacher_report_tab.dart`
  - `teacher_create_class_screen.dart`
  - `teacher_class_detail_screen.dart`
  - `teacher_class_members_screen.dart`
  - `teacher_shared_widgets.dart`
- Teacher bottom navigation is now 3 items only: Home, Report, Settings.
- Create Class is a pushed full-screen flow, not a tab.
- Class Detail is a pushed full-screen flow, not a tab.
- Create Class select fields open bottom sheets.
- Teacher class list refreshes after successful class creation.
- Classroom creation sends `program_ids` only as `List<int>`; `program_id` is no longer sent.
- The Create Class program selector supports selecting multiple programs, renders selected chips below the field, and keeps the selector as a scrollable bottom sheet.
- Teacher class detail reads the class code from `classroom_code` through `ClassroomModel.classroomCode`. The parser still falls back from legacy `invite_code` during backend rollout.
- Class detail copy actions are wired:
  - copy classroom code
  - copy join link
  - share button copies the join link
- Stable Figma-exported assets were added under `assets/images/` for teacher class detail/add/back/copy icons. Runtime does not depend on expiring Figma URLs.
- `flutter_svg` was added for SVG Figma exports.
- Teacher Class Detail lower area was updated from the Figma node:
  - `Quản lý thành viên` card
  - `Chức Năng Lớp Học` heading
  - 2x2 class function grid with `Bài Tập` first tile
  - member count uses `ClassroomModel.displayStudentCount` / backend `student_count`, not `member_count`
  - request count loads from `POST /classrooms/join-requests/list`
- Added Teacher Manage Members screen from Figma node `2091:256`:
  - pushed from the `Quản lý thành viên` card
  - join request list loads from `POST /classrooms/join-requests/list`
  - accept/reject actions call `POST /classrooms/join-requests/approve` and `POST /classrooms/join-requests/reject`
  - joined student list loads from `POST /classrooms/members/list` with `role: STUDENT` and `status: ACTIVE`
  - joined student rows and join-request rows display student avatars through the shared `ProfileAvatarImage` rule, not custom per-screen initials/images
  - add-student button opens a bottom sheet search/select flow
- Add-student bottom sheet searches profiles via `POST /profiles/list` with `{ "search": "Keyword" }`, supports multi-select, and sends real invitations through `POST /classrooms/invitations/send`.
- Manage Members shows a blocking loading overlay while teacher invitations are being sent and disables the add-student button to prevent duplicate sends.
- `ProfileListRequest` now supports optional `userId` and optional `search`; `ProfileApi.searchProfiles(search: ...)` wraps the search use case while existing settings/profile code still uses `listProfiles(userId: ...)`.
- Backend numeric ID fields were converted from string-compatible IDs to `int`, `int?`, and `List<int>` across network models, request models, services, UI/state logic, and generated serializers.
- Active profile secure-storage ID encoding/decoding is centralized through named helper methods; do not add scattered `.toString()` conversions except at explicit string-only boundaries.
- Student profile creation/editing hides document type selection and submits `id_type: MOET` by default. Teacher profile document type and teacher ID are optional as a pair: both empty is valid, both filled is valid, only one filled is invalid.
- OTP preview for login/signup now displays as one inline line on the OTP entry screen instead of an alert dialog.
- Teacher home class cards display `ClassroomModel.displayStudentCount`, not `displayMemberCount`.
- Teacher home class cards center the member/request count text. The grid card extent was increased to avoid a two-line request-count overflow.
- Recent validation in the current Codex environment:
  - `dart run build_runner build --delete-conflicting-outputs` succeeded.
  - `dart format ...` succeeded for touched files.
  - `flutter analyze` passed with `No issues found`.

## Latest Avatar/Profile Updates

- Added fixed profile avatar catalog:
  - `lib/features/onboarding/domain/profile_avatar.dart`
  - nine `profile-avatars/...png` backend keys mapped to local `assets/avatars/...png` asset paths
- Added shared avatar renderer:
  - `lib/features/onboarding/presentation/widgets/profile_avatar_image.dart`
  - supports local picked file path, bundled avatar asset by `avatar_key`, backend `avatar_url`, and one standardized fallback icon/background
- Profile avatar display was standardized across:
  - Home student/profile header
  - Home user avatar in bottom nav
  - Teacher profile header
  - Settings landing avatar
  - Account details avatar
  - Profile list cards
  - Profile create/edit avatar selector
- Profile create/edit now shows a bottom-sheet grid of the fixed avatar catalog for both Student and Teacher profiles.
- The avatar bottom sheet is scroll-controlled and bounded to avoid overflow on large iPhone simulators.
- Settings landing now displays the current active profile avatar/name. Account avatar/name are only fallback when no active profile exists.
- Settings landing avatar has a small bottom-right switch icon; tapping it opens the profile list so users can change active profile.
- `scripts/download_profile_avatars.sh` downloads the nine private S3 avatars into `assets/avatars/` using `AWS_*` env vars or `STORAGE_ACCESS_KEY` / `STORAGE_SECRET_KEY`. Do not commit credentials.
- Profile list cards now display and copy backend `profile_code`, not internal `id` and not `profile_id`. `StudentProfile.profileCode` parses `profile_code`; if no profile code is present, the code row is hidden.

## Latest Classroom Exercise / Homework Updates

- Added classroom exercise API/model/service plumbing:
  - `lib/core/network/classroom_exercise_models.dart`
  - `lib/core/network/classroom_exercise_models.g.dart`
  - `NetworkApi.listClassroomExercises`
  - `NetworkApi.createClassroomExercise`
  - `NetworkApi.getClassroomExerciseDetail`
  - `NetworkApi.updateClassroomExercise`
  - `lib/features/onboarding/data/classroom_exercise_api.dart`
- Teacher homework screens added under the teacher classroom screen parts:
  - `teacher_homework_screen.dart`
  - `teacher_homework_detail_screen.dart`
  - `teacher_create_homework_screen.dart`
- Teacher class detail `Bài Tập` function tile opens the teacher homework list for the selected classroom.
- Teacher homework list calls `POST /classroom-exercises/list` with `classroom_id` and `profile_id`.
- Teacher create homework calls `POST /classroom-exercises/create`.
  - Create payload now includes both `title` and `description`.
  - `title` is sent from the current title input, trimmed.
  - `description` is sent from the current description input, trimmed.
  - Do not use default/fallback values for `title` or `description`; empty inputs should send empty strings unless product validation is explicitly added later.
  - Program must be explicitly selected; do not preselect the first/default program.
  - Chapter and lesson inputs start empty.
  - Start/end date pickers are real date/time pickers, require future dates, and end date must be after start date.
  - Visibility switch uses label `Visibility` / `Hiển thị` and sends `PUBLIC` or `PRIVATE`.
  - Class selector opens a bottom sheet and loads classroom detail so grade/program/school display from mapped backend IDs.
  - Program selector is constrained to the selected classroom `program_id` / `program_ids`.
- Teacher assignment detail calls `GET /classroom-exercises/:id?profile_id={{profile_id}}`.
  - Detail screen shows a loading state before displaying fetched API data.
  - It parses detail responses that return top-level `exercise` without `mstatus`.
  - It displays question data from `questions`, answer content from answer objects, and correct answer from `right_answer`.
  - It shows labeled values for `chapter_name` and `lesson_name`.
  - It shows description only when the API returns `description`, `assignment_description`, `exercise_description`, or `metadata.description`.
  - No placeholder question, answer, title, due date, or question-count values should be rendered for missing real API data.
- Teacher assignment detail visibility switch tracks API value vs edited value.
  - If changed, a `Save` action appears in the app bar.
  - Save calls `POST /classroom-exercises/update` with `profile_id`, `classroom_exercise_id`, and `visibility`.
- Student classroom detail loads public homework via `POST /classroom-exercises/list` with `visibility: PUBLIC`.
  - The homework category box count comes from the loaded homework list.
  - Upcoming deadlines come from the loaded homework list, sorted by nearest future `end_date`.
  - Loading and empty states are shown; do not use static sample deadline values.
- Student homework screen receives `classroomId` and `profileId`, calls the same list API with `visibility: PUBLIC`, and displays real exercise cards.
- Student homework list now wires the backend submission filter through `submission_status`:
  - `ClassroomExerciseListRequest` includes optional `submission_status`
  - `ClassroomExerciseApi.listExercises(...)` accepts and forwards `submissionStatus`
  - homework filter tabs send:
    - `NOT_SUBMITTED` for `Chưa nộp` / `Not submitted`
    - `SUBMITTED` for `Đã nộp` / `Submitted`
    - `NOT_SUBMITTED` for `Quá hạn` / `Overdue`, then overdue is still derived locally from `end_date`
- Student homework submitted state now uses only backend `submission_status`.
  - Do not fall back to `status` / `exercise_status` for student submission behavior.
  - `ClassroomExercise.submissionStatus` is parsed only from `submission_status`.
- Student homework cards now display a visible status badge:
  - `Chưa nộp` / `Not submitted`
  - `Đã nộp` / `Submitted`
  - `Quá hạn` / `Overdue`
- If `submission_status == SUBMITTED`, students cannot open the attempt flow again:
  - blocked in `StudentHomeworkScreen`
  - blocked in student classroom upcoming-deadline tiles
  - blocked taps show localized `studentHomeworkAlreadySubmitted` snackbar text
- Student class detail teacher avatar follows the shared real-data rule:
  - Display backend avatar URL from classroom owner/teacher fields when present.
  - Otherwise show a neutral initial generated from the teacher name.
  - Do not use the old static `assets/images/student_class_teacher.png` placeholder as the teacher avatar.
- Real API-backed UI rule: do not keep placeholder/mock values for fields that should come from backend data. Show loading, empty, or error states until real data is available, then display mapped backend values only.

## Latest Passcode Lock Updates

- Added local 4-digit app passcode support stored directly in `FlutterSecureStorage`, keyed per authenticated backend `userId`.
- Passcodes are intentionally local-only:
  - no backend endpoint is called
  - no hashing/crypto dependency is used
  - normal logout does not clear the saved local passcode
- Added passcode service:
  - `lib/features/onboarding/data/passcode_service.dart`
  - `SecurePasscodeService.hasPasscode`
  - `SecurePasscodeService.setPasscode`
  - `SecurePasscodeService.verifyPasscode`
  - `SecurePasscodeService.clearPasscode`
- Added reusable passcode UI:
  - `lib/features/onboarding/presentation/screens/passcode_screen.dart`
  - Figma source: Numinumi file `KhbblZdYfW0DKtqDt7zutO`, node `2220:1597`
  - uses Andika, white background, top circular back button, Numinumi mascot, four numeric PIN boxes, teal primary button, and text-link skip where applicable
  - setup/change flows collect the PIN twice and show inline mismatch errors
  - unlock/verify flows clear and shake input on invalid passcode
- Local Figma PIN assets were exported and bundled under `assets/images/`:
  - `pin_figma_mascot.png`
  - `pin_figma_back.svg`
  - `pin_figma_arrow.svg`
  - SVG fills were normalized to explicit colors because the raw Figma exports used CSS variable fills that did not reliably render in `flutter_svg`
- Onboarding passcode gate is wired through `OnboardingCubit`:
  - after signup or OTP login, if the authenticated user has no passcode, show skippable setup before Home
  - skipping setup enters Home without storing a passcode
  - on app start/session restore, if the saved auth token resolves to a user with a saved passcode, show unlock before Home
  - backing out of app-start unlock logs out/clears auth token and returns to Welcome
- Passcode/login flow was further changed:
  - app startup no longer automatically resumes directly into Home
  - `NumiHome` no longer calls `restoreSession()` on cubit creation
  - login screen now has a conditional `Đăng nhập với PIN` / `Log in with PIN` entry point
  - the PIN login link is shown from local PIN availability, not from an eager successful session restore
  - after correct local PIN entry, the app re-validates the saved auth session through the existing token-backed current-user flow before entering Home
  - if the saved session is invalid/expired, PIN login returns to Login and shows localized session-expired messaging
- `SecurePasscodeService` now also tracks the last user id with a saved local passcode:
  - new helper `lastPasscodeUserId()`
  - new storage key `local_passcode_v1_last_user_id`
  - legacy passcodes created before this change are recovered by scanning existing secure-storage passcode keys once and backfilling the last-user-id marker
- PIN screen navigation/back behavior:
  - top-left back button is wired for PIN login unlock
  - system/device back is intercepted through `PopScope` and routes through the same `onBack` logic
- PIN screen layout rules after the latest review:
  - screen stretches to full device width and height
  - do not wrap the whole PIN screen in a hardcoded `360x800` design canvas
  - centered visual groups are centered with layout primitives on the real device canvas
  - do not derive spacing from width/ratio scaling for the main PIN screen layout; keep literal Figma values for element sizes/offsets where they are still used
- Settings passcode management was added to the Settings landing menu:
  - no passcode: opens setup flow
  - existing passcode: opens a bottom sheet with Change PIN and Remove PIN
  - changing PIN requires verifying the current PIN first
  - removing PIN requires verifying the current PIN first, then deletes only the local secure-storage passcode
- New passcode strings were added to `AppKeys` and `AppStrings` for Vietnamese and English.
- Recent validation:
  - `dart format ...` succeeded for touched files
  - `flutter analyze` passed with `No issues found`
  - `flutter test` was not run, following the project guidance not to run tests unless explicitly requested

## Latest Welcome / Login Refresh

- Welcome screen was rebuilt from Figma file `KhbblZdYfW0DKtqDt7zutO`, node `1:536`.
- Login screen keeps the existing phone-login behavior, but now includes the conditional PIN-login link from Figma file `KhbblZdYfW0DKtqDt7zutO`, node `2210:1120`.
- Welcome/login-related local Figma assets were exported under `assets/images/` and the current branch includes:
  - `welcome_figma_mascot.png`
  - `welcome_figma_waves.png`
  - `welcome_figma_books.png`

## API Requirements

Add classroom endpoints through `NetworkApi`, wrapped by a feature service like `ClassroomApi`.

Create class:

```http
POST /classrooms/create
multipart/form-data
profile_id
name
description
program_ids
grade_id
school_id
max_members
file
```

Get class list:

```http
POST /classrooms/list
{
  "profile_id": "{{profile_id}}"
}
```

Search classroom for student join:

```http
POST /classrooms/list
{
  "profile_id": {{profile_id}},
  "search": "Lớp 1C"
}
```

Student joined classroom list:

```http
POST /classrooms/my-joined
{
  "profile_id": {{profile_id}}
}
```

Request student join by classroom code:

```http
POST /classrooms/join-by-code
{
  "profile_id": {{profile_id}},
  "classroom_code": "DF-3202"
}
```

Get class detail:

```http
GET /classrooms/:id?profile_id={{profile_id}}
```

Search student profiles for classroom invite:

```http
POST /profiles/list
{
  "search": "Keyword"
}
```

List join requests for each class:

```http
POST /classrooms/join-requests/list
{
  "profile_id": {{profile_id}},
  "classroom_id": {{classroom_id}}
}
```

Current join-request response shape:

```json
{
  "mstatus": 200,
  "pagination": {
    "has_next": false,
    "has_previous": false,
    "page": 1,
    "size": 20,
    "skip": 0,
    "take_all": false,
    "total_count": 1,
    "total_pages": 1
  },
  "requests": [
    {
      "classroom_id": 1,
      "member_role": "STUDENT",
      "member_status": "PENDING_REQUEST",
      "profile_id": 6,
      "request_id": 3,
      "requested_dt": "2026-06-01T08:34:16.617413Z",
      "requester": {
        "avatar_url": null,
        "name": "Wuyen",
        "profile_id": 6,
        "role": "STUDENT"
      }
    }
  ],
  "status": "Success"
}
```

Display join-request student info from nested `requester`.

Approve join request:

```http
POST /classrooms/join-requests/approve
{
  "profile_id": {{profile_id}},
  "classroom_id": {{classroom_id}},
  "target_profile_id": {{target_profile_id}}
}
```

Reject join request:

```http
POST /classrooms/join-requests/reject
{
  "profile_id": {{profile_id}},
  "classroom_id": {{classroom_id}},
  "target_profile_id": {{target_profile_id}}
}
```

List active students in class:

```http
POST /classrooms/members/list
{
  "profile_id": {{profile_id}},
  "classroom_id": {{classroom_id}},
  "role": "STUDENT",
  "status": "ACTIVE"
}
```

Current active-student member response shape:

```json
{
  "members": [
    {
      "classroom_id": 1,
      "id": 2,
      "joined_dt": "2026-06-01T08:12:57.888236Z",
      "member_id": 2,
      "member_profile": {
        "avatar_url": null,
        "name": "Wuoc",
        "profile_id": 5,
        "role": "STUDENT"
      },
      "member_role": "STUDENT",
      "member_status": "ACTIVE",
      "profile_id": 5
    }
  ],
  "mstatus": 200,
  "pagination": {
    "has_next": false,
    "has_previous": false,
    "page": 1,
    "size": 20,
    "skip": 0,
    "take_all": false,
    "total_count": 1,
    "total_pages": 1
  },
  "status": "Success"
}
```

Display active member student info from nested `member_profile`.

Send classroom invitations:

```http
POST /classrooms/invitations/send
{
  "inviter_profile_id": {{teacher_profile_id}},
  "classroom_id": {{classroom_id}},
  "targets": [6]
}
```

List pending invitations for a student:

```http
POST /classrooms/invitations/my-pending
{
  "profile_id": {{student_profile_id}}
}
```

Accept invitation:

```http
POST /classrooms/invitations/accept
{
  "invitee_profile_id": {{student_profile_id}},
  "inviter_profile_id": {{teacher_profile_id}},
  "classroom_id": {{classroom_id}}
}
```

Reject invitation:

```http
POST /classrooms/invitations/reject
{
  "invitee_profile_id": {{student_profile_id}},
  "inviter_profile_id": {{teacher_profile_id}},
  "classroom_id": {{classroom_id}}
}
```

The add-student UI filters results to student profiles and allows selecting many. Sending invite requests is API-backed; do not restore the old local-only queued behavior.

Model parsing should be defensive because exact backend response examples were not provided. Match existing app pattern:

- Response envelope: `mstatus`, `status`, `mmessage`, `debug`
- List may appear as `classrooms`, `classes`, `items`, or nested under `data`
- Detail/create may appear as `classroom`, `class`, or nested under `data`
- Class code is read from `classroom_code` and displayed in full. `ClassroomModel.fromJson` still accepts legacy `invite_code` as a fallback. The class detail class-code chip uses scale-down fitting instead of ellipsis.
- Join-request/member list parsing accepts `members`, `students`, `profiles`, `items`, `join_requests`, `requests`, or those fields nested under `data`.
- Invitation list parsing accepts `invitations`, `classroom_invitations`, `items`, `classes`, `classrooms`, or those fields nested under `data`.
- `ClassroomMemberListResponse` parses pagination.
- `ClassroomInvitationListResponse` parses pagination.
- Join-request rows parse `request_id` as `ClassroomStudent.id` and nested `requester` as the source of `profileId`, `name`, `avatarKey`, `avatarUrl`, and `role`.
- Active member rows parse nested `member_profile` as the source of `profileId`, `name`, `avatarKey`, `avatarUrl`, and `role`.
- Invitation rows parse `classroom`, `class`, `inviter`, `teacher`, `owner`, `inviter_profile_id`, and `teacher_profile_id` defensively.
- `member_role` maps to `ClassroomStudent.role`; `member_status` maps to `ClassroomStudent.status`; `joined_dt` maps to `ClassroomStudent.joinedAt`.
- Class list/detail may include `member_count`, `teacher_count`, and `student_count`. `ClassroomModel.studentCount` maps explicitly from `student_count`; UI student counts should use `displayStudentCount`, not `member_count`.
- Treat `mstatus != 200` as an exception using the current NetworkApi error style

Numeric ID model behavior:

- Backend numeric IDs are `int`, `int?`, or `List<int>` end to end. This includes auth/profile/user IDs, relation IDs, grade/program/semester/school IDs, classroom IDs, quiz IDs, and chapter relation IDs.
- Request models should use `int`, `int?`, or `List<int>` for backend numeric IDs.
- Do not use string-style checks such as `.trim()` or `.isEmpty` on backend numeric IDs; use null checks and integer equality.
- Keep human/external identifiers as strings: `idType`, `studentId`, `teacherId`, `identifier`, `deviceId`, `otpId`, classroom codes, phone/email fields, avatar keys, and avatar URLs.
- Use named helpers for unavoidable string-only boundaries such as secure-storage active profile values, URL path/query encoding, and intentionally user-visible ID display.

Profile avatar API:

- `CreateProfileRequest` and `UpdateProfileRequest` include optional `avatarKey`, serialized as `avatar_key`.
- `NetworkApi.createProfile` and `NetworkApi.updateProfile` include `avatar_key` in multipart form data when present.
- Keep the submitted value as the backend key, for example `profile-avatars/20260530-92ad1bf7-289a-4efa-836b-863cb4b6e5a8.png`.
- Display should prefer bundled asset by `avatar_key`; backend `avatar_url` remains supported as fallback/legacy data.

## Implementation Plan

### Data layer

- `lib/core/network/classroom_models.dart` has json-serializable request/response/domain models.
- `classroom_models.g.dart` has been generated/updated.
- `ProfileListRequest` accepts either `user_id` or `search` and uses `includeIfNull: false`.
- `ProfileApi.searchProfiles(search: ...)` calls existing `NetworkApi.listProfiles` with only the search keyword.
- `ClassroomListRequest` requires `profile_id` and accepts optional `search`.
- `ClassroomJoinByCodeRequest` sends `profile_id` and `classroom_code`.
- `ClassroomRelationship` parses `MEMBER`, `PENDING_INVITATION`, `PENDING_REQUEST`, `NONE`, and falls back to `unknown`.
- `ClassroomModel.studentCount` maps from API field `student_count`.
- `ClassroomModel.displayStudentCount` is the correct value for UI text like `Học sinh đã tham gia (n)`.
- `ClassroomModel.displayMemberCount` remains available for total member count and falls back to student count.
- `ClassroomModel.classroomCode` maps from API field `classroom_code`; legacy `invite_code` is only a parser fallback.
- `ClassroomStudent` parses defensive profile/member shapes including nested `requester`, `member_profile`, `profile` / `user`, `target_profile_id`, `student_profile_id`, `avatar_key`, and `avatar_url`.
- `NetworkApi.createClassroom`, `NetworkApi.listClassrooms`, `NetworkApi.listMyJoinedClassrooms`, `NetworkApi.getClassroomDetail`, `NetworkApi.joinClassroomByCode`, `NetworkApi.listClassroomJoinRequests`, `NetworkApi.listClassroomMembers`, `NetworkApi.approveClassroomJoinRequest`, `NetworkApi.rejectClassroomJoinRequest`, `NetworkApi.sendClassroomInvitations`, `NetworkApi.listMyPendingClassroomInvitations`, `NetworkApi.acceptClassroomInvitation`, and `NetworkApi.rejectClassroomInvitation` exist.
- `lib/features/onboarding/data/classroom_api.dart` contains `ClassroomService`, `ClassroomApi`, and `ClassroomException`.
- Keep all endpoint paths and FormData construction outside UI.

### Student home and join classroom

- Student homepage uses the active student profile id from `ActiveProfileSession.profileStableId`.
- Student homepage joined classroom list calls `ClassroomService.listMyJoinedClassrooms`, which uses `POST /classrooms/my-joined`.
- Student homepage loads pending classroom invitations through `ClassroomService.listMyPendingInvitations`, which uses `POST /classrooms/invitations/my-pending`.
- Student invitation accept/reject calls send active student `profile_id` as `invitee_profile_id`, invitation teacher id as `inviter_profile_id`, and the invitation classroom id.
- Accepting an invitation refreshes both pending invitations and joined classroom list.
- Join Classroom is pushed from the student homepage CTA.
- Join Classroom search calls `ClassroomService.searchClassrooms(profileId: ..., search: ...)`, which uses `POST /classrooms/list`.
- Classroom search result cards must read `ClassroomModel.relationshipStatus`:
  - `NONE`: enable join button, label `CHƯA THAM GIA` / `NOT JOINED`, use the Figma enter icon.
  - `MEMBER`: disable join button, label `ĐÃ THAM GIA` / `JOINED`, use the local Figma graduation icon.
  - `PENDING_INVITATION`: disable join button, label `ĐÃ ĐƯỢC MỜI` / `INVITED`, use the local Figma filter icon.
  - `PENDING_REQUEST`: disable join button, label `ĐANG CHỜ` / `PENDING`, use the local Figma bell icon.
  - `unknown`: disable join button defensively.
- `_joinClassroom` must guard relationship state before calling the API to prevent duplicate requests even if the button is accidentally triggered.
- The grade filter pills on the join screen should stay compact and must not stretch full width.
- The join screen header should show the Figma back icon.
- New student Figma screens must use local Figma-exported assets and direct Figma numbers, not viewport scale multipliers.

### Teacher home

- Teacher-specific tab composition exists under `HomeScreen` when `activeRole == ProfileRole.teacher`.
- Teacher bottom bar must have only 3 tabs:
  - Home
  - Report
  - Settings
- Review/History are removed from Teacher bottom nav.
- Keep the bottom bar style aligned with Figma:
  - white translucent dock
  - rounded top corners
  - active teal pill `#3F8F92`
  - muted inactive labels/icons
  - safe-area bottom inset included
- Teacher Home tab:
  - Header with teacher avatar, welcome label, profile name, notification icon
  - Teal hero card with Numinumi mascot
  - Class section title `Lớp học của bạn`
  - No-class state shows mascot panel and `Tạo Lớp Học Mới`
  - With-class state shows two-column class cards and a small add button
  - Tapping create/add pushes Create Class screen
  - Tapping a class or `Vào Lớp` pushes Class Detail screen
  - Per-class student count uses `classroom.displayStudentCount`, not `displayMemberCount`
- Current Figma fixes applied:
  - class card shadow is painted outside the clipped Material layer
  - class grid has no default GridView padding
  - class grid uses Figma-like `16px` spacing and `168px` card extent
  - small coral add button shadow is painted outside the clipped Material layer

### Create class screen

- Push as a new screen, not inside a Home tab.
- Use `Scaffold` + `SafeArea`.
- Fields:
  - Class avatar upload
  - Grade
  - Class name
  - Program
  - School
  - Description
  - Create button
- Reuse existing profile option APIs where possible for grade/program/school selections.
- Submit through `ClassroomService.createClassroom`.
- Required fields for v1: `profile_id`, `name`, `program_ids`, `grade_id`, `school_id`, `max_members`.
- Program selection is multi-select. Submit all selected programs through `program_ids`; do not send `program_id`.
- Default `max_members` to `50`.
- `description` optional.
- `file` optional unless the user picks an image.
- On success, pop back and refresh teacher class list.

### Class detail screen

- Pushes as a new screen, not inside a Home tab.
- Uses `Scaffold` + `SafeArea`.
- Loads detail by classroom id and active teacher `profile_id`.
- Match Figma:
  - top header `Lớp Học`
  - white classroom info card at the top
  - large pale background area
  - `Quản lý thành viên` card below the info card
  - `Chức Năng Lớp Học` heading
  - 2x2 function grid; first tile is `Bài Tập`, remaining tiles are currently empty placeholders matching Figma
- Classroom info card includes:
  - class icon from Figma export
  - class name
  - share icon from Figma export
  - grade/program/description icons from Figma exports
  - full `classroom_code`
  - QR icon from Figma export
  - join link using the full classroom code
- Member-management card count should use `classroom.displayStudentCount`, so API responses like `student_count: 0` do not accidentally display `member_count: 1`.
- Member-management request count loads from `ClassroomService.listJoinRequests`.
- The `Quản lý thành viên` card uses the Figma chevron SVG asset. The SVG stroke is hardcoded to `#718096` because the raw Figma export used a CSS variable that `flutter_svg` may not render reliably.

### Manage members screen

- Pushes as a new screen from Class Detail, not inside a Home tab.
- Uses `Scaffold` + `SafeArea`.
- Figma node: `2091:256`.
- Header title: `Thành Viên`.
- Top coral add button opens an add-student bottom sheet.
- Join requests are API-backed through `ClassroomService.listJoinRequests`.
- Accept/reject icons call `ClassroomService.approveJoinRequest` / `ClassroomService.rejectJoinRequest`, then refresh the lists.
- Joined students are API-backed through `ClassroomService.listStudents`, which sends `role: STUDENT` and `status: ACTIVE`.
- Add-student bottom sheet:
  - search input with 700ms debounce to avoid excessive API calls while users type slowly
  - calls `ProfileApi.searchProfiles(search: keyword)`
  - uses `ProfileAvatarImage` for result avatars
  - supports selecting multiple students
  - `Gửi lời mời` sends `POST /classrooms/invitations/send`
  - the screen shows a blocking loading overlay while the send-invite API call is in flight
  - selected profiles are tracked by stable profile id through `ActiveProfileSession.profileStableId`

### Report tab

- No Figma/API was provided for Teacher Report.
- Implement a Figma-style placeholder tab in v1 unless the user provides report API/design before implementation.
- Label bottom tab as `BÁO CÁO` / localized key equivalent.

## Localization

- Add new app keys for all new teacher strings.
- Add Vietnamese and English translations in `AppStrings`.
- The app is multilingual. Every new or changed user-facing string must be represented in both Vietnamese and English before the change is considered complete.
- Backend-provided classroom names/descriptions are displayed as-is.
- API metadata behavior does not change unless classroom APIs later require metadata.

## Assets

- Prefer existing app assets and Figma-exported assets for screens that are matching Figma.
- Figma remote asset URLs expire, so do not depend on them at runtime.
- Profile avatar assets are bundled under `assets/avatars/`, not loaded from private S3 at runtime.
- `pubspec.yaml` includes `assets/avatars/`.
- Avatar download helper:
  - `scripts/download_profile_avatars.sh`
  - requires locally configured credentials via `AWS_PROFILE`, `AWS_ACCESS_KEY_ID` / `AWS_SECRET_ACCESS_KEY`, or `STORAGE_ACCESS_KEY` / `STORAGE_SECRET_KEY`
  - previous attempts failed with `403 Forbidden` when the active local AWS credentials did not have access; no credentials should be written to repo or chat logs.
- Stable Teacher UI exports currently added:
  - `assets/images/teacher_class_add.svg`
  - `assets/images/teacher_class_back.svg`
  - `assets/images/teacher_class_copy.svg`
  - `assets/images/teacher_class_link_copy.svg`
  - `assets/images/teacher_class_graduation.svg`
  - `assets/images/teacher_class_share.png`
  - `assets/images/teacher_class_grade.png`
  - `assets/images/teacher_class_program.png`
  - `assets/images/teacher_class_description.png`
  - `assets/images/teacher_class_qr.png`
  - `assets/images/teacher_class_members.png`
  - `assets/images/teacher_class_assignment.png`
  - `assets/images/teacher_class_chevron.svg`
  - `assets/images/teacher_member_accept.png`
  - `assets/images/teacher_member_reject.png`
  - `assets/images/teacher_member_avatar_1.png`
  - `assets/images/teacher_member_avatar_2.png`
- Stable Student UI exports currently added:
  - `assets/images/student_home_mascot.png`
  - `assets/images/student_home_class_icon.png`
  - `assets/images/student_home_bell.svg`
  - `assets/images/student_home_invite.svg`
  - `assets/images/student_home_practice.svg`
  - `assets/images/student_home_assessment.svg`
  - `assets/images/student_home_nav_home.svg`
  - `assets/images/student_home_nav_class.svg`
  - `assets/images/student_home_nav_report.svg`
  - `assets/images/student_home_nav_message.svg`
  - `assets/images/student_home_nav_settings.svg`
  - `assets/images/student_join_back.svg`
  - `assets/images/student_join_search.png`
  - `assets/images/student_join_scan.png`
  - `assets/images/student_join_filter.svg`
  - `assets/images/student_join_dropdown.svg`
  - `assets/images/student_join_book.svg`
  - `assets/images/student_join_enter.svg`
- Figma SVG exports sometimes contain CSS variables such as `var(--fill-0, ...)` or `var(--stroke-0, ...)`; replace them with direct SVG color values before using them with `flutter_svg`.

## Typography

- The app should use one font: Andika.
- Global theme: `GoogleFonts.andikaTextTheme()`.
- Do not add new `fontFamily: 'Nunito'`, `fontFamily: 'Fredoka'`, `GoogleFonts.fredoka`, `GoogleFonts.beVietnamPro`, or `GoogleFonts.plusJakartaSans` usages.
- `pubspec.yaml` no longer registers the local Nunito font.

## Profile Forms

- Student profile create/edit keeps the existing student fields and student ID field:
  - document type selector is hidden for students.
  - `id_type` is submitted as `MOET` by default.
  - `student_id` remains optional free-text ID value.
- Teacher profile create/edit is role-specific and shows:
  - name
  - school
  - optional document type (`id_type`) with label `Loại giấy tờ` / `Document type`
  - optional `teacher_id`
- Teacher document type and teacher ID are optional as a pair:
  - both empty: valid, submit neither `id_type` nor `teacher_id`
  - both filled: valid, submit both
  - only one filled: invalid, show validation error
- Profile APIs submit `id_type` and the matching role ID field only when values are present.
- Profile APIs submit `avatar_key` when a catalog avatar is selected.
- The API values remain `MOET` and `PUBLIC_ID`; only the visible labels differ by role.
- Profile create/update select inputs use bottom sheets, not inline dropdown menus.
- Profile create/update avatar selection uses a bottom sheet grid. Keep it scrollable/bounded to avoid RenderFlex overflow.
- Use `ProfileAvatarImage` for avatar display. Do not introduce new default avatar images per screen; keep the shared background/fallback consistent.
- Settings landing should display active profile avatar/name and a switch icon that navigates to the profile list.

## Figma Layout Rules

- Do not blindly translate Figma absolute coordinates into `Stack` + `Positioned`.
- Prefer normal Flutter layout primitives for most UI: `Column`, `Row`, `Padding`, `SizedBox`, `Spacer`, `Expanded`, `Flexible`, `Align`, `Center`, `AspectRatio`, `FractionallySizedBox`, `ConstrainedBox`, `GridView`, and `ListView`.
- Use `Stack` / `Positioned` only for real overlap or anchored decorative layers, not for ordinary vertical content, buttons, headers, forms, cards, or lists.
- For new Figma implementation work, do not create viewport scaling helpers or multiply Figma values by a `scale` factor. Use the numeric spacing, size, radius, and font values from Figma directly unless a responsive constraint is explicitly needed.
- Icons in Figma-driven screens must come from stable local Figma-exported SVG/icon assets. Do not substitute Material icons unless the Figma node does not provide an icon and the user approves the substitution.
- Do not introduce new `_designWidth`, `_designHeight`, or `constraints.maxWidth / 390` style canvas scaling for Figma screens.
- Avoid fixed width/height unless the element is intentionally fixed, such as an icon, avatar, toolbar button, or asset with a known ratio.
- Avoid fixed heights and fixed aspect ratios for containers with text or dynamic content unless the design truly requires clipping. Use intrinsic layout, padding, min/max constraints, `Flexible`/`Expanded`, and scrollable content where appropriate so localization, font metrics, and backend data do not cause overflow.
- New screen implementations should size and space from the actual device constraints, safe-area padding, and content constraints.
- Select/dropdown inputs should open a bottom sheet by default unless the user or design explicitly asks for another interaction.

## Latest Student / Parent Home And Profile Updates

- Non-teacher Home was rebuilt from Numinumi Figma node `2238:1629` for both `ProfileRole.student` and `ProfileRole.parent`.
- Teacher home remains unchanged; non-teacher bottom navigation destinations remain unchanged.
- The new student/parent Home includes:
  - top active-profile header using `ProfileAvatarImage`
  - `BÀI TẬP` hero card
  - pending invitation preview
  - joined-classroom preview grid
  - always-visible join-classroom CTA for both student and parent, even when there are no classes
  - pushed full-screen `Xem tất cả` screens for pending invitations and joined classrooms
- Local Figma assets added for the student/parent Home under `assets/images/student_parent_home_*`.
- Practice and assessment entry points still open `GradeSelectionScreen` with the existing quiz purpose constants.
- Quiz submission now forwards `profile_id`:
  - `SubmitQuizRequest.profileId`
  - `QuizService.submitQuiz(profileId: ...)`
  - assessment/test screens pass the active profile id through grade selection and submit
- Parent classroom guard behavior:
  - if active profile is parent and there are no student profiles, show the no-student Figma dialog from node `2331:4075`
  - if active profile is parent and student profiles exist, show an alert that classroom features require switching to a student profile
  - the switch alert primary action opens profile selection; it does not silently navigate without warning
  - classroom actions return `false` after the parent guard, so the classroom action does not continue until a student profile is active
- After creating a student profile, the app now writes that new student profile id to `ActiveProfileSession`, even if it is not the first profile.
- Parent profile management UI was rebuilt from Numinumi Figma node `29:137`:
  - parent info card
  - children count header
  - child cards with select/edit/delete/copy behavior
  - add button remains available
  - child selection uses the existing `onSelect` active-profile flow
- Parent update profile form is intentionally reduced to avatar and name only.
  - parent edit skips school/program/grade/id option loading
  - parent validation requires only name
  - parent update submits `profile_id`, `name`, and selected `avatar_key`
- Profile/avatar rendering rule was tightened:
  - avatar UI must check and reuse `ProfileAvatarImage` before custom rendering
  - parent profile card avatar now always uses `ProfileAvatarImage`, including fallback state
  - custom parent avatar fallback SVG was removed
- Figma SVG export rule was added:
  - every exported/downloaded Figma SVG must be inspected before use
  - normalize CSS variable fills, percentage-only dimensions, inline styles, and other markup that can render blank in `flutter_svg`
  - prefer concrete dimensions, valid `viewBox`, and explicit colors
- Parent profile management local SVG assets added under `assets/images/parent_profile_manage_*`.
- Parent no-student dialog asset added:
  - `assets/images/parent_no_student_mascot.png`
- New localized strings were added for:
  - parent no-student dialog
  - parent switch-to-student alert
  - parent profile management section labels
  - student invitation/classroom view-all and empty invitation states
- Recent validation after the latest parent/student work:
  - `dart format ...` passed for touched files
  - `flutter analyze` passed with `No issues found`
  - `flutter test` was not run, following project guidance

## Test Plan

- Run `dart run build_runner build --delete-conflicting-outputs` after adding classroom models.
- Run `dart format lib test`.
- Run `flutter analyze`.
- Do not run `flutter test` unless explicitly requested.
- After changing json-serializable models, run `dart run build_runner build --delete-conflicting-outputs`.
- Manual checks:
  - Teacher profile shows Teacher bottom bar with only Home, Report, Settings.
  - Student profile still shows current Student UI and 4-tab bottom bar.
  - No-class Teacher Home displays create CTA.
  - With-class Teacher Home displays class grid.
  - Teacher Home class cards display backend `student_count`; API responses like `student_count: 0` and `member_count: 1` should show 0 students.
  - Create class sends multipart body with `program_ids` for all selected programs, includes `school_id`, and does not send `program_id`.
  - Class list refreshes after successful create.
  - Class detail loads with `profile_id` query param.
  - Class detail reads and copies `classroom_code`; legacy `invite_code` should only be a fallback.
  - Class detail student count uses `student_count`, not `member_count`.
  - Class detail request count loads from `/classrooms/join-requests/list`.
  - Class detail `Quản lý thành viên` card opens Manage Members screen.
  - Manage Members loads join requests from `/classrooms/join-requests/list`.
  - Manage Members accept/reject buttons call `/classrooms/join-requests/approve` and `/classrooms/join-requests/reject`, then refresh.
  - Manage Members loads active students from `/classrooms/members/list` with `role: STUDENT` and `status: ACTIVE`.
  - Manage Members active students display name/avatar/profile id from `member_profile`.
  - Manage Members join requests display name/avatar/profile id from `requester`.
  - Manage Members add button opens the student search bottom sheet.
  - Student homepage loads joined classes from `/classrooms/my-joined`, not `/classrooms/list`.
  - Student join search calls `/classrooms/list` with `profile_id` and `search`.
  - Student join action is blocked unless classroom `relationship` is `NONE`.
  - Student search calls `/profiles/list` with `search`, supports multi-select, and send-invite calls `/classrooms/invitations/send`.
  - Teacher send-invite shows a blocking loading overlay until the API call completes.
  - Student pending invitations load from `/classrooms/invitations/my-pending`.
  - Student invitation accept/reject calls `/classrooms/invitations/accept` or `/classrooms/invitations/reject` with `invitee_profile_id`, `inviter_profile_id`, and `classroom_id`.
  - Login/signup OTP preview appears inline on the OTP entry screen, not as a dialog.
  - Profile avatar sheet shows all nine avatar options, scrolls without overflow, and sends `avatar_key` on save.
  - Student profile does not show a document type selector and submits `id_type: MOET`.
  - Teacher profile can save with neither document type nor teacher ID, can save with both, and errors when only one is filled.
  - Profile avatars use the same shared fallback/background across settings, profile list, home, and teacher headers.
  - Settings landing shows the active profile name/avatar and switch icon opens profile selection.
  - Fresh signup with no local passcode shows the Create PIN screen; Skip reaches Home.
  - OTP login with no local passcode shows the Create PIN screen; successful confirmation reaches Home.
  - App restart/session restore with a saved passcode requires PIN unlock before Home.
  - Wrong PIN on unlock/verify shows an inline error and does not enter Home or modify passcode settings.
  - Settings can create a passcode for the current user.
  - Settings can change a passcode only after verifying the current passcode.
  - Settings can remove a passcode only after verifying the current passcode.
  - Logout does not delete the local passcode; logging in again as the same user does not prompt setup.
- Safe areas work on iPhone with notch and home indicator.
- Long class names truncate without overflow.
- Full classroom codes display without ellipsis in the detail info card.
- New Figma screens do not use positional layout unless overlap is actually required.

## Open Decisions / Assumptions

- Report tab v1 is a placeholder because no report design/API was provided.
- Classroom response shape is unknown; implement defensive json-serializable parsing matching existing envelope style.
- `max_members` defaults to `50`.
- Create-class image upload is optional.
- Teacher class creation uses the active teacher profile id, not user id.
- Teacher UI should keep the app’s Andika typography while visually matching Figma colors, spacing, cards, and bottom dock.
