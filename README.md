# Mood2Go — Moduna Göre

Mood2Go, kullanıcıların ruh hâline, ilgi alanlarına ve kişisel tercihlerine göre mekan ve aktivite keşfetmesini sağlayan bir Flutter uygulamasıdır. Kullanıcılar bireysel öneriler alabilir veya arkadaşlarıyla grup kurarak herkesin tercihine uygun ortak bir plan oluşturabilir.

Bu proje, üç kişilik bir ekip tarafından dönem projesi olarak geliştirilmektedir.

## Projenin amacı

Bir grup arkadaşın “Nereye gidelim?” veya “Ne yapalım?” sorusuna hızlı ve kişiselleştirilmiş bir cevap vermek amaçlanmaktadır. Uygulama, kullanıcılardan topladığı tercihleri değerlendirerek uygun mekanları ve aktiviteleri sıralayacaktır.

## Planlanan özellikler

- Kullanıcı kaydı ve giriş sistemi
- Kullanıcı profili ve tercihleri
- Ruh hâli ve ilgi alanına göre öneriler
- Mekan ve aktivite listeleme
- Mekanların menü, tarihçe ve şef bilgileri
- Ürünlerin içerik ve alerjen bilgileri
- Grup oluşturma ve arkadaş davet etme
- Grup üyelerinin ortak tercihlerine göre öneri üretme
- Jev ile seçenekleri değerlendirme ve sıralama
- Yemekler ve mekanlar hakkında soruları yanıtlayan chatbot
- Uygulama içinden örnek sipariş oluşturma

## Şu anda tamamlananlar

- Karşılama ekranı
- Giriş ekranı
- Kayıt ekranı
- Form alanı kontrolleri
- Şifreyi gösterme ve gizleme
- GoRouter ile sayfalar arası geçiş
- Beyaz ve pastel yeşil renklerden oluşan temel tasarım

## Kullanılan teknolojiler

| Teknoloji | Kullanım amacı |
| --- | --- |
| Flutter | Android, iOS ve web arayüzü |
| Dart | Uygulama geliştirme dili |
| GoRouter | Sayfalar arası yönlendirme |
| Supabase | Planlanan kullanıcı, veritabanı ve dosya işlemleri |
| Jev | Planlanan kişisel ve grup önerilerinin sıralanması |

## Projeyi çalıştırma

### Gereksinimler

- Flutter SDK
- Dart SDK
- Chrome, Android emülatörü veya iOS simülatörü

Kurulumun doğru olduğunu kontrol etmek için:

```bash
flutter doctor
```

### Kurulum

Projeyi klonladıktan sonra proje klasörüne girin:

```bash
cd mood2go
```

Paketleri yükleyin:

```bash
flutter pub get
```

Uygulamayı Chrome üzerinde çalıştırın:

```bash
flutter run -d chrome
```

Bağlı cihazları görüntülemek için:

```bash
flutter devices
```

## Klasör yapısı

```text
lib/
├── main.dart
└── pages/
    ├── login_page.dart
    └── register_page.dart
```

Proje büyüdükçe sayfalar, ortak bileşenler, modeller ve servisler ayrı klasörlere taşınacaktır.

## Geliştirme yol haritası

- [x] Flutter projesini oluşturma
- [x] Karşılama ekranı
- [x] Giriş ve kayıt arayüzleri
- [x] Temel form kontrolleri
- [x] GoRouter kurulumu
- [ ] Supabase bağlantısı
- [ ] Gerçek kullanıcı kaydı ve girişi
- [ ] Kullanıcı tercihleri anketi
- [ ] Ana sayfa ve keşfet ekranı
- [ ] Mekan ve aktivite detayları
- [ ] Grup oluşturma ve davet sistemi
- [ ] Jev öneri sistemi
- [ ] Chatbot
- [ ] Örnek sipariş akışı
- [ ] Testler ve dönem sonu sunumu

## Ekip

Proje üç kişilik bir öğrenci ekibi tarafından geliştirilmektedir. Görev dağılımı geliştirme sürecinde arayüz, veri ve öneri sistemi başlıklarına göre yapılacaktır.

## Proje durumu

Proje aktif geliştirme aşamasındadır. İlk kullanıcı arayüzleri tamamlanmış, gerçek üyelik sistemi için Supabase entegrasyonuna başlanmıştır.
