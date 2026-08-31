with open('app/admin/page.tsx', 'r') as f:
    content = f.read()

# Add import
content = content.replace(
    'import type { Block, CmsEntry, Payment } from "@/lib/types";',
    'import type { Block, CmsEntry, Payment } from "@/lib/types";\nimport { BlockForm } from "./BlockForm";'
)

# Remove inline BlockForm function
# It starts at: function BlockForm({ block }: { block: Block }) {
import re
content = re.sub(r"function BlockForm\(\{ block \}: \{ block: Block \}\) \{.*?\n\}\n\n", "", content, flags=re.DOTALL)

with open('app/admin/page.tsx', 'w') as f:
    f.write(content)
