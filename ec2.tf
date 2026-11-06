
resource "aws_instance" "web" {
  count = var.instance_count

  ami           = data.aws_ami.ubuntu.id
  instance_type = var.instance_type

  subnet_id              = aws_subnet.public[count.index].id
  vpc_security_group_ids = [aws_security_group.ec2_sg.id]

  associate_public_ip_address = true

  # Recreate EC2 when user_data changes
  user_data_replace_on_change = true

  root_block_device {
    volume_type = "gp3"
    volume_size = 8
  }

  user_data = <<-EOF
    #!/bin/bash

    apt-get update -y
    apt-get install -y nginx curl

    systemctl enable nginx
    systemctl start nginx

    # Get EC2 metadata using IMDSv2
    TOKEN=$(curl -sS -X PUT \
      "http://169.254.169.254/latest/api/token" \
      -H "X-aws-ec2-metadata-token-ttl-seconds: 21600")

    INSTANCE_ID=$(curl -sS \
      -H "X-aws-ec2-metadata-token: $TOKEN" \
      http://169.254.169.254/latest/meta-data/instance-id)

    AZ=$(curl -sS \
      -H "X-aws-ec2-metadata-token: $TOKEN" \
      http://169.254.169.254/latest/meta-data/placement/availability-zone)

    PRIVATE_IP=$(curl -sS \
      -H "X-aws-ec2-metadata-token: $TOKEN" \
      http://169.254.169.254/latest/meta-data/local-ipv4)

    PUBLIC_IP=$(curl -sS \
      -H "X-aws-ec2-metadata-token: $TOKEN" \
      http://169.254.169.254/latest/meta-data/public-ipv4)

    cat > /var/www/html/index.html <<HTML
    <!DOCTYPE html>
    <html>
    <head>
      <title>AWS EC2 Load Balancer Demo</title>
      <meta name="viewport" content="width=device-width, initial-scale=1">

      <style>
        body {
          margin: 0;
          font-family: Arial, sans-serif;
          background: linear-gradient(135deg, #101d35, #253f65);
          color: white;
          min-height: 100vh;
          display: flex;
          justify-content: center;
          align-items: center;
        }

        .container {
          background: white;
          color: #1e293b;
          width: 90%;
          max-width: 650px;
          padding: 35px;
          border-radius: 18px;
          box-shadow: 0 15px 40px rgba(0,0,0,.3);
        }

        h1 {
          color: #1463d5;
          text-align: center;
        }

        .status {
          text-align: center;
          color: #16a34a;
          font-weight: bold;
          margin: 20px 0;
        }

        .info {
          background: #f1f5f9;
          padding: 15px;
          margin: 12px 0;
          border-radius: 10px;
        }

        .label {
          color: #64748b;
          font-size: 13px;
        }

        .value {
          font-weight: bold;
          font-size: 17px;
          margin-top: 5px;
          overflow-wrap: anywhere;
        }

        .footer {
          text-align: center;
          margin-top: 25px;
          color: #64748b;
          font-size: 13px;
        }
      </style>
    </head>

    <body>
      <div class="container">

        <h1>AWS Load Balancer Demo</h1>

        <div class="status">
          ● YOUR REQUEST IS SERVED SUCCESSFULLY
        </div>

        <h2 style="text-align:center">
          Welcome to Web-Server-${count.index + 1}
        </h2>

        <div class="info">
          <div class="label">EC2 Instance ID</div>
          <div class="value">$${INSTANCE_ID}</div>
        </div>

        <div class="info">
          <div class="label">Availability Zone</div>
          <div class="value">$${AZ}</div>
        </div>

        <div class="info">
          <div class="label">Private IP Address</div>
          <div class="value">$${PRIVATE_IP}</div>
        </div>

        <div class="info">
          <div class="label">Public IP Address</div>
          <div class="value">$${PUBLIC_IP}</div>
        </div>

        <div class="info">
          <div class="label">Web Server</div>
          <div class="value">Nginx - Running</div>
        </div>

        <div class="footer">
          AWS EC2 | Application Load Balancer | Terraform
        </div>

      </div>
    </body>
    </html>
    HTML

    systemctl restart nginx
  EOF

  tags = {
    Name = "Web-Server-${count.index + 1}"
  }
}
