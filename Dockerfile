# Gunakan image Python 3.9 sebagai base image
FROM python:3.9

# Set work directory dalam container
WORKDIR /app

# Copy semua file dari proyek ke dalam container
COPY . .

# Install dependencies jika ada (opsional)
# RUN pip install -r requirements.txt

# Berikan izin eksekusi pada file add2vals.py
RUN chmod +x sources/add2vals.py

# Jalankan script dengan argument default (bisa diganti saat run)
CMD ["python", "sources/add2vals.py", "10", "20"]
