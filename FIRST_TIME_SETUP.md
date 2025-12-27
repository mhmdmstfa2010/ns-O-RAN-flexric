# 🚀 دليل الإعداد الأولي - ns-O-RAN-flexric

## الترتيب الصحيح للسكريبتات عند العمل لأول مرة

---

## 📋 الخطوة 1: استنساخ المشروع

```bash
git clone --recurse-submodules https://github.com/Orange-OpenSource/ns-O-RAN-flexric.git
cd ns-O-RAN-flexric
```

**أو إذا كنت قد استنسخت المشروع بدون submodules:**

```bash
cd ns-O-RAN-flexric
git submodule update --init --recursive
```

---

## 📦 الخطوة 2: الإعداد الكامل

### الخيار 1: سكريبت واحد (الأسهل)

```bash
bash scripts/00-setup-all.sh
```

**هذا السكريبت سيقوم بـ:**
1. ✅ التحقق من git submodules وتفعيلها تلقائياً
2. ✅ تثبيت جميع المتطلبات
3. ✅ تثبيت FlexRIC
4. ✅ بناء e2sim-kpmv3
5. ✅ بناء ns-3 simulator

**الوقت المتوقع:** 30-60 دقيقة

---

### الخيار 2: خطوة بخطوة

```bash
# 1. تثبيت المتطلبات
bash scripts/01-install-dependencies.sh

# 2. تثبيت FlexRIC
bash scripts/02-install-flexric.sh

# 3. بناء e2sim-kpmv3
bash scripts/03-build-e2sim.sh

# 4. بناء ns-3 simulator
bash scripts/04-build-ns3.sh
```

---

## 🎯 الخطوة 3: تشغيل النظام

### الخيار 1: تشغيل كامل (موصى به)

```bash
bash scripts/12-start-all.sh
```

**الوصول:**
- 📊 RIC-TaaP Studio: http://YOUR_IP:8000
- 📈 Grafana: http://YOUR_IP:3000

---

### الخيار 2: تشغيل خطوة بخطوة

**Terminal 1:**
```bash
bash scripts/05-start-flexric.sh
```

**Terminal 2:**
```bash
bash scripts/06-start-gui.sh
```

**Terminal 3:**
```bash
bash scripts/07-start-gui-trigger.sh
```

---

## 🛑 إيقاف النظام

```bash
bash scripts/19-stop-all-local.sh
```

---

## 📊 ملخص الترتيب

```
1. git clone --recurse-submodules
   ↓
2. bash scripts/00-setup-all.sh
   ↓
3. bash scripts/12-start-all.sh
   ↓
4. افتح المتصفح: http://YOUR_IP:8000
   ↓
5. bash scripts/19-stop-all-local.sh (عند الانتهاء)
```

---

## ⚠️ ملاحظات

- الوقت المتوقع للإعداد: 30-60 دقيقة
- بناء ns-3 قد يستغرق 20-30 دقيقة
- تأكد من وجود 8GB+ RAM و 20GB+ مساحة فارغة

---

## ✅ Checklist

- [ ] استنساخ المشروع مع submodules
- [ ] تشغيل 00-setup-all.sh
- [ ] انتظار انتهاء البناء
- [ ] تشغيل 12-start-all.sh
- [ ] فتح المتصفح على http://YOUR_IP:8000
