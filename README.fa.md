# Flux v2 — مهارت سه‌مرحله‌ای «معمار – کارگر – ناظر» برای Antigravity

[![License: Apache-2.0](https://img.shields.io/badge/License-Apache%202.0-blue.svg)](LICENSE)
[![Antigravity Skill](https://img.shields.io/badge/Antigravity-Skill-0A0A0A.svg)](SKILL.md)

**نویسنده:** [XioDr](https://github.com/XioDr) · [AlacrityAgency](https://github.com/AlacrityAgency) · **مجوز:** [Apache-2.0](LICENSE) · **[English README](README.md)**

مهارت **`flux_v2`** الگوی مهندسی سه‌گانه **«معمار – کارگر – ناظر» (Architect – Worker – Advisor)** را به‌صورت کاملاً بومی روی ابزارها و مدل‌های داخلی Antigravity و بدون نیاز به API Key بیرونی اجرا می‌کند:

1. **فاز ۱ — معمار (`Gemini Neon` در مرورگر داخلی):**
   زمینه پروژه را جمع‌آوری می‌کند، تب باز `gemini.google.com` (مدل **Neon**) را پیدا یا باز می‌کند، پرامپت ساختاریافته را می‌فرستد، نقشه فنی و مراحل خرد اجرایی را استخراج می‌کند و تب مرورگر را برای پرسش‌های تکمیلی فعال نگه می‌دارد.
2. **فاز ۲ — کارگر (`Antigravity` / `gemini-3.8-flash-high`):**
   - اگر گفتگوی اصلی روی **Gemini 3.8 Flash** باشد، مستقیماً نقش کارگر را انجام می‌دهد.
   - اگر گفتگوی اصلی روی **Gemini 4 Hydrogen** (یا مدل دیگری) باشد، یک کارگر `swarm` با مدل `gemini-3.8-flash-high` می‌سازد.
   کدها و فایل‌ها را می‌نویسد، تست‌ها و دستورات بررسی را اجرا می‌کند و گزارش مستند (`git diff` + خروجی واقعی تست‌ها) تهیه می‌کند.
3. **فاز ۳ — ناظر (`Gemini 4 Hydrogen` / `gemini-4-hydrogen-xhigh`):**
   فایل‌های واقعی، `git diff` و شواهد تست را با نقشه Neon ممیزی می‌کند و تا سقف ۳ دور اصلاح (`CHANGES_REQUIRED` → رفع ایراد و تست مجدد → `APPROVED`) بر کار نظارت دارد.

---

## نصب سریع

### روش ۱ — کلون مستقیم در پوشه اسکیل‌های Antigravity

**ویندوز (PowerShell):**
```powershell
git clone https://github.com/AlacrityAgency/flux_v2.git "$HOME\.gemini\config\skills\flux_v2"
```

**لینوکس / مک:**
```bash
git clone https://github.com/AlacrityAgency/flux_v2.git ~/.gemini/config/skills/flux_v2
```

### روش ۲ — کلون و اجرای اسکریپت نصب

```powershell
git clone https://github.com/AlacrityAgency/flux_v2.git
cd flux_v2
.\install.ps1
```

---

## نحوه استفاده

پس از نصب، کافی است در Antigravity بنویسید:

> «با `flux_v2` این تسک را انجام بده: ...»
