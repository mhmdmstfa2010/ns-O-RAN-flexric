# دليل تشغيل و Containerization المشروع

## 📋 نظرة عامة

هذا الدليل يشرح كيفية:
1. تشغيل المشروع بالكامل وعرض Dashboard
2. Containerize المشروع بالكامل

---

## 🚀 المرحلة 1: تشغيل المشروع

### الخطوة 1: التثبيت الكامل

```bash
cd /home/mhmd/Documents/o-ran/ns-O-RAN-flexric
bash scripts/00-setup-all.sh
```

هذا السكريبت سيقوم بـ:
- ✅ تثبيت جميع المتطلبات
- ✅ تثبيت FlexRIC
- ✅ بناء e2sim-kpmv3
- ✅ بناء ns-3 simulator

### الخطوة 2: تشغيل FlexRIC

افتح terminal جديد:

```bash
cd /home/mhmd/Documents/o-ran/ns-O-RAN-flexric
bash scripts/05-start-flexric.sh
```

اتركه يعمل في الخلفية (أو افتح terminal جديد).

### الخطوة 3: تشغيل GUI

افتح terminal جديد:

```bash
cd /home/mhmd/Documents/o-ran/ns-O-RAN-flexric
bash scripts/06-start-gui.sh
```

انتظر حتى تظهر الرسالة:
```
Access RIC-TaaP Studio at: http://YOUR_IP:8000
Access Grafana at: http://YOUR_IP:3000
```

### الخطوة 4: تشغيل GUI Trigger

افتح terminal جديد:

```bash
cd /home/mhmd/Documents/o-ran/ns-O-RAN-flexric
bash scripts/07-start-gui-trigger.sh
```

### الخطوة 5: الوصول إلى Dashboard

1. افتح المتصفح واذهب إلى: `http://YOUR_IP:8000`
2. في الواجهة:
   - اضغط "Connect to FlexRIC"
   - اضغط "Show form"
   - اختر Scenario وحدد المعاملات
   - اضغط "Start"
3. شاهد الخلايا والـ UEs على الشبكة
4. اضغط "Source Data" لرؤية KPIs

### الخطوة 6: تشغيل xApp (اختياري)

```bash
cd /home/mhmd/Documents/o-ran/flexric/build/examples/xApp/c/kpm_rc
./xapp_kpm_rc
```

---

## 🐳 المرحلة 2: Containerization

### الخطوة 1: بناء جميع Containers

```bash
cd /home/mhmd/Documents/o-ran/ns-O-RAN-flexric/docker
docker-compose build
```

**ملاحظة**: البناء قد يستغرق وقتاً طويلاً (خاصة ns-3).

### الخطوة 2: تشغيل جميع الخدمات

```bash
docker-compose up -d
```

### الخطوة 3: التحقق من الحالة

```bash
docker-compose ps
```

يجب أن ترى جميع الخدمات تعمل:
- ✅ ns-oran-influxdb
- ✅ ns-oran-grafana
- ✅ ns-oran-gui
- ✅ ns-oran-flexric
- ✅ ns-oran-e2sim
- ✅ ns-oran-ns3

### الخطوة 4: الوصول إلى Dashboard

- **RIC-TaaP Studio**: http://localhost:8000
- **Grafana**: http://localhost:3000 (admin/admin)

### الخطوة 5: تشغيل محاكاة ns-3

```bash
docker-compose exec ns3-simulator ./ns3 run "scratch/scenario-zero-with_parallel_loging.cc --e2TermIp=e2sim --indicationPeriodicity=0.1 --simTime=1000"
```

### الخطوة 6: عرض Logs

```bash
# جميع الخدمات
docker-compose logs -f

# خدمة محددة
docker-compose logs -f flexric
docker-compose logs -f gui
```

### الخطوة 7: إيقاف الخدمات

```bash
docker-compose down
```

---

## 📁 هيكل الملفات

```
ns-O-RAN-flexric/
├── scripts/                    # سكريبتات التشغيل
│   ├── 00-setup-all.sh
│   ├── 01-install-dependencies.sh
│   ├── 02-install-flexric.sh
│   ├── 03-build-e2sim.sh
│   ├── 04-build-ns3.sh
│   ├── 05-start-flexric.sh
│   ├── 06-start-gui.sh
│   └── 07-start-gui-trigger.sh
│
├── docker/                     # ملفات Docker
│   ├── Dockerfile.flexric
│   ├── Dockerfile.e2sim
│   ├── Dockerfile.ns3
│   ├── docker-compose.yml
│   └── README.md
│
├── e2sim-kpmv3/               # e2sim source
├── mmwave-LENA-oran/         # ns-3 simulator
└── DEPLOYMENT_GUIDE.md       # هذا الملف
```

---

## 🔧 استكشاف الأخطاء

### المشكلة: FlexRIC لا يعمل

```bash
# تحقق من البناء
ls -la /home/mhmd/Documents/o-ran/flexric/build/examples/ric/nearRT-RIC

# تحقق من Logs
docker-compose logs flexric
```

### المشكلة: GUI لا يفتح

```bash
# تحقق من Docker containers
docker-compose ps

# تحقق من Logs
docker-compose logs gui

# تحقق من Ports
netstat -tulpn | grep 8000
```

### المشكلة: ns-3 لا يبني

```bash
# تحقق من المتطلبات
cd mmwave-LENA-oran
./ns3 configure
./ns3 build
```

### المشكلة: InfluxDB لا يتصل

```bash
# تحقق من InfluxDB
docker-compose logs influxdb

# تحقق من الاتصال
docker-compose exec influxdb influx -execute "SHOW DATABASES"
```

---

## 📝 ملاحظات مهمة

1. **الذاكرة**: ns-3 يحتاج على الأقل 8GB RAM
2. **الوقت**: البناء الكامل قد يستغرق 30-60 دقيقة
3. **المساحة**: احتياج قرصي ~20GB
4. **الشبكة**: تأكد من أن Ports 8000, 3000, 8086, 36421 متاحة

---

## 🎯 الخطوات التالية بعد التشغيل

1. **دراسة Dashboard**: استكشف جميع KPIs المتاحة
2. **تجربة Scenarios**: جرب سيناريوهات مختلفة
3. **تعديل xApps**: عدل على xApps الموجودة
4. **إضافة AI Model**: أضف AI model الخاص بك

---

## 📞 الدعم

إذا واجهت مشاكل:
1. راجع Logs: `docker-compose logs`
2. راجع README.md الأصلي
3. تحقق من المتطلبات

---

## ✅ Checklist

- [ ] تثبيت المتطلبات
- [ ] بناء FlexRIC
- [ ] بناء e2sim
- [ ] بناء ns-3
- [ ] تشغيل FlexRIC
- [ ] تشغيل GUI
- [ ] الوصول إلى Dashboard
- [ ] Containerize المشروع
- [ ] اختبار النظام المعبأ

