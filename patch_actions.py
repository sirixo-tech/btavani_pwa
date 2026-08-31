with open('app/admin/actions.ts', 'r') as f:
    content = f.read()

content = content.replace(
    'import {\n  createPayment,\n  saveBlock,\n  saveCmsEntry,\n  updatePaymentStatus,\n} from "@/lib/repository";',
    'import {\n  createPayment,\n  saveBlock,\n  saveCmsEntry,\n  updatePaymentStatus,\n  deleteCmsEntry,\n  deletePayment\n} from "@/lib/repository";'
)

new_actions = """
export async function deleteCmsAction(formData: FormData) {
  await requireAdmin();
  const id = text(formData, "id");
  if (id) {
    await deleteCmsEntry(id);
    revalidatePath("/admin/events");
    revalidatePath("/admin/content");
  }
}

export async function deletePaymentAction(formData: FormData) {
  await requireAdmin();
  const id = text(formData, "id");
  if (id) {
    await deletePayment(id);
    revalidatePath("/admin/payments");
  }
}
"""

content = content + new_actions

with open('app/admin/actions.ts', 'w') as f:
    f.write(content)
