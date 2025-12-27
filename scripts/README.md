# دليل استخدام سكريبتات ns-O-RAN-flexric

هذا الملف يوضح ترتيب استخدام السكريبتات في المشروع.

## 📋 السكريبتات المتاحة

### 🚀 الإعداد الأولي (Setup)

#### 1. الإعداد الكامل (موصى به للمرة الأولى)
```bash
bash scripts/00-setup-all.sh
```
**ما يفعله:**
- تثبيت جميع المتطلبات
- تثبيت FlexRIC
- بناء e2sim-kpmv3
- بناء ns-3 simulator

**الوقت المتوقع:** 30-60 دقيقة

---

#### 2. الإعداد خطوة بخطوة (اختياري)

إذا كنت تريد التحكم في كل خطوة:

```bash
# الخطوة 1: تثبيت المتطلبات
bash scripts/01-install-dependencies.sh

# الخطوة 2: تثبيت FlexRIC
bash scripts/02-install-flexric.sh

# الخطوة 3: بناء e2sim
bash scripts/03-build-e2sim.sh

# الخطوة 4: بناء ns-3
bash scripts/04-build-ns3.sh
```

---

### 🎯 التشغيل (Local - بدون Docker)

#### تشغيل النظام بالكامل (موصى به)
```bash
bash scripts/12-start-all.sh
```
**ما يفعله:**
- يتحقق من أن جميع المكونات جاهزة
- يبدأ FlexRIC (nearRT-RIC)
- يبدأ RIC-TaaP Studio GUI
- يبدأ GUI Trigger (لدفع KPIs إلى InfluxDB)

**الوصول:**
- GUI: http://localhost:8000
- Grafana: http://localhost:3000

---

#### التشغيل خطوة بخطوة (اختياري)

```bash
# الخطوة 1: بدء FlexRIC
bash scripts/05-start-flexric.sh

# الخطوة 2: بدء GUI
bash scripts/06-start-gui.sh

# الخطوة 3: بدء GUI Trigger
bash scripts/07-start-gui-trigger.sh
```

---

### 🛑 الإيقاف (Local)

#### إيقاف FlexRIC فقط
```bash
bash scripts/11-kill-flexric.sh
```

#### إيقاف كل شيء (Local)
```bash
bash scripts/19-stop-all-local.sh
```
**ما يفعله:**
- يوقف FlexRIC
- يوقف GUI Trigger
- يوقف GUI Docker containers
- يتحقق من أن جميع المنافذ حرة

---

### 🐳 Docker (Containerized Setup)

#### الإعداد الكامل مع Docker (موصى به)
```bash
bash scripts/18-docker-complete-setup.sh
```
**ما يفعله:**
- يوقف جميع الخدمات المحلية
- يبني جميع Docker containers
- يبدأ جميع الخدمات في Docker

**الوقت المتوقع:** 30-60 دقيقة (أول مرة)

---

#### بناء Docker Containers فقط
```bash
bash scripts/13-docker-build.sh
```
**الوقت المتوقع:** 30-60 دقيقة

---

#### بدء Docker Services
```bash
bash scripts/14-docker-start.sh
```

**الوصول:**
- GUI: http://localhost:8000
- Grafana: http://localhost:3000
- InfluxDB: http://localhost:8086

---

#### إيقاف Docker Services
```bash
bash scripts/15-docker-stop.sh
```

---

#### تشغيل ns-3 Scenario في Docker
```bash
bash scripts/16-docker-run-scenario.sh <scenario_name.cc> [args...]
```

**أمثلة:**
```bash
# تشغيل scenario-zero
bash scripts/16-docker-run-scenario.sh scenario-zero-with_parallel_loging.cc

# مع معاملات إضافية
bash scripts/16-docker-run-scenario.sh scenario-one.cc --simTime=100
```

---

#### تشغيل xApp في Docker
```bash
bash scripts/17-docker-run-xapp.sh <xapp_name> [args...]
```

**أمثلة:**
```bash
# تشغيل KPM xApp
bash scripts/17-docker-run-xapp.sh kpm_rc

# تشغيل Energy Saving xApp
bash scripts/17-docker-run-xapp.sh orange/xapp_es_with_cell_util
```

---

## 📊 سيناريوهات الاستخدام الشائعة

