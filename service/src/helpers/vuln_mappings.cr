module VulnMappings
  TYPE_MAPPING = {
    "rce"                  => "Удалённое выполнение кода (RCE)",
    "sqli"                 => "SQL-инъекция (SQL Injection)",
    "xss"                  => "Межсайтовый скриптинг (XSS)",
    "lfi"                  => "Локальное включение файлов (LFI)",
    "rfi"                  => "Удалённое включение файлов (RFI)",
    "xxe"                  => "XML External Entity (XXE)",
    "idor"                 => "Неправильная проверка доступа (IDOR)",
    "ssti"                 => "Инъекция в шаблон (SSTI)",
    "buffer_overflow"      => "Переполнение буфера",
    "heap_overflow"        => "Переполнение кучи",
    "format_string"        => "Атака с форматом строки",
    "command_injection"    => "Инъекция команд",
    "privilege_escalation" => "Эскалация привилегий",
    "auth_bypass"          => "Обход аутентификации",
    "logic_bug"            => "Логическая ошибка",
    "crypto_attack"        => "Криптографическая атака",
    "side_channel"         => "Побочный канал",
    "hardware_exploit"     => "Атака на железо",
    "iot_exploit"          => "Уязвимость в IoT-устройствах",
    "smart_contract"       => "Уязвимость в смарт-контрактах",
    "deepfake_hack"        => "Атака через Deepfake",
  } of String => String

  PLATFORM_MAPPING = {
    "windows"    => "Microsoft Windows",
    "linux"      => "Linux (серв. дистрибутивы)",
    "macos"      => "Apple macOS",
    "android"    => "Google Android",
    "ios"        => "Apple iOS",
    "web"        => "Веб-приложения (браузер)",
    "cloud"      => "Облачные сервисы",
    "scada"      => "SCADA/ICS системы",
    "iot"        => "Интернет вещей (IoT)",
    "blockchain" => "Блокчейн и крипта",
    "hypervisor" => "Виртуализация (Hyper-V, VMware)",
    "network"    => "Сетевые устройства (роутеры)",
    "firmware"   => "Прошивки (BIOS, UEFI, Embedded)",
    "game"       => "Игры и игровые движки",
    "drone"      => "Беспилотники (drones)",
    "automotive" => "Автомобили (ECU, CAN Bus)",
  } of String => String

  TYPE_ICONS = {
    "rce"                  => "💥",  # Remote Code Execution
    "sqli"                 => "💾",  # SQL
    "xss"                  => "⚠️", # Script
    "lfi"                  => "📂",  # File system
    "rfi"                  => "🌐",  # Remote web include
    "xxe"                  => "📄",  # XML file
    "idor"                 => "🔐",  # Access control
    "ssti"                 => "📝",  # Template injection
    "buffer_overflow"      => "🔒",  # Memory error
    "heap_overflow"        => "🧠",  # Heap/memory
    "format_string"        => "🔤",  # Format input
    "command_injection"    => "💣",  # Shell
    "privilege_escalation" => "⬆️", # Privilege
    "auth_bypass"          => "🚪",  # Login bypass
    "logic_bug"            => "🧩",  # Logic mistake
    "crypto_attack"        => "🧬",  # Crypto
    "side_channel"         => "🎧",  # Leak
    "hardware_exploit"     => "🔧",  # Low-level
    "iot_exploit"          => "📡",  # IoT
    "smart_contract"       => "📜",  # Blockchain
    "deepfake_hack"        => "🌀",  # Face spoofing
  } of String => String

  PLATFORM_ICONS = {
    "windows"    => "🪟",  # Windows 11 emoji
    "linux"      => "🐧",  # Tux
    "macos"      => "🍎",  # Apple
    "android"    => "🤖",  # Android
    "ios"        => "📱",  # Mobile
    "web"        => "🌐",  # Browser
    "cloud"      => "☁️", # Cloud infra
    "scada"      => "⚙️", # Industrial
    "iot"        => "📡",  # Connected device
    "blockchain" => "⛓️", # Chain
    "hypervisor" => "🧱",  # VM layer
    "network"    => "🌍",  # Routing / IP
    "firmware"   => "💾",  # Flash
    "game"       => "🎮",  # Gaming
    "drone"      => "🛸",  # Drone/UFO
    "automotive" => "🚗",  # Car systems
  } of String => String
end
