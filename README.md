# TodoApp

Bu proje, Flutter kullanarak geliştirilmiş bir Todo uygulamasıdır. Kullanıcılar görev ekleyebilir, güncelleyebilir, silebilir ve görevlerini tamamlanmış/ tamamlanmamış olarak işaretleyebilirler. Uygulama Firebase kullanılarak kullanıcı doğrulaması ve veritabanı yönetimi yapmaktadır.

## Özellikler

- Görev Ekleme: Kullanıcılar kolayca yeni görevler ekleyebilir.
- Görev Düzenleme: Eklenen görevleri düzenleme ve güncelleme.
- Görev Silme: Tamamlanan veya gereksiz görevleri silme.
- Görevler İçin Etiketleme: Görevleri kategorize ederek daha iyi organize etme.
- Arama Özelliği: Görevler arasında hızlıca arama yapma.
- Kullanıcı Dostu Arayüz: Basit ve anlaşılır bir kullanıcı deneyimi.
- Veri Senkronizasyonu: Tüm görevlerinizi bulutta saklama ve senkronize etme.

## Kurulum

Bu proje Flutter kullanılarak geliştirilmiştir. Projeyi kendi bilgisayarınızda çalıştırmak için aşağıdaki adımları takip edebilirsiniz:

1. **Gerekli bağımlılıkları yükleyin:**

    ```sh
    flutter pub get
    ```

2. **Firebase yapılandırmasını yapın:**

    Firebase projenizi oluşturun ve `google-services.json` dosyasını `android/app` dizinine yerleştirin.

3. **Uygulamayı çalıştırın:**

    ```sh
    flutter run
    ```

## Ekran Görüntüleri
### Giriş Ekranı
![Ana Ekran](https://github.com/ozcann159/TodoApp/blob/main/assets/images/1.png )
*Giriş ekranı, kullanıcıların uygulamaya kolayca giriş yapmasını sağlar.*
### Kayıt Ekranı
![Kayıt Ekranı](https://github.com/ozcann159/TodoApp/blob/main/assets/images/2.png)
*Yeni kullanıcıların hesap oluşturmasına olanak tanır.*
### Görev Ekleme
![Görev Ekleme](https://github.com/ozcann159/TodoApp/blob/main/assets/images/4.png)
*Yeni görev ekleyin ve işlerinizi düzenleyin.*
### Todo Listesi
![Görev Detayı](https://github.com/ozcann159/TodoApp/blob/main/assets/images/3.png)
*Todoların tamamlanmış ya da tamamlanmamış olarak listelenmesi*



## Kullanım

1. Uygulamayı çalıştırdığınızda, giriş yaparak veya yeni bir hesap oluşturarak uygulamaya giriş yapabilirsiniz.
2. Görev eklemek için "Yeni Todo Ekle" butonuna tıklayın.
3. Görevlerinizi düzenlemek veya silmek için ilgili görevi seçin.

## Katkıda Bulunanlar

- [Elif Özcan](https://github.com/elifozcan) - Proje sahibi ve geliştirici

## Lisans

Bu proje MIT Lisansı ile lisanslanmıştır. Ayrıntılar için [LICENSE](LICENSE) dosyasına bakabilirsiniz.
