# Phone country recognition audit

Verified on 2026-11-09. Scope: Vietnam human-to-human mobile input and NANP
input in the shared login/signup field. This is a country hint, not a live
telephone-number ownership, assignment or reachability lookup.

## Sources and findings

- [Consolidated numbering plan 04/VBHN-BTTTT, 31 March 2022](https://thuvienphapluat.vn/van-ban/Cong-nghe-thong-tin/Van-ban-hop-nhat-04-VBHN-BTTTT-2022-Thong-tu-kho-so-vien-thong-510296.aspx),
  appendices 1 and 2: H2H network codes 30–59 and 70–99, with seven subscriber
  digits. The [official Gazette record](https://congbao.chinhphu.vn/van-ban/van-ban-hop-nhat-so-04-vbhn-btttt-36965/40179.htm)
  identifies the consolidated instrument.
- [Decision 16/2021/QD-TTg, appendix I, section 2](https://vbpl.vn/FileData/TW/Lists/vbpq/Attachments/147136/VanBanGoc_469229.pdf)
  explicitly lists H2H code family 7A with A=2–5 among specially structured
  resources. This includes network code 74. It is evidence of a numbering
  resource, not evidence that a carrier currently operates 074 numbers.
- The [2018 Ministry notification published by ITU](https://www.ituob.org/issues/1150-en/)
  documents conversion to 070, 076, 077, 078 and 079. This historical conversion
  list is not the full numbering plan and cannot establish that 074 is banned.
- [Google libphonenumber Vietnam mobile metadata](https://github.com/google/libphonenumber/blob/master/resources/PhoneNumberMetadata.xml)
  has narrower supported ranges than the plan. It does not recognize 74.
  No current official carrier assignment for 074 was established in this audit.
- [The 2026 planning-process update](https://mst.gov.vn/quy-dinh-moi-ve-quy-hoach-kho-so-vien-thong-va-tai-nguyen-internet-197260812230618755.htm)
  describes Circular 34/2026/TT-BKHCN and the approval/publication process.
  It is not a carrier assignment list and does not establish that 074 is in use.

The previous UI required the strict metadata check to pass before showing a
country flag. Thus a missing Vietnam flag could mean an unsupported prefix,
not a different country. It could also reflect an explicit manual US selection.

## Application policy

1. Preserve the original input while typing. Email takes priority when `@`
   appears; numeric usernames are never truncated or reformatted. The app's
   email policy requires the first character to be an ASCII letter (`a-z` or
   `A-Z`). A numeric-leading email stays intact but is rejected on blur/submit
   with a specific first-letter error. Digits after the initial letter are valid.
   This is an app policy, not a universal email syntax or provider rule.
2. Recognize existing supported phone ranges first. Otherwise, any complete
   nine-digit national input starting with 1–9 defaults to a Vietnam country
   hint when no different country was explicitly chosen. This is a product
   heuristic for the two-country UI, not a claim about the numbering plan.
   Accept equivalent preview forms with a domestic zero or `+84`/`84`.
3. Keep country hints separate from strict validation. `747372827` and
   `688777777` both show Vietnam as a candidate, but remain outside the strict
   supported mobile ranges. Neither triggers backend availability/OTP requests.
4. Explicit country codes and manual dropdown choices retain their meaning.
   A `+1` prefix or a deliberate US selection must not silently become Vietnam
   merely because the remaining number has nine digits.
5. Reconsider automatic hints on each edit, including the transition from a
   nine-digit Vietnam candidate to a ten-digit NANP candidate. Never persist
   a country choice across app launches.

Nine-digit strings beginning with zero, incomplete numbers and strings
containing email characters do not receive this automatic Vietnam hint.
The flag can now appear for prefixes outside the H2H plan, such as 68: it
is only a default suggestion, with strict validation still performed separately.
Existing ranges already recognized by the supported metadata remain compatible.

Tests cover all 90 nonzero-leading two-digit prefixes with multiple suffixes
and national/international representations, as well as strict rejection,
explicit/manual country selection, email transitions and raw-text preservation.