### السيناريو 1: الإعداد الأولي والتشغيل (Local)
```bash
# 1. الإعداد الكامل
bash scripts/00-setup-all.sh

# 2. تشغيل النظام
bash scripts/12-start-all.sh

# 3. افتح المتصفح
# - GUI: http://localhost:8000
# - Grafana: http://localhost:3000
```

---

### السيناريو 2: الإعداد الأولي مع Docker
```bash
# 1. الإعداد الكامل مع Docker
bash scripts/18-docker-complete-setup.sh

# 2. افتح المتصفح
# - GUI: http://localhost:8000
# - Grafana: http://localhost:3000

# 3. لتشغيل scenario من GUI:
#    - افتح http://localhost:8000
#    - اضغط "Show simulation setup"
#    - اختر scenario واضغط "Start"
```

---

### السيناريو 3: إعادة التشغيل بعد التوقف
```bash
# إذا كنت تستخدم Local:
bash scripts/12-start-all.sh

# إذا كنت تستخدم Docker:
bash scripts/14-docker-start.sh
```

---

### السيناريو 4: الانتقال من Local إلى Docker
```bash
# 1. إيقاف كل شيء محلي
bash scripts/19-stop-all-local.sh

# 2. بناء وبدء Docker
bash scripts/18-docker-complete-setup.sh
```

---

## 🔍 التحقق من الحالة

### التحقق من FlexRIC
```bash
# التحقق من العملية
ps aux | grep nearRT-RIC

# التحقق من المنفذ
netstat -tuln | grep 36421
# أو
ss -tuln | grep 36421
```

### التحقق من Docker Containers
```bash
cd docker
docker-compose ps
```

### التحقق من GUI
```bash
curl http://localhost:8000/docs
```

### التحقق من Grafana
```bash
curl http://localhost:3000/api/health
```

---

## ⚠️ استكشاف الأخطاء

### مشكلة: Port 36421 مستخدم
```bash
bash scripts/11-kill-flexric.sh
```

### مشكلة: Docker containers لا تبدأ
```bash
# تحقق من الـ logs
cd docker
docker-compose logs

# إعادة البناء
bash scripts/13-docker-build.sh
```

### مشكلة: GUI لا يعرض بيانات
1. تأكد من أن `sim_data_pusher.py` يعمل
2. تأكد من أن ns-3 scenario تم تشغيله
3. تحقق من InfluxDB:
   ```bash
   docker exec ns-oran-influxdb influx -database influx -username admin -password admin -execute "SHOW MEASUREMENTS"
   ```

---

## 📝 ملاحظات مهمة

1. **الترتيب مهم:** يجب تشغيل السكريبتات بالترتيب المذكور
2. **الوقت:** بناء ns-3 قد يستغرق 30-60 دقيقة
3. **المساحة:** تأكد من وجود مساحة كافية (10GB+)
4. **الصلاحيات:** بعض السكريبتات تحتاج `sudo`

---

## 🗂️ هيكل السكريبتات

```
scripts/
├── 00-setup-all.sh              # الإعداد الكامل
├── 01-install-dependencies.sh   # تثبيت المتطلبات
├── 02-install-flexric.sh        # تثبيت FlexRIC
├── 03-build-e2sim.sh            # بناء e2sim
├── 04-build-ns3.sh              # بناء ns-3
├── 05-start-flexric.sh          # بدء FlexRIC
├── 06-start-gui.sh              # بدء GUI
├── 07-start-gui-trigger.sh      # بدء GUI Trigger
├── 11-kill-flexric.sh           # إيقاف FlexRIC
├── 12-start-all.sh              # بدء النظام بالكامل
├── 13-docker-build.sh           # بناء Docker
├── 14-docker-start.sh            # بدء Docker
├── 15-docker-stop.sh             # إيقاف Docker
├── 16-docker-run-scenario.sh     # تشغيل scenario
├── 17-docker-run-xapp.sh         # تشغيل xApp
├── 18-docker-complete-setup.sh   # إعداد Docker كامل
└── 19-stop-all-local.sh          # إيقاف كل شيء محلي
```

---

## 📞 المساعدة

إذا واجهت مشاكل:
1. تحقق من الـ logs في `/tmp` أو `docker-compose logs`
2. راجع ملف `COMPLETE_DOCUMENTATION.md` في جذر المشروع
3. راجع ملف `docker/DOCKERIZATION_GUIDE.md` للـ Docker setup

