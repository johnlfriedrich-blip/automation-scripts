import smtplib
from email.message import EmailMessage

def opt_out_emailtracer(name, email, sender_email, smtp_server, smtp_port, smtp_password):
    msg = EmailMessage()
    msg["Subject"] = "Opt-Out Request"
    msg["From"] = sender_email
    msg["To"] = "privacy@emailtracer.com"
    msg.set_content(f"Please remove the following identity:\nName: {name}\nEmail: {email}")

    with smtplib.SMTP_SSL(smtp_server, smtp_port) as server:
        server.login(sender_email, smtp_password)
        server.send_message(msg)

    return {
        "site": "EmailTracer",
        "status": "sent"
    }