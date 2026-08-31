with open('lib/repository.ts', 'r') as f:
    content = f.read()

replacement = """export async function deleteCmsEntry(id: string) {
  if (!hasDatabase()) {
    const index = memory.cmsEntries.findIndex((item) => item.id === id);
    if (index >= 0) memory.cmsEntries.splice(index, 1);
    return;
  }
  await query('delete from cms_entries where id = $1', [id]);
  await clearMobileCache();
}

export async function deletePayment(id: string) {
  if (!hasDatabase()) {
    const index = memory.payments.findIndex((item) => item.id === id);
    if (index >= 0) memory.payments.splice(index, 1);
    return;
  }
  await query('delete from payments where id = $1', [id]);
  await clearMobileCache();
}

export async function clearDemoData()"""

content = content.replace("export async function clearDemoData()", replacement)

with open('lib/repository.ts', 'w') as f:
    f.write(content)
