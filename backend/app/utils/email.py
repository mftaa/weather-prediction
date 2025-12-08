"""
Email utility functions
"""
import smtplib
from email.mime.text import MIMEText
from email.mime.multipart import MIMEMultipart
from app.core.config import settings

def send_email(subject: str, message: str, to_email: str) -> bool:
    """
    Send email using SMTP
    
    Args:
        subject: Email subject
        message: Email message body
        to_email: Recipient email address
    
    Returns:
        bool: True if email sent successfully, False otherwise
    """
    try:
        # Set up the email server
        server = smtplib.SMTP(settings.EMAIL_HOST, settings.EMAIL_PORT)
        server.starttls()
        
        # Login
        server.login(settings.EMAIL_USERNAME, settings.EMAIL_PASSWORD)
        
        # Create message
        msg = MIMEMultipart()
        msg['From'] = settings.EMAIL_USERNAME
        msg['To'] = to_email
        msg['Subject'] = subject
        msg.attach(MIMEText(message, 'plain'))
        
        # Send the email
        server.sendmail(settings.EMAIL_USERNAME, to_email, msg.as_string())
        print(f"✓ Email sent successfully to {to_email}")
        return True
        
    except smtplib.SMTPException as e:
        print(f"✗ Failed to send email: {e}")
        return False
        
    finally:
        try:
            server.quit()
        except:
            pass

def send_otp_email(otp: str, to_email: str) -> bool:
    """
    Send OTP verification email
    
    Args:
        otp: OTP code
        to_email: Recipient email address
    
    Returns:
        bool: True if email sent successfully, False otherwise
    """
    subject = "Weather App - User Verification"
    message = f"""
Hello,

Your OTP for verification is: {otp}

This OTP will expire in 5 minutes.

Best regards,
Weather Prediction Team
    """
    return send_email(subject, message.strip(), to_email)
