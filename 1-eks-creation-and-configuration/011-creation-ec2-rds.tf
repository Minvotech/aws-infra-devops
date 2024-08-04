resource "aws_security_group" "app_sg" {
  name_prefix = "app-sg-"
  vpc_id      = module.vpc.vpc_id

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
   ingress {
    from_port   = 300
    to_port     = 300
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
   ingress {
    from_port   = 300
    to_port     = 300
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
   ingress {
    from_port   = 9200
    to_port     = 9200
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
   ingress {
    from_port   = 9090
    to_port     = 9090
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
   ingress {
    from_port   = 5601
    to_port     = 5601
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port       = 0
    to_port         = 0
    protocol        = "-1"
    cidr_blocks     = ["0.0.0.0/0"]
  }
}
resource "aws_iam_role" "ec2_instance_role" {
  name = "ec2_instance_role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "ec2.amazonaws.com"
        }
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "ec2_instance_role_policy" {
  role       = aws_iam_role.ec2_instance_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonEC2FullAccess"
}

resource "aws_iam_instance_profile" "ec2_instance_profile" {
  name = "ec2_instance_profile"
  role = aws_iam_role.ec2_instance_role.name
}


# Create a security group for the RDS instance
resource "aws_security_group" "db_sg" {
  name_prefix = "db-sg-"
  vpc_id      = module.vpc.vpc_id

  ingress {
    from_port       = 3306
    to_port         = 3306
    protocol        = "tcp"
    security_groups = [aws_security_group.app_sg.id]
  }

  egress {
    from_port       = 0
    to_port         = 0
    protocol        = "-1"
    cidr_blocks     = ["0.0.0.0/0"]
  }
}


# Create the EC2 instance
resource "aws_instance" "app_instance" {
  ami           = "ami-0c9f6749650d5c0e3" # Amazon Linux 2 AMI
  instance_type = "t2.medium"
  associate_public_ip_address = true
  subnet_id     = module.vpc.public_subnets[0]
  #iam_role = aws_iam_role.ec2_instance_role.arn
  vpc_security_group_ids = [aws_security_group.app_sg.id]
  key_name  = "task"

  iam_instance_profile = aws_iam_instance_profile.ec2_instance_profile.name


  user_data = <<-EOF
              #!/bin/bash
              apt update -y
              apt install -y nginx
              systemctl start nginx
              systemctl enable nginx
              echo "<h1>Hello, World!</h1>" > /usr/share/nginx/html/index.html
              echo "<h1>Hello, World!</h1>" > /var/www/html/index.html
              sudo apt install apt-transport-https ca-certificates curl software-properties-common -y
              curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo apt-key add -
              sudo add-apt-repository "deb [arch=amd64] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable"
              apt update
              sudo apt install docker-ce -y
              sudo curl -L "https://github.com/docker/compose/releases/download/2.20.2/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose
              sudo chmod +x /usr/local/bin/docker-compose
              docker-compose --version
              docker-compose
              mkdir ~/monitoring-logging
              sudo curl -L "https://github.com/docker/compose/releases/download/1.29.2/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose
              sudo chmod +x /usr/local/bin/docker-compose
              cd ~/monitoring-logging
              cat <<EOF > docker-compose.yml
              version: '3.8'
              services:
                prometheus:
                  image: prom/prometheus:latest
                  container_name: prometheus
                  volumes:
                    - ./prometheus.yml:/etc/prometheus/prometheus.yml
                  ports:
                    - "9090:9090"
                
                grafana:
                  image: grafana/grafana:latest
                  container_name: grafana
                  depends_on:
                    - prometheus
                  ports:
                    - "3000:3000"
                  volumes:
                    - grafana-storage:/var/lib/grafana
                
                elasticsearch:
                  image: docker.elastic.co/elasticsearch/elasticsearch:8.8.1
                  container_name: elasticsearch
                  environment:
                    - discovery.type=single-node
                  ports:
                    - "9200:9200"
                
                logstash:
                  image: docker.elastic.co/logstash/logstash:8.8.1
                  container_name: logstash
                  depends_on:
                    - elasticsearch
                  ports:
                    - "5044:5044"
                  volumes:
                    - ./logstash.conf:/usr/share/logstash/pipeline/logstash.conf

                kibana:
                  image: docker.elastic.co/kibana/kibana:8.8.1
                  container_name: kibana
                  depends_on:
                    - elasticsearch
                  ports:
                    - "5601:5601"

              volumes:
                grafana-storage:

              
              
              cat <<EOF > prometheus.yml
global:
  scrape_interval: 15s

scrape_configs:
  - job_name: 'prometheus'
    static_configs:
      - targets: ['prometheus:9090']

  - job_name: 'zvendo'
    static_configs:
      - targets: ['zvendo.com:80'] # Replace with your application's address
EOF,
cat <<EOF > logstash.conf
input {
  beats {
    port => 5044
  }
}

output {
  elasticsearch {
    hosts => ["http://elasticsearch:9200"]
    index => "logstash-date"
  }
}

sudo docker-compose up -d
EOF


  tags = {
    Name = "app-instance"
  }
}

resource "aws_db_subnet_group" "db_subnet_group" {
  name       = "main"
  subnet_ids = module.vpc.private_subnets

  tags = {
    Name = "MainSubnetGroup"
  }
}

# Create the RDS instance
resource "aws_db_instance" "app_db" {
  identifier          = "rds-app"
  engine               = "mysql"
  engine_version       = "8.0"
  instance_class      = "db.t3.micro"
  allocated_storage   = 20
  storage_type         = "gp2"
  db_name             = "myapp"
  username             = "myappuser"
  password             = "myapppassword"
  vpc_security_group_ids = [aws_security_group.db_sg.id]
  skip_final_snapshot  = true
  availability_zone = "ca-central-1a" #lookup(module.vpc.private_subnets, module.vpc.private_subnets[0])["availability_zone"]
  #availability_zone    = module.vpc.private_subnets[0].availability_zone
  db_subnet_group_name   = aws_db_subnet_group.db_subnet_group.name
  publicly_accessible    = false

  tags = {
    Name = "RDSInstance"
  }
}
