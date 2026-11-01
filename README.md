# Sudoku – Flutter Android projesi

Bu paket Flutter kaynak kodudur; APK değildir.

## Bu sürümde eklenen oyun altyapısı
- Geçerli Sudoku çözüm tablosu üretimi; her ipucu çıkarımından sonra çözüm sayısını kontrol ederek tek çözümlü bulmaca oluşturma
- Günlük Sudoku için tarihe bağlı, aynı gün aynı tek çözümlü bulmaca; tamamlanan gün takvimi ve günlük/en uzun seri hesabı
- Sayı girme, silme, not işaretleme, geri alma ve gerçek çözümden ipucu
- Uygulama yeniden açıldığında oyun durumunu geri yükleyen otomatik kayıt
- Tamamlanma kontrolü ve başarı ekranı
- Kalıcı tamamlanan oyun, toplam süre ve zorluk bazında başarı istatistikleri; kalıcı ayar tercihleri ve istatistik sıfırlama

## Android'de çalıştırma
Flutter SDK ve Android Studio kurulu bir bilgisayarda proje klasöründe:

```bash
flutter pub get
flutter run
```

APK üretmek için:

```bash
flutter build apk --release
```

APK çıktısı: `build/app/outputs/flutter-apk/app-release.apk`

## Önemli
Bu çalışma ortamında Flutter/Dart SDK bulunmadığından proje burada derlenemedi veya Android cihazda test edilemedi. İlk çalıştırmadan önce `flutter analyze` ve `flutter test` ile kontrol edilmesi önerilir.

## Son kontrol notu
- Yanlış sayı girişi artık çözüm tablosuna göre hata sayılır ve hücre kırmızı çerçeveyle gösterilir.
- Silme ve ipucu işlemleri de geri alma geçmişine eklenir; geri alma hata sayısını ve hücre notlarını da geri yükler.
- Bu ortamda Flutter/Dart SDK bulunmadığı için Android derlemesi çalıştırılamadı. İlk gerçek cihaz doğrulaması için aşağıdaki komutlar gereklidir:
  `flutter analyze`, `flutter test`, `flutter build apk --release`.

## GitHub Actions ile bulut APK derlemesi
`.github/workflows/android-apk.yml` dosyası, `main` dalına gönderilen her push işleminde Android APK derlemesini başlatır. GitHub deposunda Actions etkin olmalıdır. Derleme başarılı olursa `sudoku-release-apk` adlı artifact oluşur ve Actions çalışma sayfasından indirilebilir.
