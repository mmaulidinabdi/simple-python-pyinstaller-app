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

    stage('Deploy') {
        docker.image('python:3.9').inside('--user root') {
               sh '''
                pip install --no-cache-dir --user pyinstaller
                export PATH=$HOME/.local/bin:$PATH
                pyinstaller --onefile sources/add2vals.py
                '''
        }

        echo "EC2_IP: $EC2_IP"
        sh 'ls -l dist/add2vals'

        sshagent(['ec2-ssh-key']) {
            try {
                sh '''
                scp -o StrictHostKeyChecking=no dist/add2vals ubuntu@$EC2_IP:/home/ubuntu/
                ssh ubuntu@$EC2_IP "chmod +x /home/ubuntu/add2vals && /home/ubuntu/add2vals & sleep 60 && pkill -f add2vals"
                '''
            } catch (Exception e) {
                echo "Deploy failed: ${e}"
                currentBuild.result = 'FAILURE'
                throw e
            }
        }

        echo 'Pipeline selesai'
    }
}