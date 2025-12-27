# 🚀 دليل سريع - ns-O-RAN-flexric

## خطوات التنزيل والتشغيل (للمرة الأولى)

---

## 📥 الخطوة 1: تنزيل المشروع

```bash
git clone --recurse-submodules https://github.com/Orange-OpenSource/ns-O-RAN-flexric.git
cd ns-O-RAN-flexric
```

**مهم:** استخدم `--recurse-submodules` عشان ينزل كل الملفات المطلوبة.

---

## ⚙️ الخطوة 2: الإعداد (مرة واحدة فقط)

```bash
bash scripts/00-setup-all.sh
```

**هذا السكريبت سيعمل:**
- ✅ تثبيت جميع المتطلبات
- ✅ تثبيت FlexRIC
- ✅ بناء e2sim
- ✅ بناء ns-3

**⏱️ الوقت المتوقع:** 30-60 دقيقة (خاصة بناء ns-3)

**💡 نصيحة:** اتركه يعمل وارجع بعد ساعة.

---

## ▶️ الخطوة 3: تشغيل النظام

```bash
bash scripts/12-start-all.sh
```

**بعد التشغيل:**
- 📊 افتح المتصفح على: `http://YOUR_IP:8000` (RIC-TaaP Studio)
- 📈 Grafana على: `http://YOUR_IP:3000`

**💡 لمعرفة IP جهازك:**
```bash
hostname -I
```

---

## 🛑 إيقاف النظام

```bash
bash scripts/19-stop-all-local.sh
```

---

## 📋 ملخص سريع

```bash
# 1. تنزيل
git clone --recurse-submodules https://github.com/Orange-OpenSource/ns-O-RAN-flexric.git
cd ns-O-RAN-flexric

# 2. إعداد (مرة واحدة - يستغرق 30-60 دقيقة)
bash scripts/00-setup-all.sh

# 3. تشغيل
bash scripts/12-start-all.sh

# 4. افتح المتصفح
# http://YOUR_IP:8000

# 5. إيقاف (عند الانتهاء)
bash scripts/19-stop-all-local.sh
```

---

## ⚠️ متطلبات النظام

- ✅ Ubuntu 20.04+ (مُختبر على 24.04)
- ✅ 8GB+ RAM
- ✅ 20GB+ مساحة فارغة
- ✅ Docker & Docker Compose (للـ GUI)

---

## ❓ مشاكل شائعة

### المشكلة: git submodules فارغة
```bash
cd ns-O-RAN-flexric
git submodule update --init --recursive
```

### المشكلة: Port 36421 مستخدم
```bash
bash scripts/11-kill-flexric.sh
```

### المشكلة: Docker لا يعمل
```bash
sudo systemctl start docker
sudo systemctl enable docker
```

---

## 📞 للمساعدة

راجع ملف `FIRST_TIME_SETUP.md` للتفاصيل الكاملة.

