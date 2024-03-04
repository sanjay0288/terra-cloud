pipeline {
    agent any

    parameters {
        string(name: 'environment', defaultValue: 'terraform', description: 'Workspace/environment file to use for deployment')
        booleanParam(name: 'autoApprove', defaultValue: false, description: 'Automatically run apply after generating plan?')
        booleanParam(name: 'destroy', defaultValue: false, description: 'Destroy Terraform build?')
    }

    environment {
        AWS_ACCESS_KEY_ID     = credentials('AWS_ACCESS_KEY_ID')
        AWS_SECRET_ACCESS_KEY = credentials('AWS_SECRET_ACCESS_KEY')
        // AWS_CREDENTIAL_ID = 'aws_accesskey'
        AWS_DEFAULT_REGION    = "ap-south-1"
    }

    stages {
        stage('checkout') {
            when {
                not {
                    equals expected: true, actual: params.destroy
                }
            }
            steps {
                script {
                    dir("terraform") {
                        sh("""
                            git clone "https://github.com/gshashi1408/terra-cloud.git"
                        """)
                    }
                }
            }
        }

        stage('Plan') {
            when {
                not {
                    equals expected: true, actual: params.destroy
                }
            }
            
            steps {
                sh 'terraform init -input=false'
                sh 'terraform workspace select ${environment} || terraform workspace new ${environment}'
                sh "terraform plan -input=false -out tfplan "
                sh 'terraform show -no-color tfplan > tfplan.txt'
            }
        }

        stage('Approval') {
            when {
                not {
                    equals expected: true, actual: params.autoApprove
                }
                not {
                    equals expected: true, actual: params.destroy
                }
            }
            steps {
                script {
                    def plan = readFile 'tfplan.txt'
                    input message: "Do you want to apply the plan?",
                    parameters: [text(name: 'Plan', description: 'Please review the plan', defaultValue: plan)]
                }
            }
        }

        stage('Apply') {
            when {
                not {
                    equals expected: true, actual: params.destroy
                }
            }
            
            steps {
                sh "terraform apply -input=false tfplan"
            }
        }

        stage('Deploy dependencies') {
            steps {
                // Get the private IP address from the Terraform output
                script {
                    def privateIp = sh(script: 'terraform output private_ip', returnStdout: true).trim()
                    // Write the private IP address to the Ansible hosts file
                    writeFile file: 'inventory/hosts', text: "private_ip ansible_connection=ssh ansible_user=ubuntu"
                }
                sh 'ansible-playbook dependencies.yml -i inventory/hosts'
            }
        }

        stage('Destroy') {
            when {
                equals expected: true, actual: params.destroy
            }
        
            steps {
                sh "terraform destroy --auto-approve"
            }
        }
    }
}
