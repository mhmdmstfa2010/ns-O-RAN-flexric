# 🚀 Quick Start Guide - ns-O-RAN-flexric

## الخيار 1: التشغيل المباشر (بدون Docker)

### خطوة واحدة - التثبيت الكامل

```bash
cd /home/mhmd/Documents/o-ran/ns-O-RAN-flexric
bash scripts/00-setup-all.sh
```

### تشغيل النظام

**Terminal 1 - FlexRIC:**
```bash
bash scripts/05-start-flexric.sh
```

**Terminal 2 - GUI:**
```bash
bash scripts/06-start-gui.sh
```

**Terminal 3 - GUI Trigger:**
```bash
bash scripts/07-start-gui-trigger.sh
```

**الوصول:**
- Dashboard: http://YOUR_IP:8000
- Grafana: http://YOUR_IP:3000

---

## الخيار 2: Containerization (Docker)

### بناء وتشغيل

```bash
cd /home/mhmd/Documents/o-ran/ns-O-RAN-flexric/docker
docker-compose build
docker-compose up -d
```

**الوصول:**
- Dashboard: http://localhost:8000
- Grafana: http://localhost:3000

### تشغيل محاكاة

```bash
docker-compose exec ns3-simulator ./ns3 run "scratch/scenario-zero-with_parallel_loging.cc --e2TermIp=e2sim"
```

---

## 📚 الملفات المهمة

- `DEPLOYMENT_GUIDE.md` - دليل شامل
- `scripts/` - جميع سكريبتات التشغيل
- `docker/` - ملفات Docker
- `README.md` - الوثائق الأصلية

---

## ⚠️ متطلبات

- Ubuntu 20.04+ (24.04 يعمل)
- 8GB RAM minimum
- 20GB disk space
- Docker & Docker Compose (للـ containerization)

