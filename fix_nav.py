with open('lib/src/features/contribute/contribute_page.dart', 'r') as f:
    content = f.read()

bad_code = """        if (!mounted) return;
        setState(() => _paymentMarkedComplete = true);
        _showSnack('Payment marked complete. Thank you for contributing.');"""

good_code = """        if (!mounted) return;
        _showSnack('Payment marked complete. Thank you for contributing.');
        
        // Navigate to home page
        if (widget.onBackToHome != null) {
          widget.onBackToHome?.call();
        } else if (Navigator.canPop(context)) {
          Navigator.pop(context);
        }"""
        
content = content.replace(bad_code, good_code)

with open('lib/src/features/contribute/contribute_page.dart', 'w') as f:
    f.write(content)
