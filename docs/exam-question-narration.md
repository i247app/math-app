# Kindergarten question narration experiment

`ExamAttemptScreen` reads natural-language `question_text` automatically once
when an eligible question becomes current. The speaker button replays the same
text on text and image cards. Selecting answers and image URL refreshes do not
repeat narration. Returning to a previously visited question reads it again.

Eligibility uses `question_grade` first, then the generated paper's `grade`.
Only grade `0` is eligible. Unknown grades are not treated as kindergarten.
This applies to assessment, grade exams and practice in the shared attempt
screen; review screens do not start narration.

Kindergarten cards always show the speaker icon. On cards without an image,
the icon sits at the upper left with the content below, using the full width.
Image cards keep the icon beside the written prompt above the image. Other
grades do not show it.

Written prompts are sent to TTS unchanged apart from whitespace. Prompts
containing emoji or LaTeX, empty prompts and content consisting only of numbers
or symbols are blocked for both autoplay and replay; the speaker is disabled.
There is no substitute narration for blocked content. The app does not count
objects, calculate expressions, read answer options or infer a question from
its image. The API should supply a full spoken
instruction such as `Con hãy đếm số quả táo trong hình.`. If display content and
spoken wording differ, a future API field such as `question_speech_text` can
provide explicit narration.

Speech uses official `flutter_tts` 4.2.5, with rate `0.4` on the platform's rate
scale. Vietnamese diacritics select `vi-VN`; otherwise the language follows the
app/API request language (`vi-VN` or `en-US`). The API currently supplies no
separate question-language field. Availability is checked before playback, so
an unavailable language does not silently fall back to an unrelated voice.
Automatic failures leave the exam usable. A failed manual replay shows a
localized message suggesting checking device speech voices. Voice quality and
offline availability depend on the device's installed speech engine/voices.

New questions replace pending narration. Generation, submission, the exit or
unanswered-submission dialog, app background/inactivity and disposal stop it.
Returning from the background does not automatically repeat a prompt; replay
remains available. The service serializes native calls and invalidates obsolete
requests, including requests still waiting for voice initialization.

Android declares the TTS service visibility query in the manifest. Its native
plugin uses the reviewed built-in Kotlin compatibility patch documented in
`third_party/android_gradle/README.md`; iOS and Dart resolve upstream normally.
There is no server-side audio generation or added TTS API key.

## Device checks

1. Open a grade-0 paper with full Vietnamese instructions. Check first-question
   playback, comfortable pace, pronunciation and the replay button.
2. Select an answer, jump quickly between questions, revisit one, and finish a
   set. Check that old or overlapping prompts do not continue.
3. Mix `question_grade: 0` and `question_grade: 1` in a paper. Only the grade-0
   question should speak. Check absent question grade falls back to paper grade.
4. Check both text and image cards, including long prompts and small screens.
5. Open/cancel the exit dialog, submit, navigate away, lock the device, and
   background/resume the app while speech is starting and while it is playing.
6. Check an English paper using the English app/API language, a missing
   Vietnamese voice, offline mode, Bluetooth, and iOS silent-switch behavior.

Automated tests cover grade propagation and precedence, conservative text
eligibility, language setup, engine failures, cancellation during preparation,
replacement, auto-read deduplication, replay, navigation, background/disposal,
the exit dialog, and keeping the exam usable when a voice is unavailable.
Audible pronunciation and iOS native compilation require device/platform checks.

References: [flutter_tts documentation](https://pub.dev/packages/flutter_tts),
[upstream source](https://github.com/dlutton/flutter_tts).
