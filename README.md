# FakeDiia — фейкова Дія для iOS (дизайн 4.38)

Жартівлива програма за референсом нової Дії (версія 4.38.5): живий градієнт,
glass-карточки документів, п'ять табів (Стрічка / Документи / Дія.AI / Сервіси /
Меню), QR, редагування даних. Не є документом, нічого не видає — pure prank UI.

## Склад

- iOS 17+, SwiftUI, без сторонніх залежностей
- XcodeGen для генерації проєкту
- Дані та фото зберігаються локально (UserDefaults + файл у Documents)

## Збірка в хмарі через GitHub Actions (шлях для Windows)

Корінь репозиторію = вміст цієї папки (поруч із `project.yml` лежить
`.github/workflows/build.yml`). У Actions є macOS-раннери, збірка безкоштовна.

1. Створи публічний репозиторій на GitHub.
2. Запуш проєкт:
   ```
   git init
   git add .
   git commit -m "fake diia"
   git remote add origin https://github.com/<you>/fakediia.git
   git push -u origin main
   ```
3. Actions → Build iOS → дочекайся зеленої галочки (хвилин 5).
4. У розділі Artifacts скачай `FakeDiia-ipa` → розпакуй, всередині `FakeDiia.ipa`.
   Збирається БЕЗ підпису — підпис робиться локально на Windows.

## Установка на айфон із Windows (Sideloadly)

1. Постав класичний iTunes із apple.com (потрібен для USB-драйверів, не зі
   Microsoft Store).
2. Постав Sideloadly: sideloadly.io.
3. Підключи айфон кабелем, на телефоні тапни «Довірити».
4. У Sideloadly перетягни `FakeDiia.ipa`, введи свій Apple ID і пароль, Start.
5. Після установки: Налаштування → Основні → VPN і керування пристроєм →
   довіряй профілю зі своєю поштою Apple ID.
6. Підпис із безкоштовним Apple ID живе 7 днів; переустановка тим самим
   способом оновлює термін. AltStore вміє оновлювати підпис автоматично в тій
   самій Wi-Fi-мережі.

Платний Apple Developer ($99/рік) знімає обидва обмеження: підпис на рік і
TestFlight. Для пранку — не потрібно.

## Локальна збірка (якщо з'явиться Mac)

```bash
brew install xcodegen
cd FakeDiia
xcodegen generate
open FakeDiia.xcodeproj
```

Signing & Capabilities → Team (безкоштовний Apple ID підійде), підключити
айфон кабелем, Run (⌘R).

## Файли

- `App/DiiaApp.swift` — точка входу, сплеш поверх основного UI
- `Core/Theme.swift` — градієнт фону, glass-поверхня, палітра, формати дат
- `Core/DocumentModels.swift` — моделі профіля і чотирьох документів, генератори номерів
- `Core/ProfileStore.swift` — стан, персист, збереження фото
- `Core/QRCodeView.swift` — QR через CoreImage (у коді — лише текст, який ти сам і ввів)
- `Screens/SplashView.swift` — градієнт + тризуб + міністерство
- `Screens/MainTabView.swift` — 5 табів + зелений тост-банер нагорі
- `Screens/FeedScreen.swift` — «Привіт, Ім'я 👋», карусель повідомлень, промо «Незламність», швидкі кнопки
- `Screens/DocumentsScreen.swift` — карусель документів, крапки, аркуш QR з вибором документа
- `Screens/DocumentCard.swift` — 4 glass-карточки (паспорт, водій зі смугою, РНОКПП, студентський), зелена смуга «Документ оновлено», копіювання номера, рендер в UIImage
- `Screens/DocumentDetailSheet.swift` — QR-аркуш, ShareSheet
- `Screens/AiScreen.swift` — чат Дія.AI з локальними відповідями
- `Screens/ServicesScreen.swift` — пошук + сітка сервісів з чорними кружками, під-екрани «Водіеві»/«Розваги»
- `Screens/MenuScreen.swift` — меню секціями, Повідомлення, Історія підписань, Пристрої, редактор даних
- `Assets.xcassets` — іконка (чорна плитка «дія»), тризуб з альфою, акцентний колір
- `fakediia-web/` — веб-версія (PWA) як запасний варіант, що працює без збірки взагалі

## Генерація ассетів

`resources/make_assets.py` — робить іконку з Pillow і альфу тризубу з
`resources/tryzub_raw.png` (OpenCV). Ассети вже згенеровані й лежать у
`Assets.xcassets`, скрипт потрібен лише якщо захочеш перегенерувати.
