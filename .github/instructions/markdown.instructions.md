---
name: markdown-linting
description: Rules based on markdownlint standards for consistent Markdown formatting
applyTo: "**/*.md"
---

# Markdown Linting and Formatting Rules

This document defines the Markdown linting and formatting rules based on markdownlint standards. Follow these rules when creating or editing Markdown files to ensure consistency, readability, and compatibility across different Markdown parsers.

## Heading Rules

1. **MD001 - Heading levels should only increment by one level at a time**: Do not skip heading levels. If you have an H1, the next heading should be H2, not H3.

2. **MD003 - Heading style**: Use consistent heading style throughout the document. Prefer ATX-style headings (`# Heading`) over Setext-style. Do not mix styles.

3. **MD018 - No space after hash on atx style heading**: Always include a space after the hash character(s) in ATX-style headings. Use `# Heading` not `#Heading`.

4. **MD019 - Multiple spaces after hash on atx style heading**: Use only one space between the hash character(s) and the heading text. Use `# Heading` not `#  Heading`.

5. **MD020 - No space inside hashes on closed atx style heading**: For closed ATX-style headings, include a space on both sides. Use `# Heading #` not `#Heading#`.

6. **MD021 - Multiple spaces inside hashes on closed atx style heading**: Use only one space on each side of closed ATX-style headings. Use `# Heading #` not `#  Heading  #`.

7. **MD022 - Headings should be surrounded by blank lines**: Ensure headings have a blank line before and after them (except at the start or end of a document).

8. **MD023 - Headings must start at the beginning of the line**: Do not indent headings with spaces unless they are inside a block quote.

9. **MD024 - Multiple headings with the same content**: Avoid duplicate heading text in the same document to prevent anchor conflicts.

10. **MD025 - Multiple top-level headings in the same document**: Use only one H1 heading per document, typically as the document title.

11. **MD026 - Trailing punctuation in heading**: Do not end headings with punctuation like periods, commas, colons, or semicolons. Question marks are allowed for FAQ-style documents.

12. **MD041 - First line in a file should be a top-level heading**: Start documents with an H1 heading unless front matter is present.

13. **MD043 - Required heading structure**: Follow any project-specific heading structure requirements.

## List Rules

14. **MD004 - Unordered list style**: Use consistent markers for unordered lists throughout the document. Choose either `-`, `*`, or `+` and use it consistently.

15. **MD005 - Inconsistent indentation for list items at the same level**: Ensure all list items at the same level have the same indentation.

16. **MD007 - Unordered list indentation**: Indent nested list items by 2 spaces (configurable). Be consistent with indentation throughout the document.

17. **MD029 - Ordered list item prefix**: Use consistent numbering for ordered lists. Either use `1.` for all items or use sequential numbering `1.`, `2.`, `3.`.

18. **MD030 - Spaces after list markers**: Use one space after list markers (`-`, `*`, `+`, `1.`) before the list item text.

19. **MD032 - Lists should be surrounded by blank lines**: Ensure lists have a blank line before and after them (except at the start or end of a document).

## Whitespace and Formatting Rules

20. **MD009 - Trailing spaces**: Remove trailing whitespace from lines unless specifically using 2+ spaces for a hard line break.

21. **MD010 - Hard tabs**: Use spaces for indentation, not hard tabs. Configure your editor to convert tabs to spaces.

22. **MD012 - Multiple consecutive blank lines**: Use only one blank line to separate content. Avoid multiple consecutive blank lines.

23. **MD027 - Multiple spaces after blockquote symbol**: Use only one space after the `>` symbol in blockquotes.

24. **MD028 - Blank line inside blockquote**: Ensure blockquotes that are meant to be separate have content between them, or use `>` on blank lines for continuous blockquotes.

## Code Rules

25. **MD014 - Dollar signs used before commands without showing output**: Do not prefix shell commands with `$` in code blocks unless showing output.

26. **MD031 - Fenced code blocks should be surrounded by blank lines**: Ensure fenced code blocks have a blank line before and after them.

27. **MD040 - Fenced code blocks should have a language specified**: Always specify a language identifier for syntax highlighting in fenced code blocks (e.g., ` ```bash`, ` ```python`, ` ```javascript`).

28. **MD046 - Code block style**: Use consistent code block style throughout the document. Prefer fenced code blocks (` ``` `) over indented code blocks.

