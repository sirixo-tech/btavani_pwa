with open('lib/repository.ts', 'r') as f:
    content = f.read()

# Add import
content = content.replace(
    'import { clearMobileCache, getCachedJson, setCachedJson } from "./cache";',
    'import { clearMobileCache, getCachedJson, setCachedJson } from "./cache";\nimport { sendPaymentSuccessEmail } from "./email";'
)

# Update updatePaymentStatus
target1 = """  await query(
    `update payments
     set status = $2, reference_id = $3, paid_at = case when $2 = 'paid' then coalesce(paid_at, now()) else paid_at end
     where id = $1`,
    [id, status, referenceId],
  );
  await clearMobileCache();"""
  
replacement1 = """  const result = await query(
    `update payments
     set status = $2, reference_id = $3, paid_at = case when $2 = 'paid' then coalesce(paid_at, now()) else paid_at end
     where id = $1
     returning email, resident_name, amount, block_name`,
    [id, status, referenceId],
  );
  await clearMobileCache();

  if (status === "paid" && result.rows.length > 0) {
    const row = result.rows[0];
    if (row.email) {
      sendPaymentSuccessEmail(row.email, row.resident_name, row.amount, row.block_name, referenceId);
    }
  }"""
content = content.replace(target1, replacement1)

# Update createPayment
target2 = """  await query(
    `insert into payments
      (id, amount, block_id, resident_name, email, phone, flat_number, gotram, provider, status, reference_id, paid_at)
     values ($1,$2,$3,$4,$5,$6,$7,$8,$9,$10,$11,$12)`,
    [
      payment.id,
      payment.amount,
      payment.blockId,
      payment.residentName,
      payment.email,
      payment.phone,
      payment.flatNumber,
      payment.gotram,
      payment.provider,
      payment.status,
      payment.referenceId,
      payment.paidAt || null,
    ],
  );
  await clearMobileCache();
  return payment;"""

replacement2 = """  await query(
    `insert into payments
      (id, amount, block_id, resident_name, email, phone, flat_number, gotram, provider, status, reference_id, paid_at)
     values ($1,$2,$3,$4,$5,$6,$7,$8,$9,$10,$11,$12)`,
    [
      payment.id,
      payment.amount,
      payment.blockId,
      payment.residentName,
      payment.email,
      payment.phone,
      payment.flatNumber,
      payment.gotram,
      payment.provider,
      payment.status,
      payment.referenceId,
      payment.paidAt || null,
    ],
  );
  await clearMobileCache();
  
  if (payment.status === "paid" && payment.email) {
    sendPaymentSuccessEmail(payment.email, payment.residentName, payment.amount, payment.blockName, payment.referenceId);
  }
  
  return payment;"""
content = content.replace(target2, replacement2)

with open('lib/repository.ts', 'w') as f:
    f.write(content)
