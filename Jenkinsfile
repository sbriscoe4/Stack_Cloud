pipeline {
    agent any
    environment{
        PATH = "${PATH}:${getTerraformPath()}"
    }
    stages{
        stage('terraform init'){
            steps {
                sh "terraform init"
            }
        }
    }
}

def getTerraformPath(){
    def tfHome= tool name: 'terraform-14', type: 'terraform'
    retrun tfHome
}

/*
steps {
        sh "terraform workspace new dev"
        sh "terraform init"
    }
*/