29. **MD048 - Code fence style**: Use consistent fence characters for code blocks. Prefer backticks (` ``` `) over tildes (`~~~`).

## Link and Image Rules

30. **MD011 - Reversed link syntax**: Use correct link syntax with square brackets for text and parentheses for URL, not the reverse.

31. **MD034 - Bare URL used**: Wrap URLs in angle brackets (e.g., `<https://example.com>`) or use proper link syntax with descriptive text.

32. **MD042 - No empty links**: Ensure all links have a destination. Avoid links with empty URLs or fragments.

33. **MD051 - Link fragments should be valid**: Ensure internal link fragments match actual heading IDs in the document.

34. **MD052 - Reference links and images should use a label that is defined**: When using reference-style links or images, ensure the reference label is defined.

35. **MD053 - Link and image reference definitions should be needed**: Remove unused reference link/image definitions.

36. **MD054 - Link and image style**: Use consistent link and image styles throughout the document.

37. **MD059 - Link text should be descriptive**: Use descriptive link text instead of generic phrases like "click here" or "link".

## Image Rules

38. **MD045 - Images should have alternate text (alt text)**: Always provide descriptive alt text for images for accessibility.

## Inline HTML Rules

39. **MD033 - Inline HTML**: Avoid inline HTML when pure Markdown alternatives exist. Use Markdown syntax for formatting.

## Emphasis and Strong Rules

40. **MD036 - Emphasis used instead of a heading**: Do not use bold or italic text as a heading substitute. Use proper heading syntax.

41. **MD037 - Spaces inside emphasis markers**: Do not include spaces between emphasis markers and text. Use `**bold**` not `** bold **`.

42. **MD038 - Spaces inside code span elements**: Do not include unnecessary spaces in inline code spans. Use `` `code` `` not `` ` code ` ``.

43. **MD039 - Spaces inside link text**: Do not include unnecessary spaces inside link text brackets. Keep link text tight against the square brackets.

44. **MD049 - Emphasis style**: Use consistent emphasis markers throughout the document. Choose either `*text*` or `_text_` and use consistently.

45. **MD050 - Strong style**: Use consistent strong emphasis markers throughout the document. Choose either `**text**` or `__text__` and use consistently.

## Line Length Rules

46. **MD013 - Line length**: Keep lines to a reasonable length (default 80 characters for headings and code, configurable for other content). Note that this rule is often disabled for documentation that includes long URLs or other content that cannot be easily broken across lines.

## Horizontal Rule Rules

47. **MD035 - Horizontal rule style**: Use consistent horizontal rule style throughout the document. Choose one format (`---`, `***`, or `___`) and use it consistently.

## Table Rules

48. **MD055 - Table pipe style**: Use consistent pipe style for tables. Include leading and trailing pipes on all rows.

49. **MD056 - Table column count**: Ensure all rows in a table have the same number of columns.

50. **MD058 - Tables should be surrounded by blank lines**: Ensure tables have a blank line before and after them.

51. **MD060 - Table column style**: Use consistent column spacing in tables. Choose aligned, compact, or tight style and use consistently.

## Other Rules

52. **MD044 - Proper names should have the correct capitalization**: Use correct capitalization for proper names (e.g., "GitHub" not "github", "JavaScript" not "javascript").

53. **MD047 - Files should end with a single newline character**: Ensure all Markdown files end with a single newline character.

## Configuration and Suppression

### Inline Suppression

You can suppress specific rules for sections of your document using HTML comments:

```markdown
<!-- markdownlint-disable MD033 -->
<div>This HTML is allowed</div>
<!-- markdownlint-enable MD033 -->
```

Or disable rules for a single line:

```markdown
<!-- markdownlint-disable-next-line MD033 -->
<div>This HTML is allowed</div>
```

Or disable for the entire file:

```markdown
<!-- markdownlint-disable-file MD033 -->
```

### Configuration Files

Create a `.markdownlint.json`, `.markdownlint.jsonc`, `.markdownlint.yaml`, or `.markdownlint.yml` file in your project to configure rules:

```json
{
  "MD013": false,
  "MD003": { "style": "atx" },
  "MD007": { "indent": 2 }
}
```

## Best Practices

1. **Consistency**: The most important principle is consistency. Choose a style and stick to it throughout your document and project.

2. **Accessibility**: Always include alt text for images and use descriptive link text for screen readers.

3. **Readability**: Use blank lines to separate sections, headings, lists, and code blocks for better readability.

4. **Semantic Structure**: Use headings to create a logical document structure that can be easily navigated.

5. **Valid Links**: Ensure all internal links point to valid headings or anchors in your document.

6. **Language-Specific Code Blocks**: Always specify the language for code blocks to enable proper syntax highlighting.

7. **Avoid HTML**: Use pure Markdown whenever possible for better portability and compatibility across different Markdown processors.

8. **Line Endings**: Configure your editor to use consistent line endings (typically LF for cross-platform compatibility).

## Tools and Integration

- **VS Code Extension**: Install the `markdownlint` extension by David Anson for real-time linting
- **Command Line**: Use `markdownlint-cli2` for CI/CD integration
- **GitHub Actions**: Use `markdownlint-cli2-action` for automated PR checks
- **Pre-commit Hooks**: Integrate markdownlint into your git pre-commit workflow

## Resources

- [markdownlint GitHub Repository](https://github.com/DavidAnson/markdownlint)
- [markdownlint Rules Documentation](https://github.com/DavidAnson/markdownlint/blob/main/doc/Rules.md)
- [VS Code Extension](https://marketplace.visualstudio.com/items?itemName=DavidAnson.vscode-markdownlint)
- [markdownlint-cli2](https://github.com/DavidAnson/markdownlint-cli2)
- [CommonMark Specification](https://spec.commonmark.org/)
- [GitHub Flavored Markdown](https://github.github.com/gfm/)
