node {
    stage('Checkout') {
        cleanWs()
        checkout scm
    }

    stage('Build') {
        docker.image('python:2-alpine').inside {
            sh 'python -m py_compile ./sources/add2vals.py ./sources/calc.py'
        }
    }

    stage('Test') {
        docker.image('qnib/pytest').inside {
            sh 'py.test --verbose --junit-xml test-reports/results.xml ./sources/test_calc.py'
        }
        junit 'test-reports/results.xml'
    }

    stage('Manual Approval') {
        input message: 'Lanjutkan ke tahap Deploy?', ok: 'Proceed'
    }

    stage('Build Image') {
        withCredentials([usernamePassword(credentialsId: 'docker-hub-user', passwordVariable: 'PASS', usernameVariable: 'USER')]) {
            sh '''
            docker build -t $USER/add2vals-app:latest .
            '''
        }
    }

    stage('Push to Docker Hub') {
        withCredentials([usernamePassword(credentialsId: 'docker-hub-user', passwordVariable: 'PASS', usernameVariable: 'USER')]) {
            sh '''
            echo $PASS | docker login -u $USER --password-stdin
            docker push $USER/add2vals-app:latest
            '''
        }
    }

    stage('Deploy') {
        sshagent(['ec2-ssh-key']) {
             sh '''
            ssh -o StrictHostKeyChecking=no ubuntu@$EC2_IP << 'EOF'
            
            # Periksa apakah Docker sudah terinstal
            if ! command -v docker &> /dev/null; then
                echo "Docker tidak ditemukan, menginstal Docker..."
                sudo apt update
                sudo apt install -y docker.io
                sudo systemctl enable docker
                sudo systemctl start docker
            fi

            # Tarik dan jalankan container
            sudo docker pull mmauld/add2vals-app:latest

            docker ps -a | grep add2vals-container && docker stop add2vals-container && docker rm add2vals-container || echo "Container not found, skipping removal."

            # Jalankan container baru
            sudo docker run -d --name add2vals-container mmauld/add2vals-app:latest

            # Tunggu 1 menit sebelum menghentikan container
            echo "Container berjalan selama 1 menit"
            sleep 60
            docker stop add2vals-container || true
EOF
            '''
        }
        echo 'Pipeline selesai'
    }
}
