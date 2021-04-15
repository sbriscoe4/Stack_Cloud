#data configuration - configuration for the bootstrap file - passes in variable at runtime
data "template_file" "bootstrap" {
    #template = (format("%s/boostrap.tpl", "/c:/apps/STACK_EC2-TF")) #using template file to pull in boostrap
    vars= {
        DATABASE="mariadb-server"
        DB_NAME=var.DB_NAME
        DB_USER=var.DB_USER
        DB_PASSWORD=var.DB_PASSWORD
        #DB_HOST=var.DB_HOST
    }
}