# Hiddify Reset + Setup

یک دبل‌کلیک: Hiddify ویندوز را کامل ریست می‌کند و تنظیمات پیشنهادی را اعمال می‌کند.
One double-click: fully resets Hiddify on Windows and applies a known-good config.

## چه می‌کند / What it does
1. Finds `Hiddify.exe` (Program Files, then other locations)
2. Stops Hiddify / sing-box and removes leftover TUN adapters (fixes `set ipv6 address: The object already exists`)
3. **Wipes all Hiddify data** (profiles, settings, cache)
4. Writes settings: VPN (TUN) mode · Region = Iran · Direct DNS `178.22.122.100` · Remote DNS `1.1.1.1` · IPv4 only · DNS routing · strict route
5. Creates a desktop shortcut and starts Hiddify

نتیجه: ترافیک ایران مستقیم، بقیه از VPN؛ WebRTC و DNS لو نمی‌رود.

## استفاده / Usage
Download `Hiddify-Reset-Setup.bat`, double-click, accept the UAC prompt, then add your own profile in Hiddify.

> ⚠️ **All existing Hiddify profiles are deleted.** Export them first if you need them.
> Hiddify must already be installed. No servers or credentials are included.

## License
MIT