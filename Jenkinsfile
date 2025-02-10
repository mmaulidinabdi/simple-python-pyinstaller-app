node {
    stage('Checkout') {
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
        docker.image('python:3.9').inside {
            sh '''
            pip install pyinstaller
            pyinstaller --onefile sources/add2vals.py
            '''
        }

        sshagent(['ec2-ssh-key']) {
            sh '''
            scp -o StrictHostKeyChecking=no dist/add2vals ubuntu@$EC2_IP:/home/ubuntu/
            ssh ubuntu@$EC2_IP "chmod +x /home/ubuntu/add2vals && /home/ubuntu/add2vals & sleep 60 && pkill -f add2vals"
            '''
        }

        echo 'Pipeline selesai'
    }
}
