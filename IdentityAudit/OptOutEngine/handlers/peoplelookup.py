def opt_out_peoplelookup(name, email, sender_email, smtp_config):
    import smtplib
    from email.message import EmailMessage

    msg = EmailMessage()
    msg["Subject"] = "Opt-Out Request"
    msg["From"] = sender_email
    msg["To"] = "support@peoplelookup.co"
    msg.set_content(f"Please remove the following identity:\nName: {name}\nEmail: {email}")

    with smtplib.SMTP_SSL(smtp_config["smtp_server"], smtp_config["smtp_port"]) as smtp:
        smtp.login(sender_email, smtp_config["smtp_password"])
        smtp.send_message(msg)

    return {
        "site": "PeopleLookUp",
        "status": "sent"
    }