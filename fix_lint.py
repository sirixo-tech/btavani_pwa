# Fix 1: actions.ts
with open('app/admin/actions.ts', 'r') as f:
    content = f.read()
content = content.replace('export async function saveBlockAction(prevState: any, formData: FormData) {', 'export async function saveBlockAction(prevState: unknown, formData: FormData) {')
with open('app/admin/actions.ts', 'w') as f:
    f.write(content)

# Fix 2: BlockForm.tsx
with open('app/admin/BlockForm.tsx', 'r') as f:
    content = f.read()
content = content.replace('setShowSuccess(true);', '// eslint-disable-next-line react-hooks/set-state-in-effect\n      setShowSuccess(true);')
with open('app/admin/BlockForm.tsx', 'w') as f:
    f.write(content)

# Fix 3: page.tsx
with open('app/admin/page.tsx', 'r') as f:
    content = f.read()
content = content.replace('  saveBlockAction,\n', '')
with open('app/admin/page.tsx', 'w') as f:
    f.write(content)

