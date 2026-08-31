import nodemailer from "nodemailer";

export async function sendPaymentSuccessEmail(
  email: string,
  residentName: string,
  amount: number,
  blockName: string,
  referenceId: string,
) {
  if (!email || !email.includes("@")) return;

  const smtpUrl = process.env.SMTP_URL;
  if (!smtpUrl) {
    console.warn("SMTP_URL not configured. Skipping payment success email.");
    return;
  }

  try {
    const transporter = nodemailer.createTransport(smtpUrl);

    const formattedAmount = new Intl.NumberFormat("en-IN", {
      style: "currency",
      currency: "INR",
      minimumFractionDigits: 0,
    }).format(amount);

    const html = `
      <div style="font-family: sans-serif; max-w-2xl mx-auto p-6 bg-white border border-gray-200 rounded-xl">
        <h2 style="color: #4f46e5;">Payment Successful!</h2>
        <p>Dear <strong>${residentName}</strong>,</p>
        <p>Thank you for your generous contribution to <strong>Avani Ganesh Utsav 2026</strong>.</p>
        <div style="background: #f8fafc; padding: 16px; border-radius: 8px; margin: 20px 0;">
          <p style="margin: 4px 0;"><strong>Amount:</strong> ${formattedAmount}</p>
          <p style="margin: 4px 0;"><strong>Block:</strong> ${blockName}</p>
          <p style="margin: 4px 0;"><strong>Reference ID:</strong> ${referenceId || "N/A"}</p>
        </div>
        <p>Your support helps make our celebration special!</p>
        <br/>
        <p>Best Regards,</p>
        <p><strong>BT AVANI Ganesh Utsav Committee</strong></p>
      </div>
    `;

    await transporter.sendMail({
      from: process.env.EMAIL_FROM || '"BT AVANI" <noreply@btavani.com>',
      to: email,
      subject: "Thank you for your contribution - BT AVANI Ganesh Utsav",
      html,
    });

    console.log(`Payment success email sent to ${email}`);
  } catch (error) {
    console.error("Failed to send payment success email:", error);
  }
}
