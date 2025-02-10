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
        sh '''
        docker build -t add2vals-app:latest .
        docker save -o add2vals.tar add2vals-app:latest
        '''
    }

    stage('Deploy') {
        sshagent(['ec2-ssh-key']) {
            sh '''
            scp -o StrictHostKeyChecking=no add2vals.tar ubuntu@$EC2_IP:/home/ubuntu/
            
            ssh ubuntu@$EC2_IP << 'EOF'
            set -e  # Hentikan script jika ada error

            # Cek apakah Docker sudah terinstall
            if ! command -v docker &> /dev/null
            then
                echo "Docker tidak ditemukan! Menginstall Docker..."
                sudo apt update
                sudo apt install -y docker.io
                sudo systemctl enable docker
                sudo systemctl start docker
            else
                echo "Docker sudah terinstall"
            fi

            # Load Docker image
            docker load -i /home/ubuntu/add2vals.tar

            # Jalankan container selama 1 menit, lalu hentikan
            docker run --name add2vals-container add2vals-app:latest & 
            sleep 60
            docker stop add2vals-container || true

            EOF
            '''
        }

        echo 'Pipeline selesai'
    }
}
