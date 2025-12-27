# خطوات تشغيل و Containerization المشروع

## المرحلة 1: تشغيل المشروع

### الخطوة 1: تحديث Git Submodules
```bash
cd /home/mhmd/Documents/o-ran/ns-O-RAN-flexric
git submodule update --init --recursive
```

### الخطوة 2: تثبيت FlexRIC
```bash
cd /home/mhmd/Documents/o-ran
git clone https://gitlab.eurecom.fr/mosaic5g/flexric.git
cd flexric
git checkout oie-ric-taap-xapps
mkdir build && cd build
cmake .. -DE2AP_VERSION=E2AP_V1 -DKPM_VERSION=KPM_V3_00
make -j$(nproc)
sudo make install
```

### الخطوة 3: بناء e2sim-kpmv3
```bash
cd /home/mhmd/Documents/o-ran/ns-O-RAN-flexric/e2sim-kpmv3/e2sim
mkdir -p build
cd build
# بناء e2sim (سيتم إضافة التفاصيل بعد فحص الملفات)
```

### الخطوة 4: بناء mmwave-LENA-oran
```bash
cd /home/mhmd/Documents/o-ran/ns-O-RAN-flexric/mmwave-LENA-oran
./ns3 configure
./ns3 build
```

### الخطوة 5: تشغيل FlexRIC
```bash
cd /home/mhmd/Documents/o-ran/flexric/build/examples/ric
./nearRT-RIC
```

### الخطوة 6: تشغيل GUI
```bash
cd /home/mhmd/Documents/o-ran/ns-O-RAN-flexric/mmwave-LENA-oran/GUI
# تعديل docker-compose.yml لإضافة NS3_HOST
docker-compose up --build -d
```

## المرحلة 2: Containerization

سيتم إنشاء Dockerfiles لجميع المكونات.

