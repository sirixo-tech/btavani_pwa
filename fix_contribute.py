with open('lib/src/features/contribute/contribute_page.dart', 'r') as f:
    content = f.read()

# Fix 1: _upiUri
bad_upi_uri = """  Uri get _upiUri {
    final amount = _selectedAmount ?? amounts.first.amount!;

    if (_isLoadingBlocks) {
      return const Center(
        child: CircularProgressIndicator(color: _maroon),
      );
    }

    return Uri("""
good_upi_uri = """  Uri get _upiUri {
    final amount = _selectedAmount ?? amounts.first.amount!;

    return Uri("""
content = content.replace(bad_upi_uri, good_upi_uri)

# Fix 2: the assignments in _AddressStep and _BlockStep callbacks
# We passed blocks: _blocks.map((b) => b.name).toList() so the callback receives a String blockName.
content = content.replace(
    "setState(() => _selectedBlock = block);",
    "setState(() => _selectedBlock = _blocks.firstWhere((b) => b.name == block));"
)

with open('lib/src/features/contribute/contribute_page.dart', 'w') as f:
    f.write(content)